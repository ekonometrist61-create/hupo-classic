# TASKS — Öğrenci Hazırlık (Hupo) kurtarma projesi
> Ana çalışma dosyası: `MASTER_BRIEF.md`
> Kurallar: `AGENTS.md`
> Temizlik kararları: `TEMIZLIK_RAPORU.md`
> Kurtarma kanıtı: `kurtarilan/KURTARMA_RAPORU.md`

Son güncelleme: 27 Eylül 2026

---

## 1. Tamamlananlar

### APK kurtarma
- [x] ADB kuruldu, telefon (Galaxy S23 FE) bağlandı
- [x] APK çekildi → `kurtarilan/ogrenci_hazirlik-base.apk` (66,7 MB)
- [x] `libapp.so` çıkarıldı (Dart AOT, 7,7 MB)
- [x] **Kayıp fontlar geri getirildi**: `mobile-app/assets/fonts/Nunito.ttf`, `Lexend.ttf`
      (bu iki dosya olmadan uygulama hiç derlenmiyordu)
- [x] Türkçe metin havuzu çıkarıldı: 214 metin
- [x] 153 metin diskteki kaynakta yok olarak işaretlendi (`kurtarilan/missing-turkish.txt`)
- [x] Sınıf/provider/RPC adları çıkarıldı (`kurtarilan/feature-tokens.txt`)

### Belgeler
- [x] `MASTER_BRIEF.md` — projenin tek doğruluk kaynağı
- [x] `AGENTS.md` — ajan kuralları
- [x] `TEMIZLIK_RAPORU.md` — silinebilirler listesi
- [x] `TASKS.md` — bu dosya
- [x] `Task.md` — eski adıyla (ikisi de var, `TASKS.md` esas)

### Temizlik
- [x] `Silinecekler/` karantina klasörü oluşturuldu
- [x] Taşınanlar: `node_modules` (556 MB), `.next` (504 MB), `.idea`, `reports/`,
      `research_notes/`, `proje-okulu-app/`, 7 fazlalık döküm, 2 yanlış adlı dosya
- [x] `supabase/config.toml` ana yere geri alındı
- [ ] **Kullanıcı onayı bekleniyor** — `Silinecekler/` kalıcı olarak silinecek

### Supabase kurtarma (canlı: ccozfrpnvyrnktpffkwo)
- [x] Erişim doğrulandı, `get_app_config` okunabildi
- [x] **Günlük 5 Sorusu**: 2 RPC + 2 tablo birebir kurtarıldı
      → `supabase/migrations/20260927000000_daily_challenge_and_bookmarks.sql`
- [x] **Çarpım Tablosu Şifreleri**: 5 RPC birebir kurtarıldı
- [x] **Sınıf seçimi**: 2 RPC birebir kurtarıldı
- [x] **Soru bildirme**: 1 RPC birebir kurtarıldı
      → `supabase/migrations/20260927000010_carpim_sifreleri_rpc.sql`
- [x] Migration hatası giderildi: parametre adı değişimi → `drop function` eklendi
- [ ] Çarpım tablolarının kolon tanımları alınacak (`kurtarilan/SEMA_CARPIM.sql`)
- [ ] `evaluate_badges`, `_sinif_yaz`, `_desteklenen_siniflar` gövdeleri alınacak
- [ ] `carpim_sifreleri` içeriği (10-12 şifrenin JSON verisi) kurtarılacak

### Mobil uygulama
- [x] `google_mobile_ads` paketi pubspec'e eklendiydi (APK'da vardı, kaybolmuştu)
- [x] `share_plus` **eklenmedi** — APK'da izi yok, tahminle paket eklemek derlemeyi kırar
- [x] `models/app_config.dart` yazıldı (canlı `get_app_config` yanıtından birebir)
- [ ] `models/cipher_models.dart` yazılacak
- [ ] `models/daily_challenge_models.dart` yazılacak
- [ ] `models/review_models.dart` yazılacak
- [ ] `services/personal_best.dart` yazılacak
- [ ] `widgets/` altındaki 8 dosya yazılacak
- [ ] `screens/` altındaki 6 dosya yazılacak
- [ ] `ads/` altındaki 2 dosya yazılacak
- [ ] `content/answer_feedback.dart` yazılacak

### Web paneli
- [ ] Lint hataları giderilecek (mevcut 15 hata + 1 uyarı, `any` kullanımı ve
      effect içinden senkron state güncellemesi kaynaklı)
- [ ] `npm run build` tamamlanacak (120 sn sınırında bitmedi)
- [ ] Admin paneli tarayıcıda doğrulanacak
- [ ] **Git kurulmalı** — Flutter bu yüzden başlayamıyor

---

## 2. Eksik 22 Dart dosyası

Yazım sırası: `models/` → `services/` → `widgets/` → `screens/` → `ads/`

```
lib/ads/ad_config.dart
lib/ads/student_banner_ad.dart
lib/content/answer_feedback.dart
lib/models/app_config.dart                    ← YAZILDI
lib/models/cipher_models.dart
lib/models/daily_challenge_models.dart
lib/models/review_models.dart
lib/screens/cipher/cipher_lesson_screen.dart
lib/screens/cipher/cipher_list_screen.dart
lib/screens/cipher/genel_alistirma_screen.dart
lib/screens/daily_challenge_screen.dart
lib/screens/grade_picker_screen.dart
lib/screens/review_screen.dart
lib/screens/saved_questions_screen.dart
lib/services/personal_best.dart
lib/widgets/bookmark_button.dart
lib/widgets/cipher_badges_dialog.dart
lib/widgets/cipher_icons.dart
lib/widgets/daily_challenge_card.dart
lib/widgets/maintenance_gate.dart
lib/widgets/report_question_button.dart
lib/widgets/ui/responsive_page.dart
```

---

## 3. Kurtarılan RPC özeti

| RPC | Dosya | Durum |
|---|---|---|
| `get_daily_challenge()` | 20260927000000 | ✅ |
| `complete_daily_challenge()` | 20260927000000 | ✅ |
| `list_bookmarks()` | 20260927000000 | ✅ |
| `toggle_bookmark(uuid)` | 20260927000000 | ✅ |
| `get_carpim_sifreleri()` | 20260927000010 | ✅ |
| `get_carpim_sifre_detay(uuid)` | 20260927000010 | ✅ |
| `submit_cipher_answer(uuid,text,int,int)` | 20260927000010 | ✅ |
| `complete_cipher_stage(uuid,text)` | 20260927000010 | ✅ |
| `report_taught_friend(uuid)` | 20260927000010 | ✅ |
| `get_supported_grades()` | 20260927000010 | ✅ |
| `set_my_grade(int)` | 20260927000010 | ✅ |
| `report_question(uuid,text,text)` | 20260927000010 | ✅ |
| `get_app_config()` | — | ✅ canlıda, migration'a gerek yok |
| `admin_set_daily_challenge(...)` | — | ⏳ gövde alınmadı |

## 4. Kurtarılan tablolar

| Tablo | Durum |
|---|---|
| `daily_challenges` | ✅ kolon + kısıt + RLS |
| `daily_challenge_completions` | ✅ kolon + kısıt + RLS |
| `question_bookmarks` | ✅ kolon + kısıt + 3 RLS politikası |
| `carpim_sifreleri` | ⏳ kolonlar bekleniyor |
| `carpim_ilerleme` | ⏳ kolonlar bekleniyor |
| `carpim_deneme_log` | ⏳ kolonlar bekleniyor |
| `grade_changes` | ⏳ kolonlar bekleniyor |
| `question_reports` | ⏳ kolonlar bekleniyor |
| `user_badges` | ⏳ kolonlar bekleniyor |

---

## 5. Öğrenilen iş kuralları (canlı koddan)

**Çarpım şifresi:**
- Kapalı testte ilk doğru cevap = 1 yıldız; tekrar cevaplamak yıldız getirmez
- Kapalı test cevapları istemciye gönderilmez, sadece soru metni
- Yanlış cevapta `sifre_hatirlatma` (isim + tanım) döner
- `ogretti` bayrağı "arkadaşıma anlattım" rozetini tetikler

**Günlük 5 soru:**
- Bonus XP = **25**
- Havuz önceliği: `sinifN` → `hepsi` → `ortaokul` → `ilkokul` → `lise`
- `question_ids` 1-10 arası

**Sınıf değiştirme:**
- İlk seçim serbest
- Sonra 30 günde bir
- Değişiklikler arası 24 saat

**Soru bildirme:**
- Gerekçeler: `yanlis_cevap` | `anlasilmiyor` | `yazim` | `diger`
- Kişi başı günde en fazla 20 bildirim
- Yalnızca onaylı sorular bildirilebilir

**Reklam:** `get_app_config` → `reklamlar.ogrenci_acik: false`. Varsayılan KAPALI.

---

## 6. Engeller

| Engel | Etki | Çözüm |
|---|---|---|
| **Git kurulu değil** | Flutter başlamıyor, mobil test yapılamıyor | Git for Windows kur |
| **Node.js PATH'te değil** | `npm` doğrudan çalışmıyor | `C:\Program Files\nodejs` PATH'e eklensin |
| Web lint 15 hata | Build kalitesi düşük | `any` kullanımı temizlenecek |
| Dev sunucusu kalıcı başlamıyor | Tarayıcıda test yapılamıyor | Manuel `npm run dev` ile açılmalı |
| APK release derleme | Uygulama içi veri çekilemedi | Veriler zaten Supabase'de |

---

## 7. Sıradaki adımlar

1. `kurtarilan/SEMA_CARPIM.sql` çalıştır, CSV indir → çarpım tabloları şeması
2. `carpim_sifreleri` içerik verisini kurtar (10-12 şifre)
3. `20260927000020_carpim_sifreleri_tables.sql` migration'ını yaz
4. `models/cipher_models.dart` → `models/daily_challenge_models.dart` → `models/review_models.dart`
5. `services/personal_best.dart`
6. `widgets/` (8 dosya)
7. `screens/` (6 dosya)
8. Git kur → Flutter testleri
9. Web lint hataları
10. `Silinecekler/` kalıcı silme (onay bekleniyor)

---

## 8. Alt ajan notu

Bu depoda alt ajan desteği yok; her iş tek ajan tarafından yapılır.
