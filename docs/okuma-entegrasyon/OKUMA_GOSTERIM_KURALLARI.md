# Okuma içerik gösterim kuralları

Durum: ONAYLI TASLAK (2026-10-21, kullanıcı isteği: "seçim ve adet bir kurala bağlansın; her hikâye üretiminde kullanılsın").
Kod kaynağı: `flutter_prototip/lib/gosterim_kurallari.dart` (testler: `test/gosterim_kurallari_test.dart`). Sayıyı değiştirmek için önce bu belge, sonra kod ve test güncellenir.

## 1. İlke
Anlatı önce akıcı ve doğal olur. Vurgu, hikâyenin **öğrenme hedefine** hizmet eder; süs değildir. Kavram ya da ikon yerleştirebilmek için metne anlamsız söz eklenmez. Vurgusuz sayfa normaldir.

## 2. Vurgu türleri ve öncelik
Kelime (dokununca anlam açılır) > deyim > önemli yer. Eşitlikte metindeki sıra.

## 3. Seçim kuralları (sırayla)
1. **İlk geçiş:** Aynı kelime ya da deyim hikâyede yalnız ilk geçtiği yerde vurgulanır.
2. **Cümle başına tek vurgu:** Aynı cümlede iki vurgu varsa yüksek öncelikli kalır.
3. **Sayfa bütçesi** (aşağıdaki tablo).
4. **Çıkartma (satır içi ikon):** Sayfadaki ilk işaretler, bütçe kadar; ikon kimliği olmayan sayılmaz. Maskot metin içinde basılmaz.

## 4. Sayfa bütçesi
| Mod / sınıf | Toplam vurgu | Bunlardan kelime | Çıkartma |
|---|---|---|---|
| 2–5. sınıf, Zengin | 3 | en çok 2 | 2 |
| 6. sınıf, Zengin | 2 | en çok 1 | 1 |
| 7–8. sınıf, Zengin | 2 | en çok 1 | 0 |
| Sade (her sınıf) | 1 | 1 | 0 |

## 5. Sayfa dışı kartlar
- **Kelime Keşfi** kartı: sayfa başına en çok 1; yalnız vurgulanan bir kelimenin anlamı ve aynı sözlük yuvasında benzer anlamlısı **veride varsa**. Eş/zıt anlamı uydurulmaz.
- **Atasözü kartı:** sayfada ilk atasözü kart olur; hikâye başına en çok 2 atasözü. Anlamı olmayan atasözünde "Anlamı" kutusu ve "Sözlüğe ekle" gösterilmez.
- **Düşün sorusu:** atasözü sayfasında en çok 1; cevap yazdırılmaz, puan yok.
- **Bilgi Kutusu:** yalnız onaylı içerikten gelir (kelime paneli içinde).
- **Sahne görseli:** 1. sayfada büyük; sonraki sayfalarda aynı sahnenin dar şeridi. Sade modda ve 7–8. sınıfta yalnız 1. sayfa.

## 6. Üretici (yazar, derleyici, ajan) için
- Her hikâyede en az 1, en çok 6 öğrenme hedefi tanımla (kelime, deyim, atasözü, değer).
- Bir sayfaya 3'ten fazla vurgu adayı koyma; fazlası kuralla zaten düz metne döner, ama üretimde ayıkla.
- Kelime hedefi sayfada doğal geçmeli; ilk geçişi en anlamlı cümlede olsun (ilk geçiş vurgulanır).
- Sözlük girdisi olmayan kelimeyi hedef yapma; anlamı, eş/zıt anlamı ve bilgi metni onaylı olmalı (Ajan A/B + insan).
- Hikâyede 2'den fazla atasözü olmasın.

## 7. Süre etiketi

> 2026-10-21: Derleyici (tolye/src/derle.ts) bu tabloyu ve yukarı yuvarlamayı kullanacak şekilde hizalandı; eski derleyici tablosu (2→60, 3→80, …, 8→165, yarım dakika) kaldırıldı. Tek kaynak: bu belge + mobile-app/packages/okuma_motoru/lib/sure.dart.
Her hikâye kartında "N dk" gösterilir: kelime sayısı / sınıfa göre okuma hızı (kelime/dk: 2→60, 3→75, 4→90, 5→105, 6→115, 7→125, 8→135), yukarı yuvarlanır, en az 1. Bu bir **tahmindir**, ölçüm değildir. Kod: `okuma_v3_icerik.dart` (`okumaHizi`, `okumaDakikasi`).

## 8. Otomatik geçiş (soru ekranı)
Doğru cevapta 3 sn, yanlışta 6 sn sonra sonraki soruya (sonuncuda sonuç ekranına) geçilir; geri sayım çubuğu görünür; "Sonraki soru" düğmesi her zaman bekletmeden geçirir. Hareket azaltmada çubuk animasyonsuzdur.
