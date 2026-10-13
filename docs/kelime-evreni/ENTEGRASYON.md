# Kelime Evreni — entegrasyon notu

Kaynak: `HUPOLINGO_Kelime_Evreni_Flutter_Claude_Paketi.zip` (v0.1). Branch: `feature/kelime-evreni`.
Karar kaydı ve kalan işler: `TASKS.md` §13.

## 1. Fark analizi (paket ↔ mevcut repo)

| Konu | Paket (v0.1) | Mevcut repo | Karar |
|---|---|---|---|
| Kullanıcı / rol | `word_parent_links`, `word_admin_members` adaptörleri | `profiles.parent_id`, `profiles.role` (`admin`, `veli`, `ogrenci`, `ogretmen`), `is_parent_of()`, `is_admin()` | Adaptörler kaldırıldı; mevcut fonksiyonlar kullanıldı |
| XP | `word_submit_attempt` yalnızca kendi tablosuna yazar, ledger'a yazmaz | `award_xp_and_streak()` tek yazım yolu, `xp_events` defteri, seri ve lig; `submit_answer` XP'yi zorluğa göre ve yalnızca tekrar zamanı gelmiş doğru cevapta verir | Aynı kural: XP = zorluk 1/2/3 → 10/20/30; yalnızca doğru, ipucusuz ve anlamın tekrar zamanı gelmiş olduğu cevapta. Diğer doğru cevaplar seri sayar. Paketin 10/5 puanları kullanılmadı |
| Soru bankası | Ayrı `word_game_items` | `questions` (onay_durumu, quiz akışları) | Ayrı içerik türü; `questions` değişmedi (Türkçe quiz havuzuna sızmaz) |
| Onay akışı | `status` draft/review/published/archived; `reviewed_by` | `questions.onay_durumu` (beklemede/onaylandi/reddedildi) | Kelime soruları için taslak/incelemede/yayinda/arsiv; dört göz kuralı DB CHECK + RPC |
| Doğru şık gizliliği | `correct_index` ve `explanation` tablodan okunabilir (güvenlik açığı) | `questions` için tablo select kaldırılıp kolon grant'i kullanılıyor | Tablo yetkisi kapalı; yalnızca RPC; doğru şık cevap sonrası dönüyor |
| Tekrar (SRS) | `word_mastery` (sense × skill) | `user_answers` (soru başına SM-2), `review_screen` | Kelime ustalığı ayrı (anlam düzeyi); `user_answers` ile çakışmaz |
| Ustalık | Tek beceride 5. seviye = ustalık | — | Tanıma en fazla 3; tam ustalık için diğer beceriler gerekir |
| Yanlış cevap | Açıklama + tekrar | — | Açıklama; aynı anlamın başka sorusu bulunursa sıraya eklenir |
| İpucu | 5 XP | — | İpucu XP'yi etkilemez; ustalık ve raporda ayrı izlenir |
| Hız sınırı | dakikada 30 | — | Aynı (`RATE_LIMIT`) |
| Sınıf | `grade 1–8` | `profiles.sinif 1–12` | 1–12, mevcut sınıf kolonuyla eşleşir |
| Kazanım | yok | yok (resmi tablo yok) | Serbest `kazanim_kodu` metni |
| Mobil UI | Metin tabanlı MCQ; `correct_index` istemciden okunuyor | `AnswerOption`, `GameCard`, `Hupo`, `ChunkyButton` | Mevcut bileşenlerle yeniden yazıldı; hareket azaltma ve ses/haptik mevcut çağrılarla |
| Admin | Salt okunur özet | `/yonetim/*` (client RPC kalıbı) | Yönetim ekranı mevcut kalıpla yazıldı |
| Veli | 3 metrik | `/veli-paneli` (ChildScope) | Gelişim kartı, Genel Bakış'a eklendi |
| Demo içerik | `supabase/seed/example_draft.sql` | — | Migration'a alınmadı; üretimde demo içerik yok |

## 2. Veritabanı

- Migration'lar (sırayla): `20261022000000_kelime_evreni.sql` (6 tablo, RLS, RPC'ler), `20261022000001_kelime_evreni_baslangic_icerik.sql` (93 anlam, 49 ilişki, 48 soru; hepsi taslak ve onaysız), `20261022000002_kelime_meydan_okuma.sql` (Arena kelime modu), `20261023000000_kelime_evreni_duzeltme.sql` (uzakta önceki sürümle uygulanmış kurulumu güncel sürüme getirir).
- Uzak veritabanı: ilk iki migration önceki sürümle zaten uygulanmıştı (zorluksuz, 92 anlam, sorusuz). Uygulanmış migration değiştirilmediği için düzeltme ayrı migration olarak eklendi. Veri kaybı yok (seed dışında kullanıcı verisi yoktu). Son durum salt-okunur kontrolle doğrulandı: 93 / 49 / 48, hepsi taslak, onaylı ilişki yok.
- Testler: `supabase/tests/kelime_evreni_tests.sql` (40 senaryo). Yerel çalıştırma: `supabase/tests/kelime_evreni/README.md` (PGlite, Docker gerekmez). Son çalıştırma: 40/40.
- **Uzak Supabase'e uygulanmadı.** `npm run db:preview` ve `db:deploy` için kullanıcı onayı gerekir.

## 3. Ekran tanımları (hedef · ana eylem · durumlar · kabul)

Durum işaretleri: `[x]` kod ve bir otomatik kontrolle doğrulandı; `[ ]` yapılmadı ya da cihaz / tarayıcıda görülmedi.

### 3.1 Öğrenci — Kelime Evreni ana ekranı (`kelime_evreni_screen.dart`)
- **Hedef:** Öğrencinin hangi oyunu oynayacağını ve kaç kelimenin tekrar beklediğini hemen görmesi.
- **Ana eylem:** Üç oyun kartından birine dokunmak.
- **Durumlar:** yükleniyor, hata (yeniden dene), dolu, kaydedilen kelime yok.
- **Kabul:**
  - [x] Üç oyun kartı, kaydedilen boş durumu ve özet hatası widget testinde (390×844 ve 1024×768)
  - [x] Oyun kartları anlamsal düğme olarak işaretli (Semantics)
  - [ ] Ana ekranda tek birincil eylem yok: üç eşit kart. Hiyerarşi kararı bekliyor
  - [ ] Cihaz / tarayıcı görsel kontrolü yapılmadı

### 3.2 Öğrenci — oyun oturumu (`kelime_oyun_screen.dart`)
- **Hedef:** Doğru eş anlamlı / zıt / eş sesli seçimini yapmak ve yanlıştan öğrenmek.
- **Ana eylem:** Şık seçmek; sonra "Devam" ya da "Sonucu gör".
- **Durumlar:** yükleniyor, sınıf eksik (sınıf seçme yolu), boş içerik, ağ hatası (aynı anahtarla "Tekrar dene"), soru kullanılamıyor ("Sıradaki soruya geç"), soru, geri bildirim (doğru/yanlış), özet.
- **Kabul:**
  - [x] Doğru cevap: geri bildirim, açıklama, XP (widget testi, 390×844 ve 1024×768)
  - [x] Yanlış cevap: açıklama, "başka soruyla tekrar" bilgisi, kaydetme (widget testi)
  - [x] İpucu gösterimi (widget testi)
  - [x] Boş içerik, sınıf eksik, ağ hatası ve soru kullanılamıyor durumları (widget testi)
  - [x] Ağ hatasında aynı deneme anahtarı; çift dokunuş tek gönderim; atla yalnızca cevap sürmüyorken (controller testi)
  - [x] Geri bildirim başlığı ekran okuyucuya canlı duyurulur (liveRegion)
  - [x] XP metinleri koyu renkte (kontrast)
  - [ ] Şık düğmeleri (ortak `AnswerOption`) beyaz metinle yeşil/turuncuda 4,5:1 altında. Ortak widget quiz ekranını da etkilediği için değişiklik kararı bekliyor
  - [ ] Özet ekranında tekrar çalışma eylemi yok. Yalnızca "Yeniden oyna"
  - [ ] Hareket azaltma (reduced motion), ses ve titreşim gerçek cihazda denenmedi

### 3.3 Veli — kelime gelişimi kartı (`KelimeGelisimKarti.tsx`)
- **Hedef:** Veli çocuğunun kelime çalışmasının durumunu ve somut bir sonraki adımı görsün.
- **Ana eylem:** Yok (bilgi kartı); öneri metinleri çalışmayı yönlendirir.
- **Durumlar:** yükleniyor, hata (Tekrar dene), henüz oynanmadı, dolu.
- **Kabul:**
  - [x] Çocuk değişince kart yeniden kurulur (`key`); eski veri görünmez
  - [x] `tsc --noEmit` ve ESLint temiz
  - [x] Yalnızca toplu veri; tek tek cevap yok (SQL testi: `soru_id`, `secilen`, `secenek` alanları çıktıda yok)
  - [ ] Tarayıcıda veli oturumuyla görsel kontrol yapılmadı

### 3.4 Yönetim — Kelime Evreni (`KelimeEvreniManager.tsx`, `KelimeSozlukPanel.tsx`)
- **Hedef:** Yönetici soruları taslaktan yayına güvenle taşısın; sözcük ilişkileri onaylı olsun.
- **Ana eylem:** Soru kaydetmek, incelemeye göndermek, yayınlamak.
- **Durumlar:** yükleniyor, hata (sunucu kodu → Türkçe mesaj), liste sınırı uyarısı, boş liste, dolu liste.
- **Kabul:**
  - [x] Durum geçişleri ve dört göz kuralı SQL testlerinde (senaryo 30, 34, 36)
  - [x] Yayınlamadan önce onay istenir; arşiv etiketi öğrencilere görünmediğini söyler
  - [x] 200 satır sınırı aşıldığında uyarı gösterilir
  - [x] `tsc --noEmit` ve ESLint temiz
  - [ ] Yeni soru formu tablonun altında açılıyor; açık taslak düzenlenirken sessizce kapanabilir
  - [ ] Tarayıcıda yönetici oturumuyla akış testi yapılmadı (admin oturumu gerekir)

## 4. Bilinen sınırlar

- Gerçek cihaz ve tarayıcı görsel kontrolü yapılmadı (oturum ve cihaz gerekir).
- Tek yöneticili kurulumda dört göz nedeniyle yayın yapılamaz; bu bir ürün kararıdır (TASKS §13.1 K5).
- Eşzamanlılık yükü ve gerçek `award_xp_and_streak` (seri, lig, bildirim) ile birlikte SQL testi yapılmadı.
- İçerik taslak olarak yüklü (93 anlam, 49 ilişki, 48 soru). Yayın için ilişkilerin ve soruların ayrı bir yönetici tarafından onaylanması gerekir (dört göz). Tek yöneticili kurulumda yayın yapılamaz. İçerik dil uzmanı incelemesinden geçmemiştir.
- Arena (kelime meydan okuma): puanlama `dogru x 4 - yanlis` (mevcut Arena kuralı), Arena XP üretmez (mevcut davranış). Yanıtlarla tekrar/ustalık kaydı oluşmaz. Gerçek cihazda iki hesapla uçtan uca deneme yapılmadı.
- Görsel kontrol: öğrenci ekranları (ana ekran, oyun soru/yanlış geri bildirimi, Arena hub) gerçek fontlarla 390x844 ve 1024x768 boyutlarında kontrol edildi. Material ikon fontu test ortamında yüklenmediği için ikonlar kare görünür; uygulamada bu bir artefakt. Web yönetim ve veli sayfaları oturum gerektirdiği için kontrol edilmedi.
- Arena'da `submit_challenge` ve `get_challenge_result` erişim kontrolü `IS DISTINCT FROM` ile düzeltildi (davet_edilen boşken önceki kontrol NULL nedeniyle atlanıyordu).
- İpucu metni cevabı açık etmemeli. İpucu cevaplamadan önce istemciye gider ve sunucu bunu denetlemez; yazar ve editör kontrolüne bağlıdır.
- Son tam Flutter test koşusu: 247 geçti, 3 başarısız. Başarısız üç test `splash_gate_test.dart`'ta ve hata `splash_screen` bileşenindeki `ProviderScope` eksikliğinden geliyor. Bu bileşen `78f034d` (splash) commit'inde değişti; Kelime Evreni değişikliklerinde splash dosyası yok. Splash'ın master'daki durumu ayrıca doğrulanmadı.
