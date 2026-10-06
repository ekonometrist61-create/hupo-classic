# TASKS — Öğrenci Hazırlık (Hupo) kurtarma projesi
> Ana çalışma dosyası: `MASTER_BRIEF.md`
> Kurallar: `AGENTS.md`
> Temizlik kararları: `TEMIZLIK_RAPORU.md`
> Kurtarma kanıtı: `kurtarilan/KURTARMA_RAPORU.md`

Son güncelleme: 03 Ekim 2026

---

## 0. Mimari toparlama (bu oturum)

Tek kök git deposu kuruldu ve aşağıdaki eksikler giderildi:

- [x] **Kök depo + `.gitignore`** — `kurtarilan/`, `Silinecekler/`, `node_modules/`,
      `.next/`, `build/`, `.dart_tool/`, `*.log`, `.env*.local` artık takip dışı.
      İç içe `web-panel/.git` ve `mobile-app/.git` depoları silinmedi,
      `Desktop\çıkarıldı\_firsat-git-arsiv-20260927\` altına **arşivlendi**.
- [x] **Demo modu güvenliği** — `NEXT_PUBLIC_DEMO_MODE` artık tek kaynaktan
      (`web-panel/src/lib/demo-mode.ts`) okunuyor ve
      `NODE_ENV === "production"` iken **asla** etkinleşmiyor.
- [x] **Derleme (build) kırığı** — `AdminDashboard.tsx`'in import ettiği
      `demoData.ts` `.gitignore`'daydı → temiz kopyada build kırılıyordu; artık commit'te.
- [x] **Web lint: 14 hata → 0 hata** (`types.ts` vendor `any`, kullanılmayan
      değişken, demo `setState`). Kalan `react-hooks/set-state-in-effect` uyarıları
      gerekçesiyle `warn` seviyesine çekildi.
- [x] **Migration sırası düzeltildi** — tablolar (`…000010`) artık RPC'lerden
      (`…000020`) önce çalışıyor.
- [x] `supabase/KURTARMA_DURUMU.md` eklendi — `supabase db reset`'i bloke eden
      eksik nesneler ve canlıdan kurtarma SQL'i burada.

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
- [x] Çarpım tablolarının kolon tanımları kurtarıldı (`20260927000010`)
- [x] `_sinif_yaz`, `_desteklenen_siniflar`, `_refresh_question_flag` gövdeleri
      **birebir** kurtarıldı (+ `admin_set_daily_challenge`)
      → `supabase/migrations/20260927000030_missing_objects_recovery.sql`
- [x] `question_quality_config` tablosu eklendi (`20260927000050`)
- [x] `questions.inceleme_gerekli` kolonu eklendi (`20260927000040`)
- [x] `profiles` sınıf kuralı trigger'ı eklendi (`20260927000060`)
- [x] `grade_changes` / `question_reports` RLS politikaları fail-closed doğrulandı (`20260927000030`)
- [x] `carpim_sifreleri` başlangıç seed verisi eklendi; 10 şifreye tamamlandı (`20260927000015_carpim_sifreleri_seed.sql`)
- [x] `evaluate_badges` gövdesi ve rozetler doğrulandı (`20260920000500_badges.sql`)

### Mobil uygulama
- [x] `google_mobile_ads` paketi pubspec'e eklendiydi (APK'da vardı, kaybolmuştu)
- [x] `share_plus` **eklenmedi** — APK'da izi yok, tahminle paket eklemek derlemeyi kırar
- [x] `models/app_config.dart` yazıldı (canlı `get_app_config` yanıtından birebir)
- [x] `models/cipher_models.dart` yazıldı
- [x] `models/daily_challenge_models.dart` yazıldı
- [x] `models/review_models.dart` yazıldı
- [x] `services/personal_best.dart` yazıldı
- [x] `widgets/` altındaki 8 dosya yazıldı
- [x] `screens/` altındaki 6 dosya yazıldı
- [x] `ads/` altındaki 2 dosya yazıldı
- [x] `content/answer_feedback.dart` yazıldı
- [x] Uygulama içi entegrasyonlar tamamlandı (`main.dart`, `home_screen.dart`, `profile_screen.dart`, `quiz_screen.dart`)
- [x] **Karakter koleksiyon sistemi** — 40 karakter/8 sınıf, migration+model+provider+widget+ekran (03 Ekim 2026)
- [x] `RadioListTile.groupValue/onChanged` Flutter 3.32 deprecasyonu `RadioGroup` ile giderildi
- [x] `MaintenanceGate` canlı versiyon kontrolü — `package_info_plus` + `url_launcher` mağaza linki
- [x] JWT güvenli depo — `flutter_secure_storage` (Android Keystore/iOS Keychain) ile `SecureLocalStorage`
- [x] Karakter unlock kutlaması — `CharacterCelebrationListener` + `CharacterUnlockDialog` (konfeti)
- [x] Ana ekrana Karakterlerim kısayolu (`_KarakterKisayolu` widget, quiz sonrası provider invalidate)

### Web paneli
- [x] Lint hataları giderildi (`eslint .` → 0 hata)
- [x] `npm run build` tamamlandı (`✓ Compiled successfully in 2.9min`, 51 sayfa)
- [x] PHASE 0 durum raporu yazıldı → `PHASE0_DURUM_RAPORU.md`
- [x] Web public giriş rotası production server'da doğrulandı; admin rotası oturumsuzken girişe yönleniyor
- [x] Web proxy locale-prefix normalizasyonu düzeltildi; anonim claim gerçek oturum sayılmıyor
- [ ] Admin paneli oturum açılmış tarayıcıda doğrulanacak (kullanıcı oturumu gerekir)
- [x] **Soru bankası — Matematik Bölüm 1**: 50 örnek soru migration'a dönüştürüldü (`20261003000001_soru_bankasi_matematik_bolum1.sql`); onay_durumu = 'beklemede' (kaynak doğrulanmamış)
- [ ] Proje ASCII yola taşınacak (Türkçe/OneDrive yolu Dart/Flutter için önerilir)
- [x] Web TypeScript kontrolü temiz (`tsc --noEmit`)
- [x] Web production build temiz (`next build --webpack`, 51 rota)
- [x] Dart yapısal/import statik denetimi temiz (`tools/dart-statik-denetim.mjs`, 81 dosya)
- [x] `Silinecekler/` klasörü kullanıcı talimatıyla kalıcı olarak silindi
- [ ] Flutter analyze / Chrome çalıştırması OneDrive build kilidi nedeniyle bekliyor

---

## 2. Eksik 22 Dart dosyası — TÜMÜ TAMAMLANDI ✅

Tüm 22 dosya `mobile-app/lib/` altında mevcut:

- [x] lib/ads/ad_config.dart
- [x] lib/ads/student_banner_ad.dart
- [x] lib/content/answer_feedback.dart
- [x] lib/models/app_config.dart
- [x] lib/models/cipher_models.dart
- [x] lib/models/daily_challenge_models.dart
- [x] lib/models/review_models.dart
- [x] lib/screens/cipher/cipher_lesson_screen.dart
- [x] lib/screens/cipher/cipher_list_screen.dart
- [x] lib/screens/cipher/genel_alistirma_screen.dart
- [x] lib/screens/daily_challenge_screen.dart
- [x] lib/screens/grade_picker_screen.dart
- [x] lib/screens/review_screen.dart
- [x] lib/screens/saved_questions_screen.dart
- [x] lib/services/personal_best.dart
- [x] lib/widgets/bookmark_button.dart
- [x] lib/widgets/cipher_badges_dialog.dart
- [x] lib/widgets/cipher_icons.dart
- [x] lib/widgets/daily_challenge_card.dart
- [x] lib/widgets/maintenance_gate.dart
- [x] lib/widgets/report_question_button.dart
- [x] lib/widgets/ui/responsive_page.dart

Ek olarak yazılan (kurtarma sonrası yeni):
- [x] lib/screens/collection_screen.dart — 40 karakterli koleksiyon ekranı
- [x] lib/widgets/character/character_card_widget.dart
- [x] lib/widgets/character/character_celebration_listener.dart
- [x] lib/widgets/character/character_detail_sheet.dart
- [x] lib/widgets/character/character_unlock_dialog.dart
- [x] lib/services/secure_storage.dart — JWT güvenli depo (Android Keystore / iOS Keychain)

---

## 3. Kurtarılan RPC özeti

| RPC | Dosya | Durum |
|---|---|---|
| `get_daily_challenge()` | 20260927000000 | ✅ |
| `complete_daily_challenge()` | 20260927000000 | ✅ |
| `list_bookmarks()` | 20260927000000 | ✅ |
| `toggle_bookmark(uuid)` | 20260927000000 | ✅ |
| `get_carpim_sifreleri()` | 20260927000020 | ✅ |
| `get_carpim_sifre_detay(uuid)` | 20260927000020 | ✅ |
| `submit_cipher_answer(uuid,text,int,int)` | 20260927000020 | ✅ |
| `complete_cipher_stage(uuid,text)` | 20260927000020 | ✅ |
| `report_taught_friend(uuid)` | 20260927000020 | ✅ |
| `get_supported_grades()` | 20260927000020 | ✅ |
| `set_my_grade(int)` | 20260927000020 | ✅ |
| `report_question(uuid,text,text)` | 20260927000020 | ✅ |
| `get_app_config()` | — | ✅ canlıda, migration'a gerek yok |
| `admin_set_daily_challenge(date, uuid[], text)` | 20260927000030 | ✅ |

**Yardımcı fonksiyonlar** (`20260927000030`, istemciye EXECUTE **verilmedi**):
`_desteklenen_siniflar()`, `_sinif_yaz(uuid, integer, text)`,
`_refresh_question_flag(uuid)`

## 4. Kurtarılan tablolar

| Tablo | Durum |
|---|---|
| `daily_challenges` | ✅ kolon + kısıt + RLS |
| `daily_challenge_completions` | ✅ kolon + kısıt + RLS |
| `question_bookmarks` | ✅ kolon + kısıt + 3 RLS politikası |
| `carpim_sifreleri` | ✅ kolon + kısıt + RLS (20260927000010) |
| `carpim_ilerleme` | ✅ kolon + kısıt + RLS (20260927000010) |
| `carpim_deneme_log` | ✅ kolon + kısıt + RLS (20260927000010) |
| `grade_changes` | ✅ kolon + kısıt + index (20260927000030) — RLS politikaları ⏳ |
| `question_reports` | ✅ kolon + kısıt + 4 index (20260927000030) — RLS politikaları ⏳ |
| `question_quality_config` | 🚫 **yok** — `report_question()` bunu okur (KURTARMA_DURUMU.md §4.1) |
| `user_badges` | ✅ mevcut (`20260920000000_initial_schema.sql`) |

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
| **Supabase eksik nesneler** | `supabase db reset` hata verir | `supabase/KURTARMA_DURUMU.md` |
| **Flutter, Türkçe/OneDrive yolu** | `flutter analyze` çöküyor (255) | Projeyi ASCII yola taşı (`C:\Users\cengi\flutterwork`) |
| **Supabase CLI yok** | `db pull` / `test db` çalışmıyor | `npm i -g supabase` |
| `react-hooks/set-state-in-effect` uyarıları | Lint uyarı (hata değil) | Şablon bileşenleri elden geçerken refaktör |
| Dev sunucusu kalıcı başlamıyor | Tarayıcıda test yapılamıyor | Manuel `npm run dev` ile açılmalı |

---

## 7. Sıradaki adımlar

### Ajan yapabilir
- [ ] Soru bankası diğer dersler (Türkçe, Fen Bilimleri vb.) — benzer migration
- [ ] Sorular için admin onay akışı web-panel'de test edilecek
- [x] Flutter widget testleri (`mobile-app/test/`) — `maintenance_gate_test.dart` (8 test) ve `character_celebration_test.dart` (5 test) eklendi

### Admin Yönetim Merkezi yenileme (Hupo_Admin_Prototype.html + Plan_ve_Tasarim.pdf)
Plan: `C:\Users\cengi\.claude\plans\imdi-admin-panelini-biraz-temporal-stardust.md`
**Aşama A (görsel yenileme) — kabuk + dashboard yapıldı, ekranlar kısmen:**
- [x] Kabuk: lacivert sidebar (3 grup, altın aktif çizgi, "Yakında" modüller), breadcrumb'lı üst bar, çalışan Ctrl/⌘+K komut paleti (`layout/adminNav.tsx`, `components/yonetim/ui/CommandPalette.tsx`)
- [x] TailAdmin logosu → onaylı Hupo maskotu + "hupolingo" (`components/common/BrandMark.tsx`; sidebar, header, açılış ekranı). Resmi logo dosyası repoda yok — gelince `BrandMark` güncellenecek. Auth sayfaları hâlâ TailAdmin logosu kullanıyor.
- [x] Dashboard: prototip yerleşimi, gerçek veriden türeyen "İlgi bekleyen işler" (`WorkQueue.tsx`); sahte NPS/funnel/kampanya eklenmedi
- [x] Sayfa başlığı kalıbı (eyebrow + H1 + açıklama), tablo başlık stili, Üyeler ekranında yan çekmece profil (`ui/Drawer.tsx`)
- [x] Hata düzeltmesi: Recharts 2.15 + React 19 için `react-is` override'ı; grafiklere `initialDimension` (ilk yüklemede boş görünüyordu)
- [x] `tsc`, `npm run lint` (0 hata) ve `npm run build` geçti
- [ ] **Doğrulanmadı:** oturumlu gerçek admin verisiyle ekranlar (demo modunda alt sayfalar 401 verir); Üyeler profil çekmecesi görsel olarak gerçek veriyle bakılmadı
- [ ] Kalan A işleri: A0 temizlik (şablon demo sayfaları oturumsuz erişilebilir, öğretmen rolü yönlendirme tutarsızlığı, TailAdmin README/bağımlılık kalıntıları), diğer ekranlar için drawer/arama araç çubuğu, tek grafik kütüphanesi kararı, 390 px'de alt sayfaların taranması, hupo-platform-review incelemesi
- [ ] Aşama B–F (CRM derinleştirme, içerik/gelir, segment/kampanya, anket/otomasyon, ekip & yetki): plan dosyasında

### Kullanıcı yapacak (basit adımlar)
- [ ] **Karakter görselleri**: illüstratöre kısa brief — `kurtarilan/KURTARMA_RAPORU.md` sınıf listesini ver, din sembolü yasağını hatırlat
- [ ] **Mağaza URL'leri**: uygulama yayımlandıktan sonra `maintenance_gate.dart` içindeki 2 URL güncellenir
- [ ] **Admin paneli**: `npm run dev` çalıştırıp tarayıcıda admin oturumu açarak kontrol
- [ ] **Flutter analyze**: projeyi `C:\Users\cengi\flutterwork` gibi ASCII yola kopyalayıp `flutter analyze` çalıştır

---

## 8. Alt ajan notu

Bu depoda alt ajan desteği yok; her iş tek ajan tarafından yapılır.
