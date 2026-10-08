# HUPO Growth CRM v1.0 — REUSE / EXTEND / CREATE Veri Eşleme Planı

Tarih: 2026-10-08
Kaynak: Growth CRM v1.0 FINAL CodePack + mevcut Hupo Supabase şeması

---

## REUSE — Mevcut Hupo core tabloları doğrudan kullanılır (duplicate etme)

| Mevcut Hupo Tablosu | Growth CRM Karşılığı | Nasıl Kullanılır |
|---|---|---|
| `auth.users` | auth/identity | Kullanıcı kimliği, e-posta — değişmez |
| `profiles` (veli/ogrenci) | `growth_households.core_parent_user_id` + `growth_students.core_student_id` | FK bağlantısı; veri kopyalanmaz |
| `student_stats` | `growth_students` aggregate alanları | VIEW ile çekilir (active_days, xp, streak, level, last_active) |
| `subscriptions` + `plans` | `growth_subscription_projection` | Projection tablosu core'dan sync edilir |
| `payments` | `growth_financial_transactions` | Projection tablosu core ödeme kayıtlarını referans eder |
| `admin_audit_log` | `growth_audit_log` | Mevcut denetim izi genişletilir, yeni tablo YARATILMAZ |
| `iletisim_ayarlari` | `growth_*` seviyesinde de kullanılır | Mevcut sessiz saat / sıklık sınırı korunur |

## EXTEND — Mevcut tablolara alan veya ilişki eklenir

| Mevcut Hupo Tablosu | Eklenen Alan/İlişki | Gerekçe |
|---|---|---|
| `veli_adaylari` | `growth_prospect_id uuid` FK | Mevcut basit lead tablosu korunur; zenginleştirilmiş veri Growth prospect'e bağlanır |
| `iletisim_tercihleri` | — | Mevcut kanal bazlı izin sistemi korunur; Growth CRM `growth_consents` tablosu YERİNE mevcut tablo kullanılır. Household→profile köprüsü VIEW ile |
| `iletisim_tercih_gecmisi` | — | KVKK kanıt zinciri aynen korunur |
| `olay_kutusu` | — | Domain outbox korunur; Growth events ayrı tablo (amaç farklı: analytics vs integration) |
| `segmentler` | — | Mevcut segment sistemi korunur; Growth segments ayrı `growth_segments` olarak yaratılır (daha geniş logic_json). İleride birleşebilir |
| `iletisim_kampanyalari` | — | Mevcut kampanya sistemi korunur; Growth campaigns daha geniş kapsam |

## CREATE — Yalnız Growth CRM'e özgü yeni tablolar (growth_* prefix)

### Migration 1: Growth OS Çekirdek (001_growth_os.sql → birleşik migration)

| Yeni Tablo | Açıklama | Core Bağlantısı |
|---|---|---|
| `growth_households` | Müşteri/hane ana kartı | `core_parent_user_id → profiles.id` |
| `growth_students` | Öğrenci CRM projeksiyonu | `core_student_id → profiles.id`, VIEW ile `student_stats` |
| `growth_consents` | **KULLANILMAYACAK** — mevcut `iletisim_tercihleri` kullanılır | İki tablo arasında uyumluluk VIEW'ı |
| `growth_events` | Geniş olay akışı (web/app/crm/payment/support) | `household_id`, `student_id` FK |
| `growth_identity_links` | anonymous_id → household bağlama | — |
| `growth_journeys` + `steps` + `enrollments` | Journey otomasyon motoru | segment + household FK |
| `growth_campaigns` (growth_) | Genişletilmiş kampanya | `growth_segments` FK |
| `growth_templates` | Mesaj şablonları | — |
| `growth_message_log` | Mesaj teslim kaydı | household + campaign + journey FK |
| `growth_ai_recommendations` | AI öneri katmanı | household FK |

### Migration 2: CRM Satış & Destek (002_crm_core.sql → birleşik)

| Yeni Tablo | Açıklama | Core Bağlantısı |
|---|---|---|
| `growth_leads` | Zenginleştirilmiş satış adayı | `household_id`, `veli_adaylari` den migrate |
| `growth_opportunities` | Satış fırsatları | `household_id`, `lead_id` FK |
| `growth_tasks` | CRM görevleri (öğrenme görevlerinden farklı) | `household_id`, `lead_id` FK |
| `growth_support_tickets` | Destek masası | `household_id` FK |
| `growth_lead_sources` | Kaynak takibi | — |
| `growth_team_feed` | Ekip akışı/notlar (veli_notlari genişletmesi) | `household_id`, `lead_id` FK |
| `growth_custom_fields` + `values` | Özel alan altyapısı | — |

### Migration 3: Customer 360 Genişletme (003 → birleşik)

| Değişiklik | Açıklama |
|---|---|
| `ALTER growth_households` | customer_no, core_customer_id, first_name, last_name, location, subscription_status, revenue, UTM, consent vb. |
| `growth_customer_people` | Hane kişileri (veli, öğrenci, öğretmen, kurum yetkilisi) |
| `growth_customer_addresses` | Adresler |
| `growth_subscription_projection` | Abonelik CRM görünümü (core subscriptions'dan sync) |
| `growth_financial_transactions` | Finansal işlem geçmişi (core payments'dan sync) |
| `growth_customer_360` VIEW | 9 sekmeli müşteri görünümü |

### Migration 4: Prospect Acquisition (004 → birleşik)

| Yeni Tablo | Açıklama |
|---|---|
| `growth_prospects` | Potansiyel aday kayıtları + 4-bileşenli scoring |
| `growth_prospect_consents` | Aday kanal izinleri |
| `growth_prospect_events` | Aday olay zaman çizgisi |
| `growth_prospect_provenance` | Kaynak kanıtı/provenance |
| `growth_prospect_connectors` | Intake bağlayıcıları |
| `growth_lead_capture_forms` | Form tanımları |
| `growth_prospect_lists` + `members` | Aday listeleri |
| `growth_prospect_score_history` | Skor geçmişi |
| `growth_prospect_suppressions` | Suppression listesi |
| `growth_prospect_import_jobs` | CSV import işleri |
| `growth_prospect_360` VIEW | Aday 360° görünümü |

---

## Kritik Köprü Kararları

### 1. Consent Birleştirme
- **Karar**: `growth_consents` tablosu YARATILMAZ.
- Mevcut `iletisim_tercihleri` (veli_id + kanal) sistemi korunur.
- `growth_customer_360` VIEW'ı consent verilerini `iletisim_tercihleri` tablosundan çeker.
- Prospect'ler için `growth_prospect_consents` ayrı kalır (henüz müşteri olmayan kişiler).

### 2. Lead → Prospect Dönüşüm
- Mevcut `veli_adaylari` tablosu KORUNUR (basit lead capture devam eder).
- Yeni `growth_prospects` tablosu zengin üst-huni kaydıdır.
- `veli_adaylari` → `growth_prospects` tek yönlü bağlantı (FK veya data migration).
- Prospect → Lead dönüşümünde `growth_leads` kaydı oluşur.

### 3. Segment Eş Yaşam
- Mevcut `segmentler` (Hupo-spesifik kriterler: plan, sinif, aktiflik) korunur.
- `growth_segments` (geniş logic_json) ayrı yaratılır.
- İleride birleştirilebilir; şimdilik bağımsız.

### 4. Audit Log
- `growth_audit_log` tablosu YARATILMAZ.
- Mevcut `admin_audit_log` + `log_admin_action()` fonksiyonu kullanılır.
- CRM aksiyonları için yeni islem tipleri eklenir.

### 5. Customer 360 View
- `growth_customer_360` VIEW'ı hem `growth_households` hem de mevcut core tablolardan çeker.
- Core veriler (profiles, student_stats, subscriptions, payments) VIEW içinde JOIN edilir.
- CRM-spesifik veriler (consent, adres, işlem projeksiyonu) growth_* tablolarından.

---

## RLS ve Güvenlik Stratejisi

- Tüm `growth_*` tabloları `ENABLE ROW LEVEL SECURITY` + tüm istemci yetkileri REVOKE.
- Erişim yalnızca `SECURITY DEFINER` RPC'ler aracılığıyla (mevcut Hupo deseni).
- `require_admin()` guard'ı mevcut admin rol kontrolü ile uyumlu.
- `service_role` yalnızca edge function'larda; tarayıcıya asla konmaz.
- Çocuk verisi CRM istemcisinde maskeli; audience export'a dahil edilmez.

---

## Admin Panel Entegrasyon Stratejisi

- Growth CRM kaynak kodu Vite + React SPA'dır.
- Hupo admin paneli Next.js (App Router) + TailAdmin'dir.
- **Strateji**: UI bileşenleri Next.js sayfalarına PORTLANIR (Vite SPA olarak eklenmez).
- Servis katmanı (supabaseRepository, crmRepository, prospectRepository) Hupo admin'in mevcut Supabase client'ı ile yeniden yazılır.
- Sayfa yolları: `/yonetim/musteri-360`, `/yonetim/potansiyel-adaylar`, `/yonetim/satis-hatti` vb.
