# HUPO Growth CRM v1.0 — Uygulama Planı

Tarih: 2026-10-08
Referans: REUSE_EXTEND_CREATE_MAP.md, Growth CRM v1.0 FINAL CodePack

---

## Mimari Özet

```
┌─────────────────────────────────────────────────────────┐
│  Hupo Admin Panel (Next.js App Router + TailAdmin)      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Müşteri 360° │  │  Pot. Aday   │  │  Satış Hattı │  │
│  │  (9 sekme)   │  │   Listesi    │  │  + Görevler  │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │          │
│  ┌──────┴─────────────────┴─────────────────┴───────┐  │
│  │        Supabase RPC (SECURITY DEFINER)            │  │
│  │  admin_musteri_360()  admin_prospect_listele()    │  │
│  │  admin_lead_kaydet()  admin_gorev_listele()  ...  │  │
│  └──────────────────────┬────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────┘
                          │
┌─────────────────────────┼───────────────────────────────┐
│  Supabase PostgreSQL    │                               │
│  ┌──────────────────────┴────────────────────────────┐  │
│  │  CORE (REUSE — DEĞİŞTİRİLMEZ)                    │  │
│  │  profiles, student_stats, subscriptions, plans,    │  │
│  │  payments, iletisim_tercihleri, admin_audit_log    │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  GROWTH LAYER (YENİ — growth_* prefix)            │  │
│  │  growth_households, growth_students,               │  │
│  │  growth_customer_people, growth_customer_addresses, │  │
│  │  growth_subscription_projection,                   │  │
│  │  growth_financial_transactions,                    │  │
│  │  growth_leads, growth_opportunities,               │  │
│  │  growth_tasks, growth_support_tickets,             │  │
│  │  growth_team_feed, growth_events,                  │  │
│  │  growth_identity_links, growth_segments,           │  │
│  │  growth_journeys/steps/enrollments,                │  │
│  │  growth_campaigns, growth_templates,               │  │
│  │  growth_message_log, growth_ai_recommendations,    │  │
│  │  growth_prospects + 10 prospect alt tablo          │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  VIEWS                                            │  │
│  │  growth_customer_360 (core+growth JOIN)            │  │
│  │  growth_prospect_360 (prospect+events+consent)    │  │
│  │  growth_consent_bridge (iletisim_tercihleri→CRM)  │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │  EDGE FUNCTIONS (ileride)                         │  │
│  │  event-ingest, prospect-intake, score-recompute,  │  │
│  │  outreach-gate, ai-insights, journey-dispatch     │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Faz A: Veritabanı Migration (Öncelik 1)

### A1. Birleşik Growth Migration SQL
- CodePack'in 4 migration'ını mevcut Hupo şemasıyla uyumlu TEK migration'a birleştir
- `growth_consents` → ÇIKAR (mevcut iletisim_tercihleri kullanılır)
- `growth_audit_log` → ÇIKAR (mevcut admin_audit_log kullanılır)
- `growth_customer_360` VIEW → core tablolardan JOIN ile zenginleştir
- `growth_consent_bridge` VIEW → iletisim_tercihleri ↔ growth household bağlantısı
- Tüm tablolara RLS ENABLE + REVOKE ALL + require_admin() guard RPC'ler
- **Model**: Haiku (SQL migration yazımı)

### A2. Admin RPC Fonksiyonları
- Müşteri 360 RPC: `admin_musteri_360_listele`, `admin_musteri_360_detay`
- Prospect RPC: `admin_prospect_listele`, `admin_prospect_kaydet`, `admin_prospect_detay`
- Lead RPC: `admin_lead_listele`, `admin_lead_kaydet`, `admin_lead_asama`
- Task RPC: `admin_crm_gorev_listele`, `admin_crm_gorev_kaydet`
- Support RPC: `admin_destek_listele`, `admin_destek_kaydet`
- Team Feed RPC: `admin_ekip_akisi_listele`, `admin_ekip_akisi_ekle`
- **Model**: Haiku (RPC fonksiyonu yazımı, mevcut desen takibi)

---

## Faz B: Müşteri 360° UI (Öncelik 2)

### B1. Sayfa Oluşturma
- `web-panel/src/app/[locale]/(admin)/yonetim/musteri-360/page.tsx` — Liste sayfası
- `web-panel/src/app/[locale]/(admin)/yonetim/musteri-360/[id]/page.tsx` — 9 sekmeli detay
- **Model**: Haiku (Next.js sayfa + TailAdmin bileşen)

### B2. Müşteri 360 Bileşenleri
- Arama + filtre bileşeni
- 9 sekme bileşeni: GenelBakis, KimlikIletisim, HaneOgrenci, Abonelik, IslemOdeme,
  PazarlamaIzin, UrunKullanimi, CrmDestek, ZamanCizgisi
- PII maskeleme (national_id_last4)
- **Model**: Haiku

### B3. Sidebar Menü Entegrasyonu
- Yönetim menüsüne "CRM" grubu ekle: Müşteri 360°, Potansiyel Adaylar, Satış Hattı
- **Model**: Haiku

---

## Faz C: Potansiyel Adaylar UI (Öncelik 3)

### C1. Sayfa ve Bileşenler
- `web-panel/src/app/[locale]/(admin)/yonetim/potansiyel-adaylar/page.tsx` — Liste
- `web-panel/src/app/[locale]/(admin)/yonetim/potansiyel-adaylar/[id]/page.tsx` — Detay
- Prospect 360° bileşenleri: skor kartı, olay zaman çizgisi, consent durumu
- Manuel oluşturma formu
- CSV import wizard (önizleme + duplicate kontrolü)
- **Model**: Haiku

### C2. Scoring ve Consent UI
- 4 bileşenli skor gösterimi (fit/intent/engagement/data_quality)
- Kanal bazlı eligibility gösterimi
- Lead'e dönüştürme akışı
- **Model**: Haiku

---

## Faz D: Satış Hattı + Görevler + Destek (Öncelik 4)

### D1. Satış Hattı
- `web-panel/src/app/[locale]/(admin)/yonetim/satis-hatti/page.tsx` — Pipeline görünümü
- Lead/opportunity kartları, aşama sürükle-bırak
- **Model**: Haiku

### D2. CRM Görevleri
- Görev listesi + oluşturma (call, email, meeting, follow_up)
- Household/lead bağlantılı görev takibi
- **Model**: Haiku

### D3. Ekip Akışı ve Destek
- Team feed (not, arama, toplantı, destek, sistem)
- Destek masası (bilet listesi, öncelik, kategori)
- **Model**: Haiku

---

## Faz E: Pazarlama Motoru (Öncelik 5)

### E1. Journey Otomasyon UI
- Journey builder (adım dizisi: trigger → delay → condition → action)
- Enrollment takibi
- **Model**: Haiku

### E2. Şablon ve Kampanya Genişletme
- Template versiyonlama
- Growth kampanya yönetimi (mevcut iletisim_kampanyalari'nın genişletilmiş hali)
- **Model**: Haiku

---

## Faz F: Analitik + AI (Öncelik 6)

### F1. Growth Analitik Dashboard
- Dönüşüm hunisi, kaynak performansı, segment analizi
- Retention/churn metrikleri
- **Model**: Haiku

### F2. AI Öneri Katmanı (Read-Only)
- NBA (Next Best Action) kartları
- Lead skor açıklaması
- Churn risk açıklaması
- Müşteri özeti
- **Model**: Haiku

---

## Delegasyon Stratejisi

| Görev Tipi | Model | Gerekçe |
|---|---|---|
| SQL migration yazımı | Haiku | Şablon takibi, mevcut desen tekrarı |
| RPC fonksiyonları | Haiku | SECURITY DEFINER deseni sabit |
| Next.js sayfa oluşturma | Haiku | TailAdmin bileşen + RPC çağrısı |
| React bileşen porta etme | Haiku | Vite→Next.js, mock→RPC dönüşümü |
| VIEW ve köprü SQL | Haiku | JOIN mantığı basit |
| Karmaşık iş mantığı (scoring, consent gate) | Sonnet | Doğruluk kritik |
| Mimari karar ve kod incelemesi | Opus | Bu konuşmada yapılır |

---

## Commit Sırası

```
chore(crm): add REUSE/EXTEND/CREATE mapping docs
feat(db): growth CRM merged migration (tables + enums + indexes + RLS)
feat(db): growth CRM admin RPC functions
feat(admin): müşteri 360 liste + detay sayfaları
feat(admin): potansiyel adaylar liste + detay sayfaları
feat(admin): satış hattı + görev + destek sayfaları
feat(admin): sidebar CRM menü grubu
test(crm): consent gate + dedupe + scoring testleri
```
