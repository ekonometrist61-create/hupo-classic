# Mobil yeniden tasarım — ChatGPT "Mobile Flutter MVP v1" paketi: değerlendirme ve iş planı

Kaynak paket: `Hupolingo_Mobile_Flutter_MVP_CodePack_v1.zip` (48 Dart dosyası, 24 route, mock veri, taslak SQL). Paket bir **UI kabuğu + tasarım dili**dir; backend'i mock'tur ve `flutter analyze/test` çalıştırılmamıştır.

## 1. Kararlar (kullanıcı onaylı, 2026-10-07)
1. **Ortak dil:** web, admin ve mobil aynı token setini paylaşır: Learning Teal ana eylem, Deep Navy metin ve "oyun" yüzeyleri, Cloud Cream öğrenme yüzeyi, Hupo Gold **kıt** (maskot/XP/ödül/rarity). Nunito. Paketin mavi CTA/Inter paleti benimsenmedi.
2. **Veri modeli:** canlı Supabase şeması korunur; UI mevcut RPC'lere bağlanır. Paketin `001_initial_schema.sql` / `002_seed_catalog.sql` dosyaları **uygulanmaz** (`question_options.is_correct` cevap anahtarını istemciye açar; `students/attempts` modeli canlı auth, ödeme, veli onayı ve RLS ile çakışır). Eksik özellikler için ayrı, RLS'li, `revoke/grant`'lı yeni migration'lar yazılır.
3. Paket kodu **kopyalanmaz**; ekran yerleşimi, bilgi hiyerarşisi ve kurallar uygulanır. Mevcut Riverpod/repository/Navigator yapısı korunur; yeni kabuk (5 sekme) üstüne kurulur.

## 2. Pakette alınanlar / alınmayanlar
| Alınır | Alınmaz / uyarlanır |
|---|---|
| 5 sekmeli kabuk: Ana Sayfa · Öğren · Arena · Koleksiyon · Profil | `go_router` (şimdilik Navigator; derin bağlantı gerekince ayrı iş) |
| Öğrenme döngüsü: soru → yanlış → açıklama → tekrar dene → recovery XP → ders sonucu | Mock repository'ler, sabit `currentStudent`, mock XP |
| Ay Ligi, Arkadaşa Meydan Oku (VS), görevler, rozetler, seri, deneme sınavı, kaydedilenler | `students/attempts/question_options` şeması; `HupoPose` 11 opak PNG (bizde 21+ şeffaf WebP var) |
| Maturity (junior/core/senior) yoğunluk sistemi | Paket karakter ID'leri `class1-1…` (canlıda `character_definitions.kod` canonical) |
| Hupo kullanım kuralları (anlamlı anlarda, %10–20), gold scarcity, kırmızıya boğmayan yanlış cevap | Mavi `#2376E5` CTA, Inter/Poppins, `#2BB7A9` teal (web'de `#147D8A`) |
| UX copy kılavuzu (yanlış/lig/seri/veli dili) | Çocuk ekranından satın alma (zaten yasak) |

## 3. Ortak token seti (3 yüzey)
| Rol | Değer | Web/admin karşılığı | Mobil (`AppColors`) |
|---|---|---|---|
| Ana eylem / ilerleme | Learning Teal `#147D8A` | `brand-500` | `primary` |
| Metin, oyun yüzeyi | Deep Navy `#17324D` (+ koyu `#0B1B2E` silüet/arena) | `navy` | `ink` + yeni `navyDeep` |
| Öğrenme zemini | Cloud Cream `#FFF9ED` | `cream` | `background` |
| Ödül/maskot/XP | Hupo Gold `#F5C842` (ekranın ≤%10'u) | `gold-500` | `sun` |
| Doğru | `#237A4B` / `#2E9E62` | `success` | `mint*` |
| Yanlış / tekrar | amber `#D96A28` (kırmızı X yok) | `retry` | `coral*` |
| Rarity | Common gri · Rare mavi · Epic mor · Legendary altın · Mythic ateş-gradyan | `premium` + yeni rarity tokenları | yeni `RarityColors` |
Yazı tipi: Nunito (mobil zaten, landing'de aynı). Admin paneli Outfit kullanıyor; hizalama admin oturumunun kararıdır (öneri: Nunito'ya geçiş, ayrı iş).

## 4. Ekran eşlemesi (paket → bizde ne var → yapılacak)
| Paket ekranı | Mevcut | Bağlanacağı veri | İş |
|---|---|---|---|
| Splash / onboarding / hedef / günlük hedef | `splash_screen`, `grade_picker_screen`, `settings` | `set_my_grade`, `set_daily_goal` | Yeniden stil + kısa onboarding (3 adım) |
| Ana Sayfa (hedef → kaldığın yer → odak) | `home_screen` | `get_daily_goal`, `statsProvider`, aktif karakter | Yerleşimi 3 odağa indir, yeni kartlar |
| Öğren (ders/konu haritası) | ders listesi `home` içinde | `questions.ders/konu` (`fetchSubjects` + konu kırılımı) | **Yeni** Öğren sekmesi (ders → konu), konu ilerlemesi için RPC genişletme |
| Soru / doğru / yanlış-recovery / ipucu | `quiz_screen`, `result_sheet` | `submit_answer` (+requestId) | Recovery akışı: açıklama → benzer soru → recovery XP (sunucu kuralı gerekir) |
| Ders sonucu | `result_screen` | oturum sonucu | Yeniden stil + "kalan XP" |
| Yanlışlarım / akıllı tekrar / kaydedilenler | `review_screen`, `saved_questions_screen` | `fetchReviewQuestions`, `list_bookmarks` | Yeniden stil |
| Arena (hub) | — | — | **Yeni** hub: Lig, Meydan Oku, Günün Meydan Okuması |
| Ay Ligi | `league_card` (kart) | `get_league_status`, `resolve_league_week` | **Yeni** tam ekran |
| Arkadaşa Meydan Oku / VS / sonuç | yok | **tablo yok** | **Yeni** backend (davet kodu, hazır seçenek, sohbet YOK) + ekranlar; gerçek zamanlı en son |
| Görevler / seri | `daily_challenge`, `daily_goal` | `get_daily_challenge`, `get_daily_goal` | **Yeni** görev sistemi (günlük/haftalık) veya mevcut meydan okumayı genişlet |
| Rozetler | `badges_section`, `cipher_badges_dialog` | `get_student_badges`, `badge_progress` | Tam ekran + detay |
| Koleksiyon / sınıf / karakter detayı | `collection_screen` + detay sheet | `get_my_characters`, `set_active_character` | Sınıf filtresi, rarity çerçevesi, "Kullan/Hedefle" |
| Deneme sınavı (merkez/başlangıç/canlı/sonuç) | yok (admin tarafı var) | `deneme_sinavlari*`; öğrenci RPC'leri doğrulanacak | **Yeni** akış (sınavda Hupo sessiz) |
| Profil / istatistik / bildirimler / ayarlar | `profile_screen`, `notifications_screen`, `settings_screen` | `get_profile_overview`, `notifications` | Yeniden stil + ders istatistiği |
| Parent gate + Veli alanı | veli = **web paneli** (onay `set_parental_consent`) | `get_student_dashboard` (veli rolü) | Uygulama içi yalnızca parent gate + salt okunur özet + web'e yönlendirme; satın alma/izin veli webinde |
| Premium | `membership` kartı | `my_subscription_status`, `plans` | Çocuk ekranında yalnız bilgi → parent gate → web (iyzico) |

## 5. Senkron matrisi: tek kaynak DB, üç yüzey
| Alan | Admin (yönetir) | Web | Mobil (okur/yazar) | DB/RPC |
|---|---|---|---|---|
| Sorular, konular | `/yonetim/sorular` (onay akışı) | demo kopyası | quiz | `questions`, `admin_*question*` |
| Karakter kataloğu, rarity, açılış koşulu | **eksik**: admin ekranı yok | — | koleksiyon | `character_definitions` → admin ekranı eklenecek |
| Günün meydan okuması, görev | `admin_set_daily_challenge` | — | görev/meydan okuma | `daily_challenges` |
| Deneme sınavları | `admin_upsert_mock_exam` | — | deneme akışı | `deneme_sinavlari*` |
| Bildirim/kampanya/anket | `/yonetim/bildirimler`, kampanyalar, anketler | veli tercihleri | push + uygulama içi anket (`anket_aktif_listem`) | `notifications`, `anketler` |
| Plan/üyelik/ödeme | `/yonetim/planlar,odemeler` | veli paneli | yalnız durum göster | `plans`, `subscriptions` |
| Veli izni, iletişim tercihi | aile profili | veli paneli | gate + özet | `set_parental_consent`, `veli_tercih_ayarla` |
| Uygulama ayarı (bakım, min sürüm, reklam) | `app_settings` | — | `maintenance_gate` | `get_app_config` |
Kural: mobilde hardcode katalog yok; karakter/rozet/ders listeleri DB'den. Yeni admin gereksinimi (karakter kataloğu, görev tanımı, meydan okuma moderasyonu) ilgili dalgada admin ekranıyla **birlikte** teslim edilir. Admin oturumunun `20261007*` migration'ları (henüz uygulanmadı) ile çakışmamak için yeni migration numaraları `20261008…` ve sonrası.

## 6. Eksik backend (yeni migration'lar, hepsi RLS + revoke/grant, `set search_path`)
1. `friendships`/`challenge_invites`/`challenges` + RPC'ler (davet kodu üret/kabul, hazır soru seti, skor gönder). Açık sohbet yok, takma ad/rumuz (tam ad yok), veli izni olmadan sosyal özellik kapalı.
2. `quests` + `student_quests` (günlük/haftalık görev, ödül XP, sunucuda doğrulama).
3. Recovery XP: `submit_answer` içinde "yanlıştan sonra doğru" kuralı (tek sefer, sunucuda).
4. Konu bazlı ilerleme RPC'si (`get_topic_progress`) — veli raporundaki 6 soru eşiğiyle aynı kural.
5. Deneme sınavı öğrenci RPC'leri (başlat/cevapla/bitir, süre sunucuda).
6. `maturity`: yeni sütun gerekmez; `my_sinif()`'ten türetilir.

## 7. Dalgalar (her biri küçük commit'lerle, doğrulama: `flutter analyze` + `flutter test` + önizleme görüntüleri)
- **W0 — Temel (TAMAM 2026-10-07, analyze 0 sorun, 179 test):** bu plan, token genişletme (`navyDeep`, rarity renkleri, maturity), 5 sekmeli kabuk (`IndexedStack` + `NavigationBar`), mevcut ekranlar sekmelere yerleşir. Kabul: tüm mevcut akışlar çalışır, testler yeşil.
- **W1 — Öğrenme döngüsü (TAMAM 2026-10-08, analyze 0 sorun, 184 test, SQL test 13/13 sunucuda doğrulandı):** Ana Sayfa 3 odağa indirildi (Bugünkü hedefin / Kaldığın yer / Bugünkü odakların). Öğren sekmesinde ders → konu kırılımı (`SubjectTopicsScreen`, `get_topic_progress`, 6 soru eşiği). Kurtarma XP: yanlış cevaptan sonra "Benzer Soru Çöz" aynı konudan farklı soruyu öne alır; doğru çözülürse sunucu tek seferlik +5 XP verir (`submit_answer` p_kurtarma_of). Sonuç ekranında "sonraki seviyeye kalan XP" ve kurtarılan soru sayısı. Migration `20261008000000` uzak DB'ye uygulandı ve doğrulandı.
- **W2 — Koleksiyon (TAMAM 2026-10-08, analyze 0 sorun, 187 test, SQL test 4/4 sunucuda doğrulandı):** Nadirlik (`KarakterNadirlik`) `karakter_sira` (1-5) alanından türetildi — yeni DB sütunu gerekmedi. Kazanılmış karakterlerde nadirlik etiketi + Efsanevi/Mitik için rozet ve güçlü glow; koleksiyon ekranında sınıf filtre çipleri ("Tümü" + 8 sınıf); karakter detayında nadirlik rozeti. "Kullan" zaten W0'dan beri vardı ("Aktif karakterim yap"); paketin ayrı "Hedefle" (pin) özelliği **bilinçli olarak eklenmedi** — otomatik "sıradaki kilitli karakter" zaten aynı işi görüyor, yeni DB alanı/RPC gerektirecek bir özelliği ürün sahibi onayı olmadan eklemedik. Admin `admin_list_characters()` RPC'si (salt okunur, 40 karakter + kazanan sayısı) yazıldı ve uzak DB'de doğrulandı; **web-panel ekranı bu dalgada yok** — eşzamanlı başka bir oturum web-panel/src üzerinde çalıştığı için dosya çakışması riskini önlemek adına ertelendi (RPC hazır, ekran ayrı bir işte eklenecek).
- **W3 — Lig/Arena (TAMAM 2026-10-08, analyze 0 sorun, 189 test):** Ay Ligi tam ekranı (`LeagueScreen`) — güncel durum kartı + 5 basamaklı "lig merdiveni" (Bronz→Elmas, en üstte hedef). Basamak durumları: Geçtin / Buradasın / Kilitli. Yeni backend gerekmedi: `public.leagues` tablosu zaten `authenticated` için SELECT'e açıktı (RLS `using (true)`), yalnızca `fetchLeagueLadder()` repository metodu eklendi. "Buradasın" vurgusu bilerek lig renginden bağımsız sabit marka rengiyle (teal) gösterilir — Gümüş/Bronz gibi gri/kahve tonlu liglerde kendi rengiyle vurgulanırsa "kilitli" ile karışabiliyordu (önizlemede görüldü, düzeltildi). Ana Sayfa'daki lig özeti ve Arena'daki lig kartı artık bu ekrana açılıyor. Paketin isim/avatarlı liderlik tablosu **bilerek yapılmadı** — mevcut anonim sıralama kuralı (`league_card.dart`: "başka çocukların adı gösterilmez") korundu; roster döndüren yeni bir RPC yazılmadı.
- **W4 — Görevler/rozetler/seri (TAMAM 2026-10-09, analyze 0 sorun, 193 test, SQL test uzak DB'de doğrulandı):** `quest_definitions` + `quest_claims` tabloları ve 3 RPC (`get_my_quests`, `claim_quest_reward`, `_gorev_ilerleme` internal) migration `20261009000000`'de yazılıp uzak DB'ye uygulandı. İlerleme canlı hesaplanır (ayrı sayaç tablosu yok — `user_answers` üzerinden soru/doğru/kurtarma sayıları). `submit_answer`'a `kurtarma_tarihi` damgası eklendi (kurtarma görevi sayımı için). `QuestsScreen` + `_GorevMini` özet widget'ı ana sayfaya eklendi. Quiz bitince `myQuestsProvider` + `statsProvider` invalidate edilir. Admin görev tanımı web-panel ekranı **ertelendi** (RPC + katalog hazır; web-panel oturumu bekleniyor).
- **W5 — Profil/istatistik (TAMAM 2026-10-09, analyze 0 sorun, 193 test):** `ProgressCard`'a ders bazlı navigasyon eklendi — her ders satırına tıklanınca `SubjectTopicsScreen` açılıyor (konu bazlı % + yeterli veri eşiği); `onDersDetay` callback opsiyonel, geriye dönük uyumlu. Bildirim + ayarlar ekranları mevcut ve stabil; yeniden stil bu dalgada yapılmadı (profil `HeroHeader` kullanıyor, pakete göre navy drift var; baskı yetersiz, kozmetik iş ertelendi).
- **W6 — Veli geçidi + premium bilgi (TAMAM 2026-10-09, analyze 0 sorun, 193 test):** Profil ekranına "Velim için" bölümü eklendi — veli raporu ve premium bilgi linkleri url_launcher ile tarayıcıda açılıyor (çocuk uygulamasında satın alma düğmesi yok; web sitesine yönlendirme). audio_manager.dart ambiguous_import düzeltildi (audioplayers 6.x AudioEvent çakışması, hide ile çözüldü). settings_privacy_test.dart'taki switch sırası testi düzeltildi (3. switch ses efektleri eklenince indeksler kaymıştı).
- **W7 — Deneme sınavı** (TAMAM `c48071c`) — list_my_exams/start_mock_exam/submit_mock_exam RPC + MockExamScreen (timer, PopScope, YKS puanlama sunucuda, dogru_sik istemciye gitmiyor).
- **W8 — Arkadaşa meydan oku/VS** (migration 1, güvenlik incelemesi; gerçek zamanlı en son).
- **W9 — Cila:** erişilebilirlik (44dp, metin ölçeği, reduced-motion), tablet kırılımları, performans, gerçek cihaz QA.

## 8. Riskler / açık noktalar
- Gerçek cihaz/emülatör doğrulaması bu ortamda yok; golden önizlemelerle görsel kontrol yapılır, cihaz QA'sı kullanıcıdadır.
- Paket 3–8. sınıf diyor; ürün odağı 4→5. Maturity sistemi 3–8'i destekler, içerik kapsamı pilotta 4. sınıf.
- Karakter görselleri 640 px şeffaf; sinematik "üst rarity" sunum için ayrıca yüksek çözünürlük/animasyon gerekebilir.
- Çocuk güvenliği (sosyal özellik): W8 öncesi ayrı güvenlik/veli izni tasarımı onayı.
- Admin paneli ile ortak token dosyası: web `globals.css` tek kaynak; mobil `app_theme.dart` aynı değerleri elle yansıtır (değişimde ikisi birlikte güncellenir).
