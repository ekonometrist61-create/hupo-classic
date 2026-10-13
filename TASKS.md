# TASKS — Öğrenci Hazırlık (Hupo) kurtarma projesi
> Ana çalışma dosyası: `MASTER_BRIEF.md`
> Kurallar: `AGENTS.md`
> Temizlik kararları: `docs/arsiv/TEMIZLIK_RAPORU.md`
> Kurtarma kanıtı: `kurtarilan/KURTARMA_RAPORU.md`

Son güncelleme: 13 Ekim 2026

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
- [x] `docs/arsiv/TEMIZLIK_RAPORU.md` — silinebilirler listesi (arşive taşındı)
- [x] `TASKS.md` — bu dosya
- [x] `Task.md` — eski adıyla (ikisi de var, `TASKS.md` esas)

### Temizlik
- [x] `Silinecekler/` karantina klasörü oluşturuldu
- [x] Taşınanlar: `node_modules` (556 MB), `.next` (504 MB), `.idea`, `reports/`,
      `research_notes/`, `proje-okulu-app/`, 7 fazlalık döküm, 2 yanlış adlı dosya
- [x] `supabase/config.toml` ana yere geri alındı
- [x] `Silinecekler/` kalıcı olarak silindi (kullanıcı talimatıyla)

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
- [x] PHASE 0 durum raporu yazıldı → `docs/arsiv/PHASE0_DURUM_RAPORU.md`
- [x] Web public giriş rotası production server'da doğrulandı; admin rotası oturumsuzken girişe yönleniyor
- [x] Web proxy locale-prefix normalizasyonu düzeltildi; anonim claim gerçek oturum sayılmıyor
- [ ] Admin paneli oturum açılmış tarayıcıda doğrulanacak (kullanıcı oturumu gerekir)
- [x] **Soru bankası — Matematik Bölüm 1**: 50 örnek soru migration'a dönüştürüldü (`20261003000001_soru_bankasi_matematik_bolum1.sql`); onay_durumu = 'beklemede' (kaynak doğrulanmamış)
- [x] Proje ASCII yola taşındı (`C:\Dev\hupo`)
- [x] Web TypeScript kontrolü temiz (`tsc --noEmit`)
- [x] Web production build temiz (`next build --webpack`, 51 rota)
- [x] Dart yapısal/import statik denetimi temiz (`tools/dart-statik-denetim.mjs`, 81 dosya)
- [x] `Silinecekler/` klasörü kullanıcı talimatıyla kalıcı olarak silindi
- [x] Flutter analyze temiz (§11.6'da doğrulandı; proje ASCII yolda)

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
- [x] Soru bankası diğer dersler — `20261012000000_soru_bankasi_tum_siniflar.sql` tüm sınıflar için Türkçe, Fen Bilimleri vb. kapsamına aldı (1-8. sınıf, 360 soru)
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
- [x] A0 temizlik: şablon demo sayfaları DEMO_MODE üretimde kapalı (§0 ile düzeltildi); öğretmen yönlendirme RoleGuard+navForRole ile çalışıyor; TailAdmin bağımlılıkları ve README kaldırıldı (§11)
- [ ] Kalan A işleri: diğer ekranlar için drawer/arama araç çubuğu, tek grafik kütüphanesi kararı, 390 px'de alt sayfaların taranması, hupo-platform-review incelemesi (tarayıcı+oturum gerekir)
- [x] Aşama B–F (CRM derinleştirme): Musteri360, PotansiyelAdaylar, SatisHatti, CrmGorevler, EkipAkisi, DestekMasasi, JourneyOtomasyonlari, MesajSablonlari, GrowthAnalitik, AiOneriler — tümü tamamlandı (2026-10-13)

### Kullanıcı yapacak (basit adımlar)
- [ ] **Karakter görselleri**: illüstratöre kısa brief — `kurtarilan/KURTARMA_RAPORU.md` sınıf listesini ver, din sembolü yasağını hatırlat
- [ ] **Mağaza URL'leri**: uygulama yayımlandıktan sonra `maintenance_gate.dart` içindeki 2 URL güncellenir
- [ ] **Admin paneli**: `npm run dev` çalıştırıp tarayıcıda admin oturumu açarak kontrol
- [ ] **Flutter analyze**: projeyi `C:\Users\cengi\flutterwork` gibi ASCII yola kopyalayıp `flutter analyze` çalıştır

---

## 8. Alt ajan notu

Bu depoda alt ajan desteği yok; her iş tek ajan tarafından yapılır.

---

## 9. Veli Paneli — Altyapı ve Geliştirme (2026-10-07)

### Dalga 0 — Kabuk (Tamamlandı)
- [x] Admin layout: `/veli-paneli` path'inde admin kabuğunu atla, yalnızca children render et
- [x] `src/layout/VeliSidebar.tsx`: 12 menü öğeli, 4 gruplu kendi sidebar'ı (admin sidebar'dan bağımsız)
- [x] `(admin)/veli-paneli/layout.tsx`: VeliLayout (VeliSidebar + main area)
- [x] Admin menüleri veli panelinde görünmüyor; sadece veli sidebar menüleri var
- [x] Admin paneli sağlam: tüm admin menüleri mevcut, sidebar çalışıyor
- [x] Demo mode: mock öğrenci verisi (Öğrenci A, Öğrenci B)
- [x] i18n: nav ve navGroups anahtarları veli-paneli.tr.json ve .en.json'a eklendi
- [x] TypeScript: tsc --noEmit çıktı yok (0 hata)

**Mevcut durum:** Genel Bakış "aktif", diğer 11 menü "Yakında" olarak gösteriliyor.

### Dalga 1 — Sayfalar (Tamamlandı, tarayıcı testi yapılmadı)
Mevcut `get_student_dashboard` verisiyle çalışan sayfalar:
- [x] Dersler & Konular (`/veli-paneli/dersler`) — `SubjectsView.tsx`: ders seçici, başarı yüzdesi, konu tablosu
- [x] Yanlışlar & Tekrar (`/veli-paneli/tekrar`) — `ReviewView.tsx`: özet kartları + ReviewTopicsList
- [x] Başarılar (`/veli-paneli/basarilar`) — `AchievementsView.tsx`: XP/seviye/seri kartları + rozet listesi (`get_student_badges` RPC)
- [x] Üyelik & Hesap (`/veli-paneli/uyelik`) — `MembershipView.tsx`: AbonelikKarti + PlanKarti + OdemeGecmisi

### Dalga 2 — Yeni Backend + Sayfalar (2026-10-13)
- [x] Aktivite Akışı sayfası (`/veli-paneli/aktivite`, `ActivityView.tsx`, data.haftalik'ten)
- [x] Deneme Sınavları sayfası (`/veli-paneli/denemeler`, `DenemelerView.tsx`, DenemeKaydiKarti + CocukDenemeGecmisi)
- [x] Hedefler sayfası (`/veli-paneli/hedefler`, `GoalsView.tsx`, get_daily_goal RPC)
- [x] Konu detay RPC → Dersler & Konular tam içerik (`get_child_topic_progress`, migration `20261025000000`; `SubjectsView.tsx` ders seçilince tüm konuları ilerleme çubuğuyla gösterir)

**Dosyalar değiştirildi (Dalga 0):**
- `src/app/[locale]/(admin)/layout.tsx` — veli-paneli path'inde admin kabuğunu atla
- `src/layout/VeliSidebar.tsx` — YENİ: 12 menü öğeli veli sidebar'ı
- `src/app/[locale]/(admin)/veli-paneli/layout.tsx` — YENİ: VeliLayout
- `src/messages/veli-paneli.tr.json` — nav + navGroups + shell anahtarları
- `src/messages/veli-paneli.en.json` — nav + navGroups + shell anahtarları

## 10. Gelir ve Veli Kapısı (2026-10-09)
Kapsam: çocuk kotası ve profil → veli mesajı; landing ve veli paneli plan/satın alma yüzeyi. Kontroller: `flutter analyze` (4 dosya, temiz), `tsc --noEmit` ve `eslint` (web değişen dosyalar, temiz), tarayıcıda landing ve veli paneli kabuğu (konsol hatası yok).
- [x] Çocuk: "Velime mesaj hazırla" alt sayfası (kopyala + veli paneli bağlantısı); kota diyaloğu ve üyelik kartı bu sayfaya bağlı (kod + analyze)
- [x] Çocuk profil "Premium hakkında" satırı artık in-app mesaj sayfasını açar; kırık `hupolingo.com/premium` bağlantısı kaldırıldı
- [x] Landing fiyat bölümü DB'den okunur, veri yoksa fiyat gizlenir; ₺ hardcode ve bozuk para birimi kaldırıldı (kod + render)
- [x] Veli paneli "Ücretli plan" kartı ve "Planı satın al" düğmesi (`payments-checkout` çağrısı) (kod + tsc/eslint)
- [x] `list_active_plans` RPC ve `deneme_gun` alanı — migration `20261025000200`; `admin_upsert_plan` p_deneme_gun parametresi eklendi; `PlanManager.tsx` form ve tablo, `PlanKarti.tsx` veli kartı güncellendi; `tsc` ve SQL sözdizim denetimi temiz
- [ ] Ödeme uçtan uca sandbox testi (veli oturumu → iyzico → callback → abonelik aktif)
- [ ] Veli oturumuyla plan kartı ve satın alma sayfasının kontrolü (test hesabı gerekir)
- [ ] Landing'deki kanıtsız iddialar ("14 Gün İade Garantisi", "%100 Güvenli Ödeme", "%40 tasarruf") için kaynak veya kaldırma kararı
- [ ] Mağaza politikası: çocuk uygulamasındaki harici satın alma bağlantısının Apple/Google kuralları ile uyumu
- [ ] Çocuk akışının gerçek cihazda kontrolü (kota diyaloğu, sayfa, kopyalama)

## 11. Güvenlik ve boyut çalışma paketi (2026-10-10)
Kaynak: 2026-10-09 taraması (güvenlik kontrol listesi, bulgular, boyut ölçümleri). Kararlar 2026-10-10'da kullanıcı tarafından verildi. Durum işaretleri: `[x]` yapıldı ve kontrol edildi, `[ ]` bekliyor, `(ertelendi)` gerekçesiyle sonraya bırakıldı.

### 11.1 Kararlar
| # | Konu | Karar |
|---|---|---|
| 1 | Anahtar ve jeton yenileme | En son, birlikte. Claude yönlendirir, kullanıcı panellerde kendisi yapar |
| 2 | Uzak depo | Özel; başka katkıcı yok |
| 3 | `mobile-app/telefonda-ac/sunucu.dart` | Kaldırıldı. Kaybı: telefonda LAN üzerinden web önizleme kolaylığı. Yerine: `tools/serve.ps1` (127.0.0.1) ve APK |
| 4 | AdMob kodu | Şimdilik kalır; ileride tekrar konuşulacak |
| 5 | `.netlify/`, `ortam/`, tek seferlik `tools/`, kök PNG'ler, eski notlar | Git'ten çıkarıldı, `docs/arsiv/` altına taşındı (`docs/arsiv/` `.gitignore`'da) |
| 6 | Kullanılmayan bağımlılıklar | Kaldırılacak |
| 7 | Migration konsolidasyonu | Şimdilik dışarıda |
| 8 | Uzak Supabase Dashboard (e-posta onayı, MFA, site_url) | İleride; şimdilik kalır |

### 11.2 Aşama 0 — Kimlik bilgileri (EN SON, birlikte)
- [ ] Google API anahtarlarını (Gemini / Stitch, `9b4ee9c` commit'inde `.claude/mcp.json` ve `.claude/settings.json`) iptal et ve yenile
- [ ] GitHub kişisel erişim jetonunu iptal et, yenisini oluştur; `origin` URL'sinden jetonu kaldır, kimlik yöneticisi kullan (`.git/config`)
- [ ] Git geçmişini temizle: `git filter-repo` ile anahtarlı `.claude/` sürümlerini kaldır; force push (her adımda ayrı onay). Anahtar yenilemesinden SONRA yapılır
- [ ] Yeni anahtarları kullanan ortamları kontrol et (Vercel ortam değişkenleri, yerel `.env.local`, MCP yapılandırması). Barındırma Vercel'dir; Netlify kullanılmıyor

### 11.3 Aşama 1 — Güvenlik düzeltmeleri
- [x] `sunucu.dart` kaldırıldı (karar 3). Dizin geçişi ve LAN'a açık dinleme riski ortadan kalktı
- [x] `evaluate_characters` ve `characters_after_change` yetkileri kaldırıldı; yalnızca trigger'dan çağrılıyor (migration `20261019000000_guvenlik_rpc_yetkileri.sql`)
- [x] Admin RPC'leri (9 adet) kontrolü: canlı `proacl` ile doğrulandı, anon/PUBLIC yetkisi **zaten yoktu** (20260920000900). Önceki "anon yetkisi kaldırıldı" iddiası yanlıştı; ilgili blok migration'dan çıkarıldı
- [x] `veli_adayi_olustur` yanıtından `yeni` alanı kaldırıldı (e-posta varlığı sızıntısı kapandı) — migration `20261019000100_veli_adayi_yanit_sadelestirme.sql`, `supabase/tests/veli_adaylari_tests.sql` güncellendi
- [x] `veli_adayi_olustur`: anonim çağrıda mevcut adayın adı ve telefonu artık üzerine yazılmaz (karar 2026-10-10; migration `20261019000100`, test güncellendi). Pazarlama onayı yükseltmesi çalışmaya devam eder
- [x] Prod CSP'den `unsafe-eval` kaldırıldı; `object-src 'none'`, `base-uri 'self'`, `form-action 'self'` eklendi (`web-panel/next.config.ts`)
- [x] CSP `connect-src` PostHog eksikliği giderildi (`eu.i.posthog.com`, `eu-assets.i.posthog.com`, 2026-10-13)
- [x] Landing `dangerouslySetInnerHTML` kullanımları düz metne çevrildi (sabit veri, `&#305;` varlıkları temizlendi)
- [x] `npm audit --omit=dev` yüksek bulguları giderildi (`npm audit fix`, major yükseltme yok)
- [x] Android: `allowBackup="false"`; `bundleRelease` anahtarsız derlenmez, `assembleRelease` için uyarı. **Derlenmedi:** Android SDK doğrulaması ve release anahtarı bu makinede yok; yalnızca kod incelemesi
- [ ] Release anahtarı kurulumu: `key.properties` ve upload keystore bu makinede yok; mağaza yüklemesi öncesi gerekli
- [x] **Canlıya deploy edildi (2026-10-10, kullanıcı onayı):** `20261019000000` … `…000400` (5 migration). Deploy sonrası salt okuma doğrulaması: `evaluate_characters`, `characters_after_change`, `exchange_auth_bridge_token`, `issue_auth_bridge_token` yetkileri yalnızca `service_role`; `veli_adayi_olustur` yeni tanımda; `get_carpim_sifreleri` yetkileri değişmedi (`authenticated`, `service_role`); fonksiyon/tablo/politika sayıları 265 / 102 / 45 (kurtarma no-op). `db:status`: 5 kayıt uzakta, bekleyen yok. Yerelde Docker yok; `supabase test db` çalıştırılmadı
- [x] Auth bridge: `exchange_auth_bridge_token` ve `issue_auth_bridge_token` yetkisi anon/authenticated'dan kapatıldı (migration `20261019000400`; kullanılmadıkları kullanıcı onayıyla doğrulandı). Sonradan kullanıcı onayıyla fonksiyonlar ve `auth_bridge_tokens` tablosu da kaldırıldı (migration `20261021000000`)
- [ ] (ertelendi) `iletisim_izni_iptal_et`: e-posta bağlantısına imzalı token. Mail gönderim tasarımı gerekir
- [ ] (ertelendi) `veli_adayi_olustur` ve veli kodu için IP/captcha limiti. Turnstile anahtarı gerekir
- [ ] (ertelendi) `search_path = public, pg_temp` → `''` standardizasyonu (~17 fonksiyon). Gövdelerde nitelemesiz tablo adı kırabilir; DB testi şart

### 11.4 Aşama 2 — Uzak Supabase ayarları (karar 8, ileride)
- [ ] E-posta onayını aç
- [ ] Admin hesapları için TOTP MFA zorunlu yap
- [ ] `site_url` ve `additional_redirect_urls` değerlerini prod adresine göre ayarla (yerelde `127.0.0.1`)
- [ ] Şifre politikasını güçlendir (en az 10 karakter, karmaşıklık)
- [ ] **Sızdırılmış şifre koruması kapalı** (advisor `auth_leaked_password_protection`): Auth → Passwords ekranından aç

### 11.5 Aşama 3 — Boyut
- [x] `web-panel/.netlify/` git'ten çıkarıldı, `.gitignore`'a eklendi (diskte duruyor)
- [x] **Netlify tamamen kaldırıldı (2026-10-10, kullanıcı kararı):** barındırma Vercel. Silinenler: `web-panel/netlify.toml`, `web-panel/deno.lock` (`deno.json` yok, yetim Netlify edge kalıntısı), `web-panel/.netlify/` (yeniden üretilen çıktı). Kaldırılan yapılandırma satırları: `web-panel/eslint.config.mjs` (`.netlify/**` ignore), `web-panel/.gitignore` ve kök `.gitignore` (`.netlify/`). `.claude/worktrees/` altındaki eski ajan kopyaları bilinçli olarak dokunulmadı
- [x] `ortam/` → `docs/arsiv/ortam/` (başka projeye ait kurulum belgeleri)
- [x] Tek seferlik `tools/` betikleri → `docs/arsiv/tools/` (13 dosya). Kalanlar: `serve.ps1`, `serve-mobile.ps1`, `sql-sozdizim-denetimi.mjs`, `dart-statik-denetim.mjs`, `istemci-rpc-denetimi.ps1`, `soru_bankasi_sql*.mjs`
- [x] Kök PNG'ler (`kontrol-1..3.png`, `şema-gecici.png`) ve eski notlar (`DENETIM_NOTU.md`, `DURUM.md`, `PHASE0_DURUM_RAPORU.md`, `TEMIZLIK_RAPORU.md`, `Task.md`, `cm.txt`) → `docs/arsiv/`
- [x] `mobile-app/assets_arsiv/` → `docs/arsiv/mobile-assets_arsiv/` (pakete girmiyordu)
- [x] Karakter görselleri tekilleştirildi: 81 dosya birebir aynıydı (SHA-256). `web-panel/public/characters/` git'ten çıkarıldı; `web-panel/scripts/sync-karakterler.mjs` prebuild/predev'de mobil kaynaktan kopyalar
- [x] Kullanılmayan web sayfaları ve bileşenleri **arşive taşındı (silinmedi)**: 14 TailAdmin şablon sayfası ve bağlı 73 kaynak dosyası → `docs/arsiv/web-panel-kullanilmayan/`. `proxy.ts` içindeki şablon rota listesi temizlendi. `yonetim/sorular/QuestionHistoryDrawer.tsx` yönetim özelliği olduğu için kaldı
- [x] Referanssız 12 `public/images` alt klasörü (şablon demo görselleri, ~90 dosya) arşive taşındı; `error/` ve `shape/` kullanıldığı için kaldı
- [x] `mobile-app/lib/widgets/gradient_background.dart` (şablon artığı, kullanılmıyordu) arşive taşındı
- Not: bu turdaki git silmeleri (`git rm --cached`) index'te staged durumda; commit atılmadı
- [x] Kullanılmayan npm bağımlılıkları kaldırıldı (`npm uninstall`, doğrulanmış liste)
- [x] Kullanılmayan pub bağımlılıkları kaldırıldı (`pubspec.yaml`, `flutter pub get`)
- [ ] **Karar bekliyor:** `mobile-app/tool/previews/` (38 PNG) golden test referansı; arşivlenirse görsel testler kırılır. Kalsın mı, testlerden çıkarılsın mı?
- [ ] **Karar bekliyor:** `docs/mobil-yeniden-tasarim/referans/` PNG'leri (~4 MB). Git LFS mi, arşiv mi?
- [ ] (ertelendi, karar 7) Soru seed'lerinin (`20261012000000_soru_bankasi_tum_siniflar.sql`, 4.350 satır) migration dışına taşınması: migration geçmişini etkiler
- [ ] (ertelendi, karar 7) Migration konsolidasyonu (261 fonksiyon tanımı / 231 benzersiz)
- [x] `web-panel/banner.png` — dosya artık depoda yok (kaldırıldı)
- [x] `mobile-app/lib/services/push/push_backend_firebase.dart` ve `lib/ads/student_banner_ad.dart` analiz dışına alındı (karar; `analysis_options.yaml`). Silinmedi; Firebase / AdMob kurulunca geri alınacak. AdMob dosyası karar 4 gereği kalır

### 11.6 Aşama 4 — Doğrulama (2026-10-10)
- [x] `web-panel`: `npm run lint` → 0 hata, 13 uyarı (uyarılar önceden vardı). `npm run build` → başarılı, tüm rotalar üretildi. Önce eski `.next` önbelleği silindi (eski tip dosyaları silinen sayfalara bakıyordu; önbellek yeniden üretilebilir)
- [x] `web-panel`: `npm audit --omit=dev` → 0 açık (önce 2 yüksek)
- [x] `mobile-app`: `flutter pub get` → lock'tan 33 bağımlılık düştü (`build_runner` ve kaldırılan paketlerin geçişli bağımlılıkları)
- [x] `mobile-app`: `flutter analyze` → No issues found (önce 21 hata; hepsi paketsiz iki dosyadaydı, bkz. 11.5)
- [x] `mobile-app`: `flutter test` — iki eski test düzeltildi (bkz. 11.7); tam sonuç aşağıda işlenecek
- [ ] `supabase test db --local` (pgTAP) çalıştırılamadı: Docker yok; ayrıca repodaki `supabase/tests` dosyaları pgTAP formatında değil (özel harness)
- [x] `tools/sql-sozdizim-denetimi.mjs` → 80 dosya, 0 hata (beş yeni migration dahil)
- [x] **Kuru test (canlıda `BEGIN … ROLLBACK`, 2026-10-10):** 5 migration hatasız çalıştı; `veli_adaylari` test paketi 12/12 OK; fonksiyon/tablo/politika sayıları canlıyla aynı (265 / 102 / 45); geri alma doğrulandı (ACL ve veri değişmedi). Test senaryo 9'da, tabloyu sahip rolüne geçmeden okuyan bir hata düzeltildi (`authenticated` tabloyu okuyamaz; test kodu hatasıydı)
- [x] `npm run db:preview` (salt okuma, dry-run) → uzak veritabanına gidecek 4 migration listelendi; uzak geçmiş `20261018020000`'e kadar uygulanmış
- [x] Canlı salt okuma denetimi (`supabase db query --linked`, `db advisors --type security`): RLS 102/102 tabloda açık; advisor'da RLS/search_path kaynaklı bulgu yok (bkz. 11.8)
- [x] `tools/istemci-rpc-denetimi.ps1` Türkçe locale i/I hatası düzeltildi (RegexOptions.CultureInvariant, 2026-10-13). 11 yanlış eksik → 0. Tüm RPC'ler şemada tanımlı.
- [ ] Android: `flutter build appbundle` yapılmadı (release anahtarı yok)
- [ ] Yeni migration'lar yerel Postgres'te çalıştırılmadı (Docker yok)

### 11.7 Açık konular
Kararlar bekliyor:
- AdMob kalacak mı; kalırsa gizlilik metni ("reklam ve takip yok") ile tutarlı mı (karar 4)
- `veli_adayi_olustur` üzerine yazma davranışı (11.3)
- PostHog CSP ve analitik açık mı kalacak (11.3)
- `tool/previews` (golden test referansı) ve `docs/mobil-yeniden-tasarim/referans` görselleri (11.5)
- Firebase push arka ucu (`push_backend_firebase.dart`): paketler eklenince analiz dışından geri alınacak (11.5)
- Migration konsolidasyonu ve soru seed'leri (karar 7)
- Uzak Supabase Dashboard ayarları (karar 8)
- ~~Yeni 5 migration'ın canlıya deploy edilmesi~~ — **yapıldı (2026-10-10)**, bkz. 11.3
- ~~Auth bridge~~ — **kaldırıldı (2026-10-10, kullanıcı onayı):** `exchange_auth_bridge_token`, `issue_auth_bridge_token` ve `auth_bridge_tokens` silindi (migration `20261021000000`). Canlıda doğrulandı
- Kolon düzeyi canlı–repo farkı (mevcut tablolar) için tam kontrol (açık teknik borç)

Teknik borç (bu turda bulundu):
- [x] **Canlı–repo uyuşmazlığı (8 istemci RPC'si):** `20261019000200_carpim_sifreleri_rpc_canli_dokum.sql` — gövdeler canlı `pg_get_functiondef` ile birebir, yetkiler canlı `proacl` ile eşleşiyor. Commit `7543fd5` bunları "SQL Editor'den zaten uygulanmış" gerekçesiyle kaldırmıştı. Canlıda henüz çalıştırılmadı
- [x] **Kalan canlı–repo uyuşmazlığı:** canlıda olup repoda olmayan 24 fonksiyon, 7 tablo, 7 politika, 4 indeks, 1 trigger → `20261019000300_canli_sema_eksik_nesneler.sql`. Kaynak katalog sorguları (`db dump` Docker gerektirdiği için kullanılmadı). Kolon düzeyinde, repoda zaten olan tabloların farkı **kontrol edilmedi** (açık)
- [x] `questions_sinifsiz_yedek` (yedek tablo) silindi (kullanıcı kararı: her soru sınıflı olmalı; migration `20261021000000`)
- [x] `_uret_meydan_kod()` anon ve authenticated yetkisi kaldırıldı; yalnızca `create_challenge` (SECURITY DEFINER) kullanıyor (migration `20261021000000`, kullanıcı onayı)
- [x] `veli_cocuk_bagla` hız sınırı sıkılaştırıldı: 5/saat → 3/15dk (kod ömrüyle örtüşür, migration `20261025000100`). Hesap çoğaltma riski e-posta onayı açıldığında kalkar (§11.4)
- [x] İki eski test güncellendi (`membership_test.dart`, `quiz_quota_test.dart`): ürün tasarımı değişmiş (ücretsiz kartta ve kota diyaloğunda "Velime mesaj hazırla" düğmesi, TASKS §10), test beklentileri buna göre düzeltildi; ürün kodu değişmedi. `membership_card.dart` doc yorumu güncellendi
- [ ] `supabase/KURTARMA_DURUMU.md`'deki doğrulama betikleri artık `docs/arsiv/tools/` altında (git dışı)

### 11.8 Canlı güvenlik denetimi (advisor, 2026-10-10, salt okuma)
- Toplam 193 bulgu: 184 × `authenticated_security_definer_function_executable` (WARN), 8 × `anon_security_definer_function_executable` (WARN), 1 × `auth_leaked_password_protection` (WARN)
- Anonim çağrılabilen 8 fonksiyon: `get_app_config`, `get_deneme_ayari`, `get_deneme_sinavi_tarihi`, `list_active_plans`, `get_next_mock_exam_public` (bilinçli herkese açık okuma); `veli_adayi_olustur` (üzerine yazma, karar bekliyor); `iletisim_izni_iptal_et` (imzasız, ertelendi); `exchange_auth_bridge_token` (karar bekliyor)
- 184 authenticated SECURITY DEFINER çağrısının çoğu uygulamanın kullandığı RPC'ler. Her birinde `auth.uid()` / sahiplik kontrolü olup olmadığı tek tek incelenmedi; çocuk ve deneme sınavı RPC'lerinin örneklemi (`register_for_mock_exam`, `set_exam_marketing_consent`, `get_upcoming_mock_exams_for_child`, `veli_cocuk_bagla`) `auth.uid()` + `is_parent_of` / hız sınırı içeriyor
- RLS: 102/102 tabloda açık. `search_path` ve görünüm kaynaklı bulgu yok
- **Deploy sonrası (aynı denetim):** 188 bulgu (önce 193); anon SECURITY DEFINER 7 (önce 8). Kalanlar: `get_app_config`, `get_deneme_ayari`, `get_deneme_sinavi_tarihi`, `get_next_mock_exam_public`, `list_active_plans` (bilinçli okuma uçları); `veli_adayi_olustur` (anonim yazma, rate limit yok); `iletisim_izni_iptal_et` (imzasız, ertelendi)

## 12. Yönetim paneli ve deneme sınavı çalışma paketi (2026-10-10)

Plan: `C:\Users\cengi\.claude\plans\birka-tane-iyile-tirme-yapmam-z-twinkly-castle.md`

### 12.1 Kod yazıldı (deploy edilmedi, tarayıcıda test edilmedi)
- [x] Üyeler & aileler: `ADMIN_SQL` kod bloğu ve `roleNote` kaldırıldı (`UsersManager.tsx`, `yonetim-panel.tr/en.json`)
- [x] Navigasyon: business grubunda Ödemeler / Planlar / Denemeler en üste alındı (`adminNav.tsx`)
- [x] Admin deneme sınavı yönetimi: `/yonetim/deneme-sinavlari` (`MockExamManager.tsx`, `MockExamDetailModal.tsx`, sayfa rotası, nav girişi, `types.ts`, tr/en çeviriler). Sınav oluştur/düzenle, aktif/pasif, sınıf bazlı onaylı soru atama (`admin_list_questions` + `admin_set_mock_exam_questions`), sonuç tablosu (`admin_get_mock_exam_results`)
- [x] `tsc --noEmit` temiz; `npm run lint` 0 hata (13 uyarı, hiçbiri değiştirilen dosyalarda)
- [ ] Gerçek admin oturumuyla tarayıcı testi yapılmadı

### 12.2 Kritik bulgular (deploy öncesi karar gerekli)
- Mobil uygulama (`mobile-app/lib/services/quiz_repository.dart`) hâlâ eski `start_mock_exam` / `submit_mock_exam` RPC'lerini kullanıyor. Bu RPC'ler veli kaydını ve sınav başlangıç saatini KONTROL ETMİYOR: öğrenci sınav saatinden önce soruları alabilir ve kayıtsız girebilir.
- Canlı yeni akış (`20261019000300_canli_sema_eksik_nesneler.sql`): `register_for_mock_exam` (veli + `sinav_pazarlama_izni` onayı), `start_mock_exam_attempt`, `submit_mock_exam_answer`, `deneme_sinavi_cevaplari` (kolon: `dogru`, `cevap_zamani`). İstemciler henüz bu akışı kullanmıyor.
- Oturumda yazılan zamanlama/cevap taslağı canlı akışla çeliştiği için silindi (deploy edilmemişti).
- [x] **DEPLOY EDİLDİ (2026-10-10):** `20261020000000_deneme_sinavi_eski_rpc_sertlestirme.sql` ve `20261020000100_deneme_on_kayit.sql`. `npm run db:preview` dry-run onaylandı; `npm run db:deploy` başarılı.
  - `20261020000000`: eski `start_mock_exam` (saat penceresi, sınıf, tek deneme, süre dolumu) ve `submit_mock_exam` (yalnızca sınavın soruları sayılır, süre + 30 sn tolerans; puanlama YKS'den **yüzde (0-100)**'e değiştirildi — `numeric(5,2)`, canlı `_deneme_sinavi_bitir` ile uyumlu).
  - `20261020000100`: herkese açık ön kayıt tablosu (kanal bazlı izin, append-only izin logu) ve yalnızca service_role'ün çağırdığı `deneme_on_kayit_ekle`.
- Puanlama kararı (2026-10-10): 3-7. sınıf için yüzde (0-100), negatif puan yok. 8. sınıf LGS hazırlığı için ileride **ayrı sınav tipi** eklenecek (bkz. §12.5).
- Captcha: Turnstile/hCaptcha anahtarı geliştirme aşamasında atlandı (domain henüz bağlanmadı). Edge Function `SKIP_CAPTCHA=true` ile geliştirme modunda çalışır; canlıya geçmeden önce anahtar eklenecek.

### 12.3 Açık kararlar
- Eski RPC'ler: KARAR — sertleştirilecek, mobil imza korunacak. Veli kaydı kontrolü, bir kayıt yolu (ön kayıt → veli hesabı → "sınava katıl") çıkana kadar eklenmeyecek; aksi halde hiçbir öğrenci giremez.
- Kayıt modeli: KARAR — herkese açık ve kolay ön kayıt (kayıtsız veliyi müşteriye çevirme kanalı). Captcha (Turnstile/hCaptcha) anahtarı olmadan edge fonksiyonu açılmayacak; anahtar kullanıcıdan istenecek.
- Ön kayıt → hesap eşleştirme (aynı telefon/e-posta ile veli hesabı açıldığında çocuk kaydı bağlanır). Aile tekilleştirmesinin temeli; Faz 4 ile birlikte.
- Veli kaydı (`register_for_mock_exam`) ve canlı yeni akış (`start_mock_exam_attempt`) hiçbir istemci tarafından çağrılmıyor; ön kayıt akışıyla birlikte tasarlanmalı.
- Sonuç ilanı gizliliği (öneri): çocukların adı ve puanı herkese açık sıralamada gösterilmesin (reşit olmayanlar, KVKK). Herkese açık sayfada yalnızca sınıf bazlı toplu istatistik (en az 10 katılımcı), bireysel sıra yalnızca giriş yapmış velinin kendi çocuğunda. Plan 2D'deki "anonimleştirilmiş sıralama" bu nedenle değişecek.
- Konu kırılımı premium (onaylandı). Gelişim izleme (Faz 3) ve aile tekilleştirme (Faz 4) paralel başlayacak.
- Ticari elektronik ileti onayları: KARAR — 3 kanal (e-posta/SMS/telefon) ayrı kutu, tümü başlangıçta boş. Tam metin `/ticari-ileti-izni` sayfasında. Migration `20261020000300` ile 'telefon' kanalı eklendi; trigger 3 kanala güncellendi. Şirket bilgileri (unvan, e-posta, tarih) canlıya almadan önce doldurulacak, hukuk onayı alınacak. İYS 3 iş günü entegrasyonu (backend cron/webhook) ileride eklenecek.
- Puanlama: KARAR — 3-7. sınıf için yüzde (0-100), negatif puan yok. 8. sınıf LGS hazırlığı ileriye bırakıldı (§12.5).

### 12.5 Gelecek: 8. sınıf LGS sınav tipi
8. sınıflar LGS hazırlığı için farklı yapı gerekir: TYT/AYT değil, LGS konu dağılımı. Şimdilik genel sınıf olarak sisteme girer. İleride:
- `deneme_sinavlari`'na `sinav_tipi` (genel / lgs_hazirlik) kolonu ekle
- LGS'ye özgü puan hesaplama (konu ağırlıkları, net hesabı) yeni yardımcı fonksiyonla
- Admin UI'da sinav tipi seçimi

### 12.6 Faz 2A tamamlandı (2026-10-10)
- [x] `get_open_exam_for_registration()` RPC (migration `20261020000200`) — id + ad + baslangic_zamani + siniflar döner; anon ve authenticated erişebilir. Deploy edildi.
- [x] Edge Function `deneme-on-kayit` — CAPTCHA_SECRET ortam değişkeni varsa Turnstile doğrular, yoksa geliştirme modunda atlar. service_role ile `deneme_on_kayit_ekle` çağırır. Deploy edildi (`--no-verify-jwt`).
- [x] `/deneme-sinavi-kayit` sayfası — açık sınav varsa form gösterir, yoksa "yakında" mesajı. Auth gerektirmez; full-width-pages grubunda.
- [x] `DenemeKayitForm.tsx` — veli ad, çocuk ad, sınıf, e-posta, telefon, KVKK zorunlu, e-posta/SMS izin opsiyonel. KVKK_SURUM ve IZIN_SURUM versiyonlu.
- [x] `DenemeExamSection.tsx` CTA `/signup` → `/deneme-sinavi-kayit` değiştirildi.
- [x] Çeviri anahtarları: `landing.denemeKayit.*` (tr + en).
- [x] `tsc --noEmit` temiz. `npm run lint` 0 hata.
- [ ] Tarayıcıda test: açık sınav oluşturup form akışı test edilmedi.
- [ ] CAPTCHA_SECRET Supabase Dashboard → Edge Functions → Environment'a eklenecek (domain bağlandıktan sonra).

### 12.7 Kullanıcıdan bekleyen (Claude hatırlatacak)
- [ ] **CAPTCHA_SECRET:** Domain bağlandıktan sonra Supabase Dashboard → Edge Functions → `deneme-on-kayit` → Environment Variables → `CAPTCHA_SECRET` (Cloudflare Turnstile secret). Şu an geliştirme modunda atlanıyor.
- [ ] **`/ticari-ileti-izni` sayfası:** Yer tutucuları doldurun — şirketin tam ticaret unvanı, iletişim e-postası, son güncelleme tarihi — ve hukuk birimi onayı alın.
- [ ] **İYS 3 iş günü kaydı:** E-posta dışı kanallar (SMS, telefon) İYS'ye henüz bildirilmiyor. Backend webhook/cron gerekiyor (ileride).
- [ ] **8. sınıf LGS sınav tipi:** 8. sınıflar LGS hazırlığı için ayrı `sinav_tipi` (bkz. §12.5) — kullanıcı ilerleyen fazda talep edecek.

### 12.8 Faz 2B tamamlandı (2026-10-10)

#### Veli paneli — deneme kaydı
- [x] `DenemeKaydiKarti.tsx` — `get_upcoming_mock_exams_for_child` + `set_exam_marketing_consent` + `register_for_mock_exam`. Velinin çocuğu için telefon + KVKK onayı ile kayıt. Seçili çocuk değişince otomatik güncellenir.
- [x] `ParentDashboard.tsx` — `ChildScope.render` callback'e `DenemeKaydiKarti` eklendi; seçili öğrencinin `cocukId` ve `cocukAd` aktar.
- [x] Çeviri anahtarları: `veliPaneli.denemeKaydi.*` (tr + en).

#### Öğrenci sınav arayüzü
- [x] `DenemeEkrani.tsx` — `start_mock_exam_attempt` → tek soru / sayfalı navigasyon; anlık `submit_mock_exam_answer`; `finish_mock_exam_attempt`; motivasyonel bitiş ekranı (poza göre 3 ton). Sayaç ≤5 dk sarı, ≤1 dk kırmızı + titreme. Alt şerit: boş/cevaplı/işaretli renkleri. Çift submit koruması (`submitRef`).
- [x] `YaklasanDenemeKarti.tsx` — öğrenci ana sayfasında kayıtlı sınavları listele; sınav başladıysa "Sınava Gir" bağlantısı.
- [x] `/ogrenci/deneme/[examId]` sayfası — `ogrenci` rolü kontrolü, ardından `DenemeEkrani`.
- [x] Öğrenci ana sayfasına `get_my_mock_exam_status()` çağrısı + `YaklasanDenemeKarti` eklendi.
- [x] `npm run build` — exit code 0.
- [ ] Uçtan uca test: admin sınav oluştur → veli çocuğu kaydet → öğrenci sınava gir → sonuç ekranını gör.

#### Notlar
- Doğru cevaplar (`dogru_sik`) istemciye gönderilmiyor — bitiş ekranında da gösterilmiyor. Güvenlik DB seviyesinde.
- `start_mock_exam_attempt` → velinin `register_for_mock_exam` ile çocuğu kaydetmemiş olması hata verir. Hata mesajı ekranda kullanıcıya gösterilir.
- [x] `beforeunload` uyarısı eklendi + localStorage seçim yedekleme (2026-10-13)

### 12.9 Faz 2C — Sonuç İlanı Sayfası (2026-10-10)
- [x] Migration `20261020000400`: `get_exam_public_results(p_exam_id)` — sınıf bazlı istatistik + puan dağılımı + kendi sonucu (anon + auth). `get_exam_topic_breakdown(p_exam_id)` — konu kırılımı (auth + premium). Deploy edildi.
- [x] `/deneme-sonuclari/[examId]` — SSR, full-width-pages grubunda (auth gerekmez). Kendi sonucu (auth ise), sınıf bazlı istatistikler + histogram, konu kırılımı (premium) veya premium gate.
- [x] `KonuKirilimi.tsx` — premium kullanıcıya ders/konu bazlı doğru/yanlış ilerleme çubuğu; free kullanıcıya CTA.
- [x] `DenemeEkrani.tsx` bitiş ekranına "Sonuçları Gör →" + "Ana Sayfaya Dön" butonları.
- [ ] Uçtan uca test: sınav tamamla → `/deneme-sonuclari/[examId]` doğru sonucu gösteriyor mu.

### 12.10 Faz 3 — Gelişim İzleme (2026-10-10)
- [x] Migration `20261020000500`: `get_my_exam_progress()` — tüm sınavlar puan/sıra/yüzdelik trendi (auth). `get_my_topic_trends()` — konu bazlı toplam başarı (auth). Deploy edildi.
- [x] `/ogrenci/gelisim` — SSR öğrenci sayfası; puan trendi SVG çizgisi + sınav listesi, güçlü/zayıf konular, konu ısı haritası.
- [x] Öğrenci ana sayfasına "Gelişimimi Gör" hızlı erişim linki (deneme varsa gösterilir).
- [ ] Uçtan uca test: birden fazla sınav tamamlanmış öğrenciyle trend grafiğini gör.

### 12.11 Faz 4 — Aile Tekilleştirme Backend (2026-10-10)
- [x] Migration `20261020000600`: `identity_merge_candidates` tablosu (RLS açık, service_role erişimi).
  - `admin_detect_identity_duplicates()`: aynı ad+sınıf, farklı veli → aday oluştur (service_role, cron tetikler).
  - `admin_list_merge_candidates()`: admin RPC — bekleyen adayları listele.
  - `admin_resolve_merge_candidate(id, action)`: merged/distinct/ignored kararı kaydet.
  - Deploy edildi.
- [x] Admin sayfası `/yonetim/kimlik-eslestirme` — birleştirme arayüzü (kod + tsc; tarayıcı testi yapılmadı).
- [x] `admin_detect_identity_duplicates` günlük cron — migration `20261020000800` (pg_cron, her gün 00:30 UTC). Job satırı SQL ile ayrıca doğrulanmadı.
- [ ] Gerçek profil birleştirme mantığı (deneme sonuçlarını tek profilde topla) — gelecek fazda.

### 12.12 Faz 5A / 5B / 5D (2026-10-10)
- [x] Faz 5A — Migration `20261020000700`: `deneme_sinavi_denemeleri.started_at` + `supheli`. `start_mock_exam_attempt` başlangıcı yazar; `_deneme_sinavi_bitir` 30 sn altındaki tamamlamayı `supheli = true` işaretler (engellemez).
- [x] Faz 5B — Aynı migration: ilk bitişte `olay_kutusu` → `deneme_sonuc_bildirimi` (payload: exam_id, student_id, puan, sira, supheli; PII yok). Gönderen worker henüz yok.
- [x] Faz 5D — `PaylasKarti.tsx`: sonuç sayfasında canvas ile 1080×1080 PNG (ad yok; puan, sınıf sırası, yüzdelik). Web Share, yoksa indirme. tsc + eslint temiz; tarayıcıda görsel kontrolü yapılmadı.

### 12.4 Sıradaki
- [ ] Uçtan uca testler (12.8 / 12.9 / 12.10) — EN SON yapılacak. Test öğrenci + veli hesabı ve tarayıcı gerekir.
- [x] Faz 4 gerçek profil birleştirme — migration `20261020001000`. Ana hesap = daha önce oluşturulan hesap. Deneme ve katılım kayıtları ana hesaba taşınır; aynı sınavda iki kayıt varsa tamamlanmış/yüksek puanlı olan kalır. Her birleştirme `identity_merge_log`'a yazılır. XP/rozet/görev/karakter ve veli onay (consents) kayıtları kaynak hesapta kalır (ayrı karar). Birleştirilen öğrenci hesabı sınava giremez; veli kaydı ana hesaba yapılır. Test verisinde deneme gerekir.
- [x] `supheli` bayrağı admin sonuç listesinde gösteriliyor (migration `20261024000000`, `MockExamDetailModal` ⚠ ikonu, çeviri eklendi)
- [x] Bitirilmemiş denemeler: `deneme_sure_dolanlari_kapat()` her dakika (pg_cron) süresi dolmuş bitmemiş denemeleri kapatır; teslim türü `otomatik`, bildirim tetiklenir. Kapanış süre sonunda olur, anında değil: öğrenci süre içinde de sınava geri dönemez (`start` tekrar girişi reddeder), bu yüzden süre sonu tek kesin zamandır. Veli panelinde (`CocukDenemeGecmisi`) ve öğrenci gelişim sayfasında görünür. Migration `20261020000900`.
- [x] Süre dolan cevap yolu düzeltildi: `submit_mock_exam_answer` artık bitirip `return` eder (raise yok), bitiş kalıcı. Migration `20261020000900`.
- [x] `deneme_sonuc_bildirimi` worker'ı — Edge Function `olay-kutusu-gonder` (`--no-verify-jwt`) deploy edildi; pg_cron her 5 dk pg_net ile çağırır. Sağlayıcı: Resend (karar onayı bekliyor). Veritabanı tarafı: `olay_kutusu_talep_et` (lease + deneme sayacı, 5 denemede ölü kayıt), `olay_kutusu_sonuc_yaz` (üssel geri çekilme), `deneme_bildirim_alici` (service_role). Migration `20261020001100`. **Gönderimi açmak için:** `supabase secrets set OLAY_WORKER_SECRET=… RESEND_API_KEY=… OLAY_MAIL_FROM="Hupolingo <bildirim@alan.adi>" PUBLIC_SITE_URL=…`; Supabase Vault'a aynı değerle `olay_worker_secret` adında secret ekle. Gönderici alan adı doğrulanmadan e-posta gitmez. Gizli metin repoda yok.
- [ ] `/ticari-ileti-izni` şirket unvanı, iletişim e-postası, tarih + hukuk onayı — KARAR: en son yapılacak, Google Play canlıya çıkmadan önce.
- [ ] CAPTCHA_SECRET — domain bağlandıktan sonra Edge Function ortamına.
- [ ] İYS 3 iş günü kaydı — KARAR: en sondan bir önce; bekleme listesinde. İYS entegrasyon bilgileri gerekir.
- [ ] 8. sınıf LGS sınav tipi (§12.5).

## 13-ek. Growth CRM entegrasyonu (2026-10-08)
Kaynak: `Hupolingo_Growth_CRM_v1_FINAL_CodePack.zip`. Mevcut Supabase'e `growth_*` prefix ile additive layer.
Dokümanlar: `docs/growth-crm/IMPLEMENTATION_PLAN.md`, `docs/growth-crm/REUSE_EXTEND_CREATE_MAP.md`.

### Durum (2026-10-13)
- [x] Migration'lar: `20261014000000` (core tablolar), `000100` (RPC'ler), `000200` (pazarlama), `000300` (analitik) — tümü uzakta uygulanmış
- [x] Admin sayfaları: müşteri-360, müşteri-360/[id], potansiyel-adaylar, potansiyel-adaylar/[id], crm-gorevler, ekip-akisi, satis-hatti, destek-masasi, journey-otomasyonlari, mesaj-sablonlari, growth-analitik, ai-oneriler — `tsc` temiz
- [ ] Gerçek admin oturumuyla tarayıcı testi yapılmadı
- [x] Faz B–F derinleştirme: tüm CRM manager bileşenleri yazıldı (`tsc` temiz) — Müşteri 360, Potansiyel Adaylar, Satış Hattı, CRM Görevleri, Ekip Akışı, Destek Masası, Journey, Mesaj Şablonları, Growth Analitik, AI Öneriler
- [x] Veli adayları CRM: `ErkenErisimSection` landing'e eklendi; `veli_adayi_olustur` RPC direkt çağrılıyor (kaynak: `landing_erken_erisim`). Captcha CAPTCHA_SECRET eklenince eklenecek (bkz. §12.7)

### 13-ek.2 Müşteri 360 veri toplama katmanı (2026-10-13)
Plan: `docs/growth-crm/VERI_TOPLAMA_PLANI.md`. Sorun: 360 ekranı hazırdı ama `growth_households` yalnızca elle doluyordu.
- [x] Migration yazıldı: `20261027000000_musteri_360_veri_toplama.sql` — profiles/subscriptions/payments/veli_adaylari/deneme ön kaydı → tek kart (e-posta ile), tetikleyiciler, geri doldurma, `growth_household_izinleri`, liste filtreleri (kaynak, kanal izni), `admin_musteri_360_ozet`
- [x] PGlite doğrulaması: `cd supabase/tests/musteri_360; npm install; node kos.mjs` — 11/11 senaryo geçti (taklit şema üzerinde; gerçek şemanın tamamı değil, uzak DB'de çalıştırılmadı)
- [x] Panel: liste filtreleri (kaynak, kanal izni) + özet kartları yazıldı, `tsc --noEmit` temiz. Tarayıcıda gerçek admin oturumuyla bakılmadı. "Bilinmiyor" kaynak seçeneği arayüzde henüz yok (RPC destekliyor)
- [x] **Uzak DB'ye uygulandı** (2026-10-13): `20261027000000` tek transaction içinde `supabase db query --linked -f` ile çalıştırıldı, ardından `migration repair --status applied`. `db:deploy` KULLANILMADI (aynı anda duyuru migrasyonu hazırlanıyordu; o dosyaya dokunulmadı). Doğrulama: 1 veli → 1 kart, 2 öğrenci (1'i veliye bağlı → 1 kişi kaydı; bağlı olmayan öğrenciye kart açılmaz), abonelik/ödeme/aday/ön kayıt yok, 5 tetikleyici ve `admin_musteri_360_ozet` mevcut. Duyuru migrasyonu (`20261026000000`) ayrı çalışmada uzağa uygulandı (bkz. §14.3).
- [x] V2 (web) uzakta uygulandı (2026-10-13, `db:preview` → `db:deploy`; yalnızca `20261028000000` bekliyordu; fonksiyonlar ve anon yetkisi doğrulandı, davranış testi canlıda yapılmadı): `20261028000000_growth_web_olaylari.sql` (`growth_web_olay_kaydet`, `growth_web_kimlik_bagla`; anonim, beyaz liste, 15 dk pencere), landing'de ilk temas UTM ve form sonrası izleme (`erkenErisimIzleme.ts`). PGlite 15/15 geçti. Tarayıcıda ve uzak DB'de doğrulanmadı (anon anahtar sorunu). Açık risk: iki anonim RPC'de hız sınırı yok (`veli_adayi_olustur` ile aynı açık)
- [ ] V2 (Flutter / /ogrenci): uygulamadan olay yakalama. Kapsam dışı bu turda
- [ ] V3: kitle dışa aktarımı (yalnızca `granted`), kampanya/bildirim bağlama
- [ ] V4: reklam kitlesi (hash'li e-posta, yalnızca açık izinli)
Kararlar: izin tahmin edilmez (kutu işaretsiz = `denied`; `veli_adaylari.pazarlama_izni=false` = kayıt yok); senkron boş alanı doldurur, admin değerini ezmez; çocuk verisi yalnızca ad + sınıf; ücretsiz (0 kuruş) abonelik = `trial`.

## 13. Kelime Evreni entegrasyonu (2026-10-10, branch `feature/kelime-evreni`)
Kaynak: `HUPOLINGO_Kelime_Evreni_Flutter_Claude_Paketi.zip` (v0.1 başlangıç kodu; ürünün kendisi değil). Eş anlamlı / zıt anlamlı / eş sesli kelime oyunları Öğren sekmesine bağlanır.

### 13.1 Kararlar
| # | Konu | Karar |
|---|---|---|
| K1 | Kullanıcı sistemi | Yeni sistem YOK. `profiles` + `is_parent_of()` (veli) + `is_admin()` (yönetici). Paketin `word_parent_links` / `word_admin_members` adaptörleri kaldırıldı |
| K2 | Soru bankası | `questions` KULLANILMAZ. Kelime soruları ayrı içerik türü (`kelime_sorulari`); anlam ve ilişki envanteri ayrı (`kelime_anlamlari`, `kelime_iliskileri`). Gerekçe: `questions` tüm mevcut quiz/tekrar/bildirim akışını etkiler; yayına alınan kelime sorularının Türkçe quizlere sızması istenmedi |
| K3 | XP | Tek yazım yolu ward_xp_and_streak(). XP, submit_answer ile aynı kuralla: yalnızca doğru, ipucusuz ve tekrar zamanı gelmiş cevapta; tutar sorunun zorluğuna göre 10/20/30 (kelime_sorulari.zorluk). İpucu mevcut sistemde olmayan bir yardımdır, ipucuyla doğru cevap XP vermez. Paketin 10/5 puanları kullanılmadı |
| K4 | Ustalık | Yalnızca `taninma` becerisi yazılır; seviye en fazla 3. Seçenekle tanıma "tam ustalık" sayılmaz. Yanlış → 0 (1 gün). İpucu ile doğru → seviye değişmez (1 gün). Doğru → +1 (1 / 3 / 7 gün) |
| K5 | Yayın onayı | Dört göz: yazan ≠ yayınlayan ≠ ilişki kuran ≠ ilişki onaylayan. DB CHECK + RPC kontrolü. **Tek yönetici olan kurulumda yayın yapılamaz**; gevşetilecekse karar gerekir |
| K6 | Doğru şık gizliliği | `kelime_sorulari` ve `kelime_*` tablolarında `authenticated` tablo yetkisi YOK. Öğrenci yalnızca `kelime_oyun_getir` (doğru şık ve açıklama yok) ve `kelime_cevap_gonder` (cevap sonrası açıklama) RPC'lerini kullanır |
| K7 | Veli görünürlüğü | Yalnızca toplu özet (`kelime_veli_ozeti`): oranlar, zorlanılan kelimeler, tekrar sayısı, öneri kodları. Cevap listesi / soru kimliği yok |
| K8 | Sınıf / kazanım | İçerikte `sinif` (1–12, `profiles.sinif` ile eşleşir) ve serbest `kazanim_kodu` metni. Resmi kazanım tablosu YOK (kaynak yok) |
| K9 | İlişki yönü | İlişkiler çift yönlü; (A,B) ve (B,A) tek kayıt (benzersiz indeks) |
| K10 | Hız sınırı | Kullanıcı başına dakikada 30 deneme (`RATE_LIMIT`) |
| K11 | Demo içerik | `supabase/seed/example_draft.sql` migration'a alınmadı; üretimde demo içerik yok |

### 13.2 Yapıldı (doğrulandı)
- [x] `supabase/migrations/20261022000000_kelime_evreni.sql` — 6 tablo, RLS, 15 RPC (öğrenci 5, veli 1, yönetim 9) + 2 yardımcı fonksiyon; tüm RPC'lerde `revoke` (public/anon) + `grant` (authenticated)
- [x] `supabase/tests/kelime_evreni_tests.sql` — 40 senaryo (RLS, yetki, idempotency, XP, ustalık, hız sınırı, dört göz, onay akışı, veli gizliliği)
- [x] Yerel SQL doğrulaması: PGlite (Postgres WASM) + Supabase bağımlılık taklitleri (`supabase/tests/kelime_evreni/`). **40/40 geçti.** Bilinçli açık mutasyonları (doğru şık sızıntısı, anon metrik yetkisi) testler yakaladı
- [x] Bulunan ve düzeltilen hatalar: `text[] ||` dizi literali, `auth.uid()` dönüş tipi, `smallint`/`integer` parametre uyumsuzluğu, `OR` içinde hata üreten kontrol
- [ ] Docker'da `supabase db reset` + `supabase test db` — Docker yok; PGlite ile yerine geçmez (gerçek `award_xp_and_streak`, `log_admin_action` yerine taklit kullanıldı)
- [x] **Uzak Supabase'e uygulandı.** `db:status` tüm Kelime migration'larını (20261022000000–000002, 20261023000000) uzakta senkron gösteriyor (2026-10-13 doğrulaması)
- [x] Flutter: model, repository, akış denetleyicisi (`kelime_oyun_akisi.dart`), ana ekran, oyun ekranı, Öğren kartı. 42 Kelime testi geçiyor; `flutter analyze` proje genelinde temiz
- [x] Web: `/yonetim/kelime-evreni` (metrikler, taslak/inceleme/yayın/arşiv, sözlük ve ilişki onayı), veli Genel Bakış kartı. `tsc` ve ESLint temiz
- [x] Tam Flutter test takımı: `splash_gate_test.dart` 3 başarısız test düzeltildi (Riverpod ProviderScope ve yeni splash sözleşmesine uyarlandı, commit `6146ed2`). Tüm testler geçiyor
- [ ] Tarayıcı, cihaz ve ekran okuyucu kontrolü (oturum ve cihaz gerekir): 390 px / masaüstü, hareket azaltma, ses ve titreşim
- [x] Ortak `AnswerOption` kontrastı düzeltildi: `mintDark` (#237A4B, 4,86:1) ve `coralDark` (#A64B24, 5,30:1) kullanılıyor; Quiz ve Kelime ekranları aynı widget'ı paylaşır
- [ ] İçerik: ilk onaylı paket (dil uzmanı incelemesi gerekir; demo içerik yayınlanmaz)
- [ ] Ödül/rozet entegrasyonu: XP ledger bağlı; rozet kuralı ayrıca tasarlanacak
- [ ] Ana ekranda tek birincil eylem ve özet ekranında tekrar çalışma eylemi (tasarım kararı)

### 13.3 Bilinen sınırlar
- Eş zamanlılık: advisory lock ve benzersiz anahtar kuralı SQL'de tanımlı; gerçek yük/yarış testi yapılmadı (PGlite tek oturum)
- `kelime_oyun_getir` öncelik sorgusu her çağrıda deneme sayısını hesaplar; içerik büyürse indeks/materialize gerekir
- Ustalık (taninma dışı beceriler) henüz yazılmıyor; kalıcı ustalık raporu bu yüzden boş kalır
- Branch hijyeni: `feature/kelime-evreni` üzerinde Kelime dışı dört commit var (`8bd52c0`, `11a666e`, `71ff03d`, `78f034d`). Bunlara dokunulmadı. Kelime işini PR'a almadan önce ayrılmalı

## 14. Web sitesi duyuru şeridi (2026-10-13)

Admin'den yönetilebilir ana sayfa duyurusu: başlık, metin (en fazla 500 karakter), yayında/pasif ve isteğe bağlı bitiş tarihi (Türkiye saati).

### 14.1 Kararlar
- Tek tablo, çoklu duyuru: en yeni aktif ve süresi dolmamış duyuru ana sayfada gösterilir. (karar)
- Tabloya doğrudan erişim yok; yalnızca RPC'ler (`get_aktif_duyuru`, `admin_list_duyurular`, `admin_save_duyuru`). (karar)
- Silme yok; duyuru pasife alınarak kapatılır. (karar, kayıt kaybını önlemek için)
- Süresi dolan duyuru otomatik pasife dönmez; yalnızca gösterilmez. Listede "Süresi doldu" olarak görünür.
- Hata durumunda (migration yoksa dahil) ana sayfa şerit göstermeden çalışmaya devam eder.

### 14.2 Yapıldı (kod)
- [x] Migration `supabase/migrations/20261026000000_site_duyurulari.sql`: tablo, RLS (politikasız), 3 RPC, anon/authenticated yetkileri
- [x] SQL testi `supabase/tests/duyurular_tests.sql`: PGlite üzerinde 13/13 senaryo geçti (stub + require_admin kopyası ile; gerçek Supabase'de değil)
- [x] Admin sayfası `/yonetim/duyurular` (menü: Büyüme & iletişim) — oluştur, düzenle, yayına al / kaldır
- [x] Ana sayfa şeridi `DuyuruSeridi` (sunucu bileşeni), `LandingPage` içinde header'ın altında
- [x] Türkiye saati yardımcıları `components/yonetim/turkiyeTarih.ts` altına taşındı; ayarlar sayfası bunu kullanıyor
- [x] Çeviriler: `yonetim-panel.{tr,en}.json` (menü/sayfa açıklaması), `{tr,en}.json` → `landing.duyuruSeridi`

### 14.3 Kullanıcı yapacak
- [x] Uzak veritabanına uygulandı (2026-10-13): `npx supabase db push --include-all`; dry-run yalnızca `20261026000000_site_duyurulari.sql` listeledi. `--include-all` gerekti çünkü uzakta `20261027000000` (Müşteri 360, ayrı çalışma) zaten uygulanmış; yeni dosya ondan bağımsız.
- [x] Uzak salt-okunur doğrulama: 3 fonksiyon var, `duyurular` 0 satır, anon `get_aktif_duyuru` çalıştırabiliyor, anon `admin_list_duyurular` / `admin_save_duyuru` ve tablo okuma yetkisi yok.
- [ ] **Anon anahtar uyarısı:** `web-panel/.env.local` içindeki `NEXT_PUBLIC_SUPABASE_ANON_KEY` değeri uzak projede 401 "Invalid API key" döndürüyor. Anahtar döndürülmüş ya da yanlış kopyalanmış olabilir. Bu, ana sayfadaki duyuru şeridini ve `get_deneme_sinavi_tarihi` geri sayımını sessizce etkiler (geri sayım sabit yedek tarihe düşer). Vercel ortam değişkenlerinde anahtarı kontrol et.
- [ ] Deploy sonrası: admin'de bir duyuru oluştur, ana sayfada göründüğünü ve bitiş tarihi geçince kalktığını doğrula (anahtar sorunu çözülmeden şerit görünmez).

### 14.4 Doğrulanmadı
- [x] `npx tsc --noEmit` temiz; `npm run lint` 0 hata (16 uyarı, hiçbiri yeni dosyalarda); `npm run build` başarılı, `/yonetim/duyurular` rotası derlendi (2026-10-13)
- [ ] Tarayıcıda ana sayfa (masaüstü + 390 px) ve admin formu görsel kontrolü (dev sunucu + Supabase bağlantısı gerekir; yapılmadı)

## 15. Duyuru mecraları: web sitesi, web app, mobil, veli paneli (plan, 2026-10-13)

Hedef: admin duyuruyu hangi mecralarda yayınlayacağını seçsin; her mecra yalnız kendine seçilen duyuruyu görsün. Mekanizma, anket yayın yüzeyleriyle (`20261029000000_anket_yuzeyler.sql`) birebir aynı kurulur; yeni bir desen icat edilmez.

### 15.1 Mevcut durum
- Tablo `duyurular` yalnızca web sitesi için; `get_aktif_duyuru()` parametresiz, en yeni aktif duyuruyu döndürür.
- Yalnız `web-panel/.../landing/sections/DuyuruSeridi.tsx` tüketiyor. Flutter (`mobile-app/lib`) ve veli paneli (`web-panel/.../(admin)/veli-paneli/layout.tsx`) duyuru okumuyor.
- Anket tarafında hazır örnek var: `anketler.yuzeyler text[]` (`mobil` | `web_app` | `web_sitesi` | `veli_paneli`), `SurveySurface` tipi (`yonetim/merkez/types.ts`), mobilde `kIsWeb ? 'web_app' : 'mobil'` (`survey_repository.dart`), veli panelinde `AnketIstemi`.

### 15.2 Kararlar (önerilen, onay bekliyor)
- Yüzey kümesi aynen anketlerle aynı: `mobil`, `web_app`, `web_sitesi`, `veli_paneli`. Tek sözlük, iki ayrı liste yok.
- Bir duyuru birden çok yüzeyi seçebilir (`yuzeyler text[]`, en az 1). Varsayılan: `web_sitesi` (bugünkü davranışla uyumlu).
- Her yüzey, kendi yüzeyi için en yeni aktif ve süresi dolmamış duyuruyu alır. Yüzeyler arası "tek duyuru" kısıtı yok.
- Tablo erişimi değişmez: yalnız RPC. Silme yok; pasife alma.
- Hata/migration yoksa her yüzey bozulmadan boş döner (şerit/kart çizilmez).

### 15.3 Adımlar
1. [x] (uzak DB'ye uygulandı 2026-10-13; `get_aktif_duyuru(p_yuzey default 'web_sitesi')` — parametresiz eski çağrı da çalışır; canlıda anon çağrıyla doğrulandı) Migration `20261030000000_duyuru_yuzeyler.sql` (yeni dosya, `20261026000000` değiştirilmez): `duyurular.yuzeyler` kolonu + check; `get_aktif_duyuru(p_yuzey text default 'web_sitesi')` yeni imza; `admin_list_duyurular` ve `admin_save_duyuru` (`p_yuzeyler text[] default null`) güncellenir. Eski parametresiz fonksiyon kaldırılır veya geriye uyumlu tutulur (karar: kaldır, tek tüketici var).
2. [x] (PGlite tam zincir, `duyurular_tests.sql` 19/19; gerçek Supabase'te çalıştırılmadı) SQL testi: her yüzey için filtreleme, çok yüzeyli duyuru, yüzeysiz kayıt reddi, yüzey dışı değer reddi.
3. [x] (kod: tsc/eslint temiz; görsel kontrol aşağıda) Admin formu (`DuyuruManager.tsx`): yüzey onay kutuları (anket formundakiyle aynı bileşen/etiketler), en az bir yüzey zorunlu. Liste satırında yüzey rozetleri.
4. [x] Web sitesi: `DuyuruSeridi` `get_aktif_duyuru('web_sitesi')` çağırır (davranış değişmez).
5. [x] (kod: `flutter analyze` temiz, tüm testler geçti; cihaz/tarayıcı görsel kontrolü YAPILMADI; renk widget'a yerel sabit, `AppColors`'a token eklenmesi önerilir) Flutter (`mobile-app/lib`): `DuyuruRepository` + ana ekranda kart/şerit. Yüzey `kIsWeb ? 'web_app' : 'mobil'`. Kapatılabilir olmalı; kapatma durumu yerelde tutulur (duyuru id'sine göre), sunucuya yazılmaz. Çocuk ekranında gösterim dili hupo-ux-writing ile kontrol edilir.
6. [x] (kod; `DuyuruBandi`, kapatılabilir; görsel kontrol aşağıda) Veli paneli: `(admin)/veli-paneli/layout.tsx` içine `get_aktif_duyuru('veli_paneli')` ile küçük şerit. Veli'ye yönelik metin, ödeme/satın alma çağrısı içermez.
7. [~] Uzak DB: `20261029000000` (anket) ve `20261030000000` (duyuru) uygulandı (2026-10-13, düz `db push`, önce dry-run). Vercel ve Flutter dağıtımı YAPILMADI, ayrı onay. Eski not: uzak DB'ye uygulama ayrı onayla (`db push --include-all` kullanılmadan önce dry-run). Vercel ve Flutter dağıtımı ayrı onay.
8. [ ] TASKS §14.3 anon anahtar uyarısı çözülmeden 5 ve 6 canlıda doğrulanamaz; Flutter ve veli paneli de aynı anahtarı kullanır.

### 15.4 Riskler ve notlar
- Anon anahtar 401 sorunu üç mecrayı birden etkiler; önce çözülmeli.
- Flutter Web ile mobil aynı kod tabanı; `web_app` ile `mobil` ayrımı yalnız `kIsWeb` ile. Bu ayrım anket için de böyle, tutarlılık için korunur.
- Flutter değişikliği mobil yayın (Play/App Store) gerektirir; web tarafı Vercel/Flutter Web deploy'uyla gider. Mobil sürüm yayınlanmadan `mobil` yüzeyine duyuru gönderilmemeli (eski sürüm RPC'yi çağırmaz, zararsız ama görünmez).
- Hupolingo UI/UX işi olduğu için CLAUDE.md gereği adımlar 5 ve 6 öncesi `hupo-design-growth-director` agent'ı ile gözden geçirilir.
- **Açık bulgu (anket/duyuru dışı, çözülmedi):** PGlite tam zincir testinde `public.admin_kampanya_listele()` (`20261007000020`, 0 argüman) ile `admin_kampanya_listele(p_status, p_limit, p_offset)` (`20261014000200`, hepsi varsayılanlı) birlikte var; argümansız çağrı "42725 is not unique" veriyor. `CampaignsManager.tsx:51` argümansız çağırıyor; canlıda PostgREST'in aynı belirsizliği (PGRST203) verip vermediği doğrulanmadı. Eski 0-argüman sürümünü DROP eden yeni migration gerekir. `yonetim_merkezi_tests.sql` bu yüzden ancak çakışan overload koşuya özel kaldırılınca 30/30 geçti.
- **Açık bulgu:** `20260927000010` (COMMENT içinde `||`) ve `20260927000019` (question_reports sırası) boş bir veritabanında zinciri bozar; canlıda uygulanmış olduğu için ancak sıfırdan kurulumda sorun çıkar.
- **Anket/duyuru ortak:** yüzey sözlüğü tek (`SurveySurface`, `SurfacePicker`); mobil `kIsWeb ? 'web_app' : 'mobil'` (`yayin_yuzeyi.dart`).
