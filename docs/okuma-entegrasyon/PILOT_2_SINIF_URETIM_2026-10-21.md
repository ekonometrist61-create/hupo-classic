# Pilot 2. sınıf: biçim dönüşümü ve derleme sonucu (2026-10-21)

Kaynak değerlendirme: `PILOT_2_SINIF_DEGERLENDIRME_2026-10-21.md`. Kaynak metin: `C:\Users\cengi\Downloads\HupoRead_2_Sinif_15_Tam_Hikaye.md`.

## 1. Kararlar (kullanıcı, 2026-10-21)

- Ana karakterler `{kahraman}` tokenı. Çocuk seçer; bazı hikâyelerde hayvan ya da hayali tür ile sınırlı (izinli_turler).
- Hupo metinde `{yoldas:yalin|Hupo}` tokenı; varsayılan (yedek) ad Hupo. Her hikâyede en az 2 geçiş var.
- Pilot: bu 15 hikâye (2. sınıf). 4–5. sınıf ayrı dalga.
- Redaksiyonu ben yaptım: 15 metnin tamamı yeniden yazıldı (zayıflarda yapı değişti; iyi olanlarda cümle düzeyinde).
- Her hikâyeye 4 okuduğunu anlama sorusu (sınıf ölçütü 2–3; karar 4, derleyici uyarısı kabul edildi), cevap anahtarı (`dogru`) ve gerekçe.
- Sözlük yuvaları: 30 yeni kelime yuvası, `s2_` önekiyle, taslak (`ornek/sozluk.pilot-2.json`, mevcut 10 yuva korundu).

## 2. Dosya eşlemesi

Konum: `C:\Dev\Senin Hikayen - HupoRead\icerik\pilot-2-sinif\` (paketler `paket/` altında).

| Dosya | Kod | Tür | Kelime hedefleri | Değer |
|---|---|---|---|---|
| hr001-kayip-canin-izinde | HR-001 | macera | dikkatle, uzak | D20 |
| hr002-renkli-ucurtma | HR-002 | macera | yukarı, harita | D20 |
| hr003-corabini-arayan-robot | HR-003 | mizah | yuvarlak, köşeli | D12 |
| hr004-ters-gun-okulda | HR-004 | mizah | erken, geç | D14 |
| hr005-hocanin-golundeki-umut | HR-005 | mizah | tahmin, gözlem | D5 |
| hr006-dudek-kimin-olacak | HR-006 | mizah | emek, harçlık | D16 (+D1) |
| hr007-kaplumbaga-ve-tavsan | HR-007 | macera | hızlı, yavaş | D12 (+D14) |
| hr008-aslan-ve-fare | HR-008 | macera | güçlü, küçük | D9 (+D20) |
| hr009-konusan-kalem-kutusu | HR-009 | mizah | dar, geniş | D16 |
| hr010-kelogan-ve-konusan-tas | HR-010 | macera | bilmece, cevap | D20 |
| hr012-yeni-arkadasin-gizli-yetenegi | HR-012 | macera | çekingen, cesur | D14 |
| hr013-kirilan-oyuncak-kopru | HR-013 | macera | sağlam, onarım | D16 |
| hr014-yagmur-damlasinin-yolculugu | HR-014 | bilim | buhar, damla | D17 |
| hr016-golgeyi-kim-buyuttu | HR-016 | bilim | uzun, kısa | D12 |
| hr017-mahallenin-en-hizli-bisikleti | HR-017 | macera | eski, yeni | D3 (+D20) |

HR-011 ve HR-015 bu pilotta yok (katalogda 3. sınıf).

## 3. Derleme sonucu

- 15/15 hikâye hatasız derlendi, 15 paket üretildi (`paket/`).
- Yol arkadaşı, token ek kontrolü, sözlük yuvası, dayanak (omurga) ve şık sayısı kontrolleri geçti.

Kalan uyarılar (hepsi bilerek bırakıldı):
- Kanıt düzeyi C: resmî sınıf eşleşmesi yok; yayın öncesi insan kararı.
- 4 soru: 2. sınıf pilot aralığı 2–3; kullanıcı kararı.
- Yuva başına 1 aday: yayın kapısı en az 3 aday ister; taslak aşamasında kabul.
- Uzunluk: kelime sayıları yaklaşık 160–220 (derleyici aralığı 120–220). Kaynak dosyanın 300–350'si ile katalog brifindeki 300–500 hedefi ile uyuşmuyor; **karar gerekiyor**.

## 4. Açık kalanlar

1. Uzunluk standardı: 120–220 (rehber pilot tablosu) mı, 300–500 (katalog brifi) mi? Hikâyeler iki yöne de genişletilebilir.
2. Editör ve insan okuması: hiçbir metin onaylı değil. Ajan A/B denetimi yapılmadı (süreç dışında).
3. Telif: A ve K kaynaklı hikâyeler (HR-005, 006, 007, 008, 010) için kaynak ve hak kaydı yok; yayından önce hukuk onayı gerekir.
4. Uzak DB: hiçbir veri yazılmadı. İçe aktarma ayrı onay ister.
5. Fiş eşlemesi: front matter'da fiş kodu alanı yok; eşleme yukarıdaki tabloda.
