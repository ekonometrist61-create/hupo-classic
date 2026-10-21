# Pilot: 2. sınıf 15 hikâye — değerlendirme (2026-10-21)

- Kaynak: `C:\Users\cengi\Downloads\HupoRead_2_Sinif_15_Tam_Hikaye.md` (15 tam metin, HR-001…HR-017; HR-011 ve HR-015 bu dosyada yok).
- Durum: **değerlendirme, değişiklik yok.** Metinler yayına hazır değil; taslak olarak kabul edilebilir.
- Hedef kitle: 2. sınıf. Pilot planında ilk sınıf seti 4–5. sınıftı; bu dosya 2. sınıf. Karar gerekiyor (bkz. §4).

## 1. Doğrulanan (mekanik)

| Kontrol | Sonuç |
|---|---|
| Kod, başlık, sınıf kataloğu (`fixtures/hr_katalog.json`) | 15/15 eşleşiyor, hepsi 2. sınıf |
| Telif sınıfı | O: 9 · A (geleneksel kök): HR-005, 006, 010 · K (kamu malı kaynak): HR-007, 008 |
| Kelime sayısı (gövde) | 306–345; 300–350 aralığında. Dosyadaki beyanlar ±4 kelime fark ediyor |
| Dosyadaki "MEB yarışma şartnamesi" atfı | Doğrulamadım; ürün kuralı olarak kullanmıyorum |

## 2. Metin kalitesi (okuma değerlendirmesi)

| Kod | Başlık | Puan | Ana sorun |
|---|---|---|---|
| HR-002 | Renkli Uçurtmanın Peşinde | İyi | Harita fikri net; yön sözcükleri yerinde |
| HR-009 | Konuşan Kalem Kutusu | İyi | Somut, mizahlı, düzen-plan kavramı net |
| HR-016 | Gölgeyi Kim Büyüttü? | İyi | Bilimsel olarak doğru (gölge boyu, güneş yüksekliği); tekrarlar az |
| HR-001 | Kayıp Çanın İzinde | Orta | Sade ve tutarlı; "Hupo" karakteri (§3) |
| HR-003 | Çorabını Arayan Robot | Orta | Espri zayıf, "mavi" tekrarı; son sahne zorlama |
| HR-005 | Hoca'nın Gölündeki Umut | Orta | Gözlem/tahmin değeri iyi; "göl kirlenmemişti" ironisi karışık |
| HR-007 | Kaplumbağa ile Tavşanın Yeni Yarışı | Orta | Fabl yeniden anlatımı; son paragraflar aynı sonucu üç kez söylüyor |
| HR-012 | Yeni Arkadaşın Gizli Yeteneği | Orta | Değer net; cümleler uzun, harita sahneleri tekrarlı |
| HR-013 | Kırılan Oyuncak Köprü | Orta | Uzlaşma iyi; son bölüm vaaz gibi |
| HR-014 | Yağmur Damlasının Yolculuğu | Orta | Su döngüsü doğru; 2. sınıf için "buharlaşma, yoğunlaşma" yoğun; çerçeve anlatı uzun |
| HR-017 | Mahallenin En Hızlı Bisikleti | Orta | Değer iyi; "bir yandan … bir yandan" kalıbı fazla |
| HR-004 | Ters Gün Okulda | Zayıf | Dağınık: dört ayrı olay; "ÇOK UZUN KISA CETVEL" gibi tabela şakaları mantıksız |
| HR-006 | Düdük Kimin Olacak? | Zayıf | Hoca'nın tek düdük verme kararı "adalet" değerine ters; ahlaki sonuç bulanık |
| HR-008 | Aslan ile Farenin Yardımı | Zayıf | Aynı duygular 4–5 kez tekrar; "ceviz kabı sandal" bölümü bağlamsız |
| HR-010 | Keloğlan ve Konuşan Taş | Zayıf | Bilmecenin cevabı ("iyilik") soruyla tam örtüşmüyor; sepet sahnesi iki kez anlatılıyor; "yol işareti" bölümü kopuk |

Özet: 3 iyi, 8 orta, 4 zayıf. Hiçbiri olduğu gibi yayınlanamaz. Zayıf 4 hikâye yeniden yazım, orta 8 hikâye redaksiyon (tekrar temizliği, son paragrafı kısaltma), iyi 3 hafif redaksiyon gerektirir.

## 3. Yapısal uyumsuzluklar (karar gerekir)

1. **Kahraman modeli.** Sistemdeki 52 taslağın tamamı `{kahraman}` ve `{yoldas:...}` tokenlarıyla yazılmış (ör. `tavsan-sepeti.hikaye.md`). Bu dosyada kahramanlar sabit isimli (Ela, Ali, Mert, Ayşe…). Böylece "çocuk kahraman olur" ilkesi bu 15 hikâyede yok.
2. **"Hupo" metin karakteri.** Dosyada Hupo 38 kez karakter olarak geçiyor. Şartname (K8) okuyucu metninde Hupo'yu yasaklamıştı; bu bir görsel karardı, ama metin içinde karakter olarak kullanımı açık değil. Yoldaş tokeni mi, sabit karakter mi?
3. **Soru ve sözlük yok.** Dosyada okuduğunu anlama soruları, cevap anahtarı ve sözlük anlamları yok. Pilotun çalışması için her hikâyede soru ve sözlük yuvası gerekir; bunlar ayrı üretilip onay alır.
4. **Deyim ve atasözü hedefi zayıf.** Brief eş/zıt/sesteş, deyim ve atasözü istiyordu. Dosyada çoğunlukla yalnızca zıt anlam çifti var (ör. erken-geç, açık-kapalı); deyim ve atasözü metinde görünmüyor (HR-006'nın "atasözüyle anlam" kaydı var ama metinde atasözü yok).
5. **Hak durumu.** A ve K kayıtlarında kaynak edisyonu ve hak notu yok; yayından önce editör kaydı ve hukuk onayı gerekir (GÖR-043/045).

## 4. Kararlarınız gereken konular

1. **Kahraman:** Ana karakterler `{kahraman}` tokenına çevrilsin mi (önerim: evet)?
2. **Hupo:** Metinde sabit yoldaş olarak kalsın mı (`{yoldas}` yerine), yoksa yoldaş tokeni mi kullanılsın?
3. **Pilot sınıfı:** 2. sınıf 15 hikâye pilot olsun mu, yoksa planlanan 4–5. sınıf seti mi önce gelsin? (Önerim: bu 15'i pilot olarak kullanıp 4–5'i ayrı dalga yapmak; ama 2. sınıf 4–5. sınıf planından farklı.)
4. **Redaksiyon:** Zayıf 4 hikâyeyi ben yeniden yazayım mı, sen mi? Orta 8 için tekrar temizliği yapılsın mı? (Önerim: ben yazarım, sen okursun.)
5. **Soru ve sözlük:** Her hikâyeye 3 okuduğunu anlama sorusu + cevap anahtarı + sözlük yuvası üretilsin mi? Onaylar sende.

## 5. Önerilen sıra (karar sonrası)

1. Kararlar (§4) → kahraman tokenları ve Hupo kuralı.
2. Zayıf 4 + orta 8 + iyi 3 için redaksiyon, her biri için kısa değişiklik notu.
3. `.hikaye.md` biçimine dönüşüm (`atolye` derleyici ile hata kontrolü, `npm test`).
4. Soru ve sözlük üretimi; hepsi taslak, onay bekler.
5. Kullanıcı okuması. Onaydan sonra yerel paket ve fiş katmanına (HR-001…017) içe aktarma. Uzak DB'ye yazma ayrı onay ister.

## 6. Bu aşamada yapılmayanlar

- Metinlerde değişiklik yapılmadı; dosya kaynak olarak Downloads'ta duruyor.
- Hiçbir hikâye yayınlanmadı, bayrak kapalı kaldı, uzak DB'ye dokunulmadı.
- Derleyici hata kontrolü henüz çalıştırılmadı (biçim dönüşümü yapılmadan anlamlı değil).
