# Etiket önerileri: kazanımsız onaylı sorular (WP3)

Tarih: 2026-10-24. Üretim: `docs/mufredat/scripts/etiket_aday_uret.py` (aday listesi) + ajan sınıflandırması. Kaynak: `docs/mufredat/haftalik_akis_2026_2027.csv` (kaynak_yili=2026-2027). **DB'ye yazım yok**; öneriler yalnız insan incelemesi ve `admin_set_question_kazanim` ile uygulanır.

## 1. Özet

- Kazanımsız onaylı soru: **510** (salt okunur sorgu, `kazanim_kodu` boş/null).
- Kazanım kodu dolu soru (DB, tüm onay durumları): **638**; bunların onaylı olanı **458**; benzersiz (ders, sınıf, kod) üçlüsü **429**.
- Sonuç: öneri **322** (yüksek 114, orta 135, düşük 73); eşleşme yok **148**; ders eşleşmedi **40**.
- Her kazanımsız soru için CSV'de tam bir satır var: 510 = 510.

Dosyalar:
- `girdi_kazanimsiz_sorular.json`: 510 soru (id, ders, sınıf, konu, alt_konu, soru_metni, siklar, dogru_sik, kazanim_kodu). Öğrenci verisi yok.
- `adaylar.json`: soru_id → en fazla 8 aday (kod, metin, ünite, skor).
- `etiket_onerileri_2026-10-24.csv`: soru_id, ders, sinif, onerilen_kod, guven, gerekce, durum.
- `kontrol_kodlu.json`: ders eşleme ve kod-müfredat kontrolü ayrıntısı.

## 2. Eşleşmeyen sonuçların nedenleri

| Neden | Adet |
|---|---|
| Sınıflandırıldı: aday listesinde uygun kazanım yok | 72 |
| Sözcük örtüşmesi yok (aday 0; sınıflandırılmadı) | 38 |
| En uygun kazanım aday listesinde yok (aday kaçırma) | 20 |
| Müfredatta ders-sınıf yok (Sosyal Bilgiler 8) | 10 |
| 4. sınıf TYMM kodu (program kuralı) | 8 |
| Ders eşleşmedi (`ders_eslesmedi`) | 40 |

Not: "aday kaçırma" satırlarında en uygun kazanım, sözcük örtüşmesi ile seçilen ilk 8 adayın dışında kaldı. Bu sorular yeniden aday listesiyle (daha geniş aday kümesi) sınıflandırılmalı.

## 3. Ders eşleme

Eşleme yalnızca birebir aynı ad ile yapıldı; tahmin yapılmadı.

- `Türkçe`, `Matematik`, `Fen Bilimleri`, `Hayat Bilgisi`, `Sosyal Bilgiler`, `İngilizce`, `Din Kültürü ve Ahlak Bilgisi` (5. sınıf): birebir eşleşti.
- **`Din Kültürü` (4, 6, 7, 8. sınıf; 40 soru): eşleşmedi.** Müfredatta bu ad yok (`Din Kültürü ve Ahlak Bilgisi`). Karar gerekir. Ad eşlemesi onaylanırsa 4 ve 8. sınıf için müfredatta 2026-27 kazanım yok (yalnız 2025-2026 satırları); 6 ve 7. sınıf soruları için ayrıca kod kontrolü yapılmalı.
- **`Sosyal Bilgiler` 8. sınıf (10 soru):** müfredatta Sosyal Bilgiler 8 yok (8. sınıf karşılığı `T.C. İnkılap Tarihi ve Atatürkçülük`). Ad eşlemesi yanlış olabilir; tahmin edilmedi.

## 4. Kod-müfredat kontrolü (kazanım kodu dolu sorular)

DB'deki benzersiz 429 (ders, sınıf, kod) üçlüsünden **75** tanesi müfredatta yok:

| Ders | Sınıf | Adet | Örnek kodlar | Açıklama |
|---|---|---|---|---|
| Fen Bilimleri | 4 | 18 | FB.4.1.1, FB.4.1.2, FB.4.2.1, FB.4.2.2, FB.4.2.3, FB.4.3.1… | DB `FB.4.x.x.x`, müfredat `F.4.x.x.x` (önceki program biçimi) |
| Matematik | 4 | 28 | MAT.4.1.1, MAT.4.1.10, MAT.4.1.11, MAT.4.1.12, MAT.4.1.13, MAT.4.1.2… | DB `MAT.4.x.x`, müfredat `M.4.x.x.x` (önceki program biçimi) |
| Türkçe | 4 | 5 | T.K.4.2, T.O.4.2, T.O.4.3, T.Y.4.2, T.Y.4.3… | DB `T.K/T.O/T.Y.4.x`, müfredat `T.4.x` biçimi |
| Türkçe | 8 | 24 | T.O.8.11, T.O.8.12, T.O.8.13, T.O.8.14, T.O.8.15, T.O.8.16… | DB `T.O/T.Y.8.x`, müfredat `T.8.x.x` biçimi |

Yorum: kodların çoğu biçim farkından müfredatta görünmüyor; anlamca eşleştirme yapılmadı (öneri üretilmedi). Kod biçimi kararı (DB kodu mu, müfredat kodu mu) yapılmadan bu 75 kod için etiket verilmemeli. 4. ve 8. sınıf kodları 2026-27 programında önceki program sayıldığı için bu sınıfların etiketi yayın kapısında ayrıca doğrulanmalı.

Müfredat dosyasında gözlenen kusur: `Sosyal Bilgiler` 5. sınıfta `B.5.1.2` kodu (muhtemelen `SB.5.1.2` yazım hatası). Aday listelerinde görünüyor; öneri olarak kullanılmadı.

## 5. Ders × sınıf kırılımı

| Ders | Sınıf | Yüksek | Orta | Düşük | Eşleşme yok | Ders eşleşmedi |
|---|---|---|---|---|---|---|
| Din Kültürü | 4 | 0 | 0 | 0 | 0 | 10 |
| Din Kültürü | 6 | 0 | 0 | 0 | 0 | 10 |
| Din Kültürü | 7 | 0 | 0 | 0 | 0 | 10 |
| Din Kültürü | 8 | 0 | 0 | 0 | 0 | 10 |
| Din Kültürü ve Ahlak Bilgisi | 5 | 2 | 3 | 1 | 14 | 0 |
| Fen Bilimleri | 3 | 3 | 4 | 0 | 3 | 0 |
| Fen Bilimleri | 4 | 5 | 2 | 1 | 2 | 0 |
| Fen Bilimleri | 5 | 3 | 11 | 4 | 2 | 0 |
| Fen Bilimleri | 6 | 3 | 2 | 0 | 5 | 0 |
| Fen Bilimleri | 7 | 3 | 3 | 1 | 3 | 0 |
| Fen Bilimleri | 8 | 7 | 2 | 0 | 1 | 0 |
| Hayat Bilgisi | 1 | 2 | 5 | 2 | 1 | 0 |
| Hayat Bilgisi | 2 | 3 | 2 | 3 | 2 | 0 |
| Hayat Bilgisi | 3 | 2 | 4 | 3 | 1 | 0 |
| Matematik | 1 | 1 | 7 | 0 | 2 | 0 |
| Matematik | 2 | 2 | 7 | 1 | 0 | 0 |
| Matematik | 3 | 6 | 2 | 0 | 2 | 0 |
| Matematik | 4 | 7 | 0 | 2 | 1 | 0 |
| Matematik | 5 | 22 | 13 | 5 | 10 | 0 |
| Matematik | 6 | 4 | 3 | 2 | 1 | 0 |
| Matematik | 7 | 4 | 3 | 0 | 3 | 0 |
| Matematik | 8 | 8 | 1 | 0 | 1 | 0 |
| Sosyal Bilgiler | 4 | 0 | 0 | 0 | 10 | 0 |
| Sosyal Bilgiler | 5 | 2 | 7 | 2 | 9 | 0 |
| Sosyal Bilgiler | 6 | 1 | 5 | 2 | 2 | 0 |
| Sosyal Bilgiler | 7 | 0 | 6 | 3 | 1 | 0 |
| Sosyal Bilgiler | 8 | 0 | 0 | 0 | 10 | 0 |
| Türkçe | 1 | 2 | 4 | 3 | 1 | 0 |
| Türkçe | 2 | 2 | 2 | 3 | 3 | 0 |
| Türkçe | 3 | 1 | 3 | 5 | 1 | 0 |
| Türkçe | 4 | 2 | 4 | 0 | 4 | 0 |
| Türkçe | 5 | 6 | 2 | 4 | 8 | 0 |
| Türkçe | 6 | 2 | 3 | 0 | 5 | 0 |
| Türkçe | 7 | 3 | 3 | 0 | 4 | 0 |
| Türkçe | 8 | 5 | 4 | 0 | 1 | 0 |
| İngilizce | 2 | 0 | 0 | 4 | 6 | 0 |
| İngilizce | 3 | 0 | 0 | 7 | 3 | 0 |
| İngilizce | 4 | 1 | 2 | 2 | 5 | 0 |
| İngilizce | 5 | 0 | 1 | 6 | 13 | 0 |
| İngilizce | 6 | 0 | 2 | 4 | 4 | 0 |
| İngilizce | 7 | 0 | 6 | 0 | 4 | 0 |
| İngilizce | 8 | 0 | 7 | 3 | 0 | 0 |

## 6. İnsan inceleme listesi

- Düşük ve orta güven, **tümü** (208 soru).
- Yüksek güven: rastgele %20 örnek (23 / 114; tohum 20261024).
- Eşleşme yok ve ders eşleşmedi satırları CSV'de; eşleşme yok için aday kaçırma satırları ayrıca yeniden sınıflandırılmalı.

Düşük ve orta güven (inceleme zorunlu):
```
005b4125-90be-40af-962c-b898a9342685  010c7e46-2b63-433b-bc66-dc1819c1ebc7  03341c6a-270d-439b-a7d8-09e221746538
0379223d-a1d1-4d04-80e0-7ece32a68873  03e73d7f-1313-45f0-931d-a18ae8826665  05e2838a-4a9b-4661-89ed-30b2c8dd2924
06b41338-7c8c-4e2d-9919-e8a8e27e6fdf  0a00a552-3251-4fbf-bfc9-b95f79b2d8b1  0b4af0c8-9977-447f-b9f5-44ffe54cf8ef
0c3d2e4b-c0f4-4be8-950c-6580c051bec6  0d30b5a1-668c-48bf-97d2-a10b8601147c  0d7e18cf-609a-49a4-9769-a9389376ca0e
0da63255-c9d7-491c-8077-02cec0133811  0e8a48f4-6c38-4a61-af5e-72ebb58cd7ba  108074d3-3f9e-4e95-be0d-97fcfb543089
1323a8db-4205-4e59-92e8-9abc418c898e  133a97d4-7dc3-43f8-9f89-1c147a2a55db  13563a85-8aa2-432b-9514-65a436941eb8
14319301-a8b8-401a-96c1-e924ff3cb69c  145d6eaa-92b9-4de0-b773-a843ea2c8bbf  16138e56-025b-418b-a371-7f025802cf72
18eccd4b-6853-43b3-bf29-954a574955ab  1910f182-2d19-4bbe-83bd-3e8a02f3ec49  1940b406-34a3-4b86-9c94-dc1b4ff82ae4
1a9a540f-7990-4dec-9557-24542cf5097c  1b7cc09f-024e-402f-b6e4-aba540e0082c  1bce82ff-fa8a-447f-8c20-e1309fde9b02
1c8c1a4b-15df-41f2-99da-aa370fb93997  1ce93f7f-3200-403a-b5a8-50c1653d8353  1e76aeeb-85c1-4905-91e6-9ff03f20d83c
204a7dc9-a140-48e5-8b88-08ccb8286d21  20aba302-b190-430c-913d-e6f893c8719d  23bbd99e-6c44-43b8-9c50-776328f2aa7b
23dbfe29-065a-471f-83b2-3d919b1302a4  24835f2e-ee44-48be-9e57-29c3e3722b85  263e17d0-5874-4753-9a93-658af627a6de
2683adcc-2444-412c-82b7-55b1cc228e81  27a6830d-2d46-4322-bd36-47c72bb6d3fd  28921f01-7cf8-48d6-b70e-8d117f2336fc
28fc9871-8606-4fa1-be53-87c653113547  2a8e951d-c4f4-4cd8-85b6-ad0999a1ccd4  2ca33082-704f-48db-95c6-1478c3742a1b
2d422f8e-bacb-43f0-855e-14d970a612e6  310131e2-1b1c-4b33-9acc-baf2bf1faa72  31a467c4-842d-4c08-afbf-005aeaf38de8
32332b38-489f-4998-ad52-712125f4fd8f  344597d5-596d-423c-90a9-b09fbba26622  35e01bc4-e351-4610-8dd3-ed0fc29832c2
382613e2-ed92-4bee-aa8b-757fe6b20429  38a523b3-2754-46e0-badb-eb85eaaf136c  3b02d84d-afc0-4930-8bfd-9219816813eb
3bb983eb-9b76-4787-9f04-cf8b5e1af762  3cdc6de5-068e-476e-902f-ec1ddc6a2c49  3cee4a72-3dcd-40a2-8f01-48f37e404bd6
41dd00a0-b757-4843-b751-e9a7c9c61cb6  423833f3-0e18-45d5-a783-82edab2acd58  43b32f00-1890-455a-87ba-7fbba8822934
4496262c-51e5-41e3-91a9-8c4e0a650f06  4900096e-29cb-41df-a9a7-5cf46f9a821e  4a6cc598-5064-4059-8c84-5960fa700997
4b982b94-28d0-4946-8242-515a112bad19  4cae2246-029d-4032-adb4-c2da650cd7b2  4da8b408-7e4a-4d2f-9576-9cd21722a67b
4e0a85fc-3f3e-4481-8e21-22669f7c015b  4fd0ed04-a9d3-4cb6-b84c-24c7bc324fad  517732ed-d16c-4c4e-bbaf-6c8787133baf
523dde86-9cdc-4999-a268-e4e709177c32  52df0719-b629-438d-a5d0-1db2bd25daaf  54b67958-d568-49aa-b70d-40e52d7c5a11
54b9dee4-a1c5-49ac-bb85-8934b415c0c6  551ecdb9-dbe9-423b-b933-dd4097f557cc  56bf1247-7ccf-42aa-9765-5eb989539e9c
57db1f21-75f6-4897-a04e-da0f7dcbaec0  5898e6bf-b4e5-475b-b78f-ba8c67fd76d6  5930811a-50b9-46db-9f60-29e02eb307e7
59abc795-c7ad-46d5-8966-db3191fd2563  5b333429-8603-4117-ba15-787e43d15ac7  5ddbcce1-0e5f-4977-966e-87833094dcc2
5df2eb4b-bd61-45ae-879d-c074eb3d9558  5ef8352d-3aca-47ee-a276-7265eb993b9c  5f1c61e6-5a6f-41c1-94a8-8976d4b0fc2b
6029b110-ed05-4f70-945e-33070537759a  60fde487-69f7-4489-849d-2a383fcbe0fa  61847cdf-8625-4a07-a9d6-14152390c8b2
63163ebc-c11f-488e-b4a3-72818d009550  63dcbe0d-eb1d-43f4-9a12-da2b2717e0dc  6751d7f3-6b1e-4a6e-9d2a-be7198fefdd6
676624e7-bd8b-456b-bee4-255d2b2f5091  68564729-acde-4117-aab3-8a9383e7c30a  68bc0e48-6754-4069-8933-0d98ac3a69fb
6ac27db4-d282-4162-90c8-c5be9b838ff9  6f00b74d-248c-4f1d-8ed7-69cc79009f36  6fffd04c-b021-4caf-a67d-53860737357d
71f6eb27-0817-4702-a287-7e3c3997d203  722561cf-730a-4754-99a1-2637ffb75341  72474646-c9c7-43e1-8bcc-8ecfbb10572e
73e93f80-2c13-4459-aaf1-613a6721a5a8  74bef5ae-2c91-48d4-a42a-3a8865364189  779c03cb-e0a7-4390-9ea3-fe38d04d3171
78318580-6e0a-4cb9-a00f-e0cab3a89992  7862b0a0-0d29-42cc-93c6-3d49e5307c64  78d63d57-a6ac-4cbe-9c00-9b3d23ccfa75
79fc7ec1-6cc8-4ef7-888a-35304dcbb0fa  7a5e2a0b-b49c-4865-bea6-fb57235ab698  7c0853ca-8ed4-4e5c-85c8-b8be4e049f77
7c5851ef-ac3b-4049-adec-605383be0f74  7d1e7c1b-3873-4954-abe2-100a11ba89a9  7f59da51-d46b-49f5-8e8f-8b308afebf7f
7f78f45f-5639-4de9-a5cc-128f74e6095c  7feee692-c89e-4708-810a-8cc01c55239b  80285984-fe8b-41e4-bf31-c331b8b8718f
81d3b7b5-f3da-4359-83c0-5bed14f9e16e  8229cd83-dae6-4802-b9f6-0e990f612efa  82e79962-f2b5-4f6c-ad25-ba5f145b660c
83582a00-cbef-4b78-8644-ea8c25f1b08e  858d6869-c212-4dcf-9b68-8faccf06f53d  88a13ab0-bb0a-4b26-9240-ddbb84456f0f
89406d79-7ec6-4d31-96b5-777f5c70cb2e  89616fde-7419-4f6a-84a4-afbf63f38c2e  8994df61-31e0-41e0-ad3f-ad5f6af97f62
89e62198-d248-4d7e-86d7-a287399c8030  8a527b65-4f77-4149-8e8d-8e02c56443ca  90564862-4cf3-42b9-ae0c-11523bbb0c79
9083b1b9-0699-4716-a9e8-b25c0bee56d4  92296930-8d71-4eb6-a268-b4addaf5cfaa  93165a9a-725b-465b-9446-7f6327bf1bc4
94621aad-7d56-4106-baf2-1e2c96047980  96a04bff-d3e2-4d85-902b-a6d61a70c8dd  97c6ffe5-c31b-4272-aaf5-a6d306864333
9b83171a-023c-4a2e-bde0-18e436fe8fd2  9ce9c182-4fa3-4504-ab86-6a2f64f7f90d  9df89376-fff7-4c94-bf9c-1b6c42ec612f
9e6e20ea-5aae-4740-8b8f-14e5c2ad7cc2  9e92167e-7832-4062-a971-b7b1b3b7ac08  9ed21fc8-8278-4507-af1f-9a9557cb012a
9ed472a7-0231-435a-ab3f-fab2fcc3e448  a1d37f0f-5564-41fd-826d-13d67ce6a04d  a286ce52-f571-44f7-8b2f-ceb4e5434816
a3206bed-5353-4a55-8ce2-2e329b1d5739  a4107550-b50f-4113-99a5-9b1f3b18b2f9  a6fb898a-fd9f-4ff9-8171-03e003946bd3
a7a578a4-3ca1-4bd5-b5e5-d8e2a07ce855  a7f5d9f3-9316-4be9-b2a1-f9727bf2d8f2  acaad916-bdf7-485d-ade9-81f3d0d5be56
b3d05565-c360-4fcc-9f6d-d37e73a394e2  b56ea872-5f3d-4014-a393-4881cdef0602  b6b87824-a5e0-4ca5-ad43-6e14bce8bbd1
b6c0eee1-a28a-43bf-a523-d683e40ab802  b7775be2-5d49-4f7d-a356-9e9c315366ac  b7f6cb44-4485-4812-80db-53848e2beead
b84a0200-b4fd-434d-ac60-54f55e2232a7  ba5143a4-20e9-444d-9084-cadb3c0377c1  babcdf17-1da8-4a0e-995b-30fb7e22f760
bc9f87f4-80bc-4673-9c38-c724c62549ac  beae3b7d-3e9c-4c71-8d98-c094639bf27e  bee47420-59eb-4055-abfe-7f3d5182b486
bf50059c-448c-4c56-9147-a8ee3da7a4a2  c0638032-3eac-454f-ae45-bfd4ab0d5055  c2700e93-ae3b-40da-bb63-3cfaae685941
c2d8d09f-0bd9-48ce-b5bd-894477ceb632  c2e9a1c2-cd2f-4286-a2b6-b2c10c5415b6  c39e0bf8-c2d1-42f2-b209-694492fd4435
c40f6d33-3270-450a-bc7e-fd73bc1e4c81  c46d3601-27c5-453c-96f6-668ccecc74ba  c5ec1c50-b1db-4b70-961e-630e50efaf01
c94adb61-cd52-4af3-ad90-17bbe75d6564  cb311f3b-49b9-4876-8130-861304c19c5e  cd3c667f-dade-49ba-b0d3-ff392a9292ac
cf2395e6-c7e3-4872-85b5-d5b84d6bca31  d0e0aa51-0d01-4480-92d4-031adda35dc3  d17c1982-cd73-4926-9e82-c077b90ed3f4
d3e778b9-6943-4aa1-808a-3b2b271c0319  d3e787be-0700-4593-9b9d-4ff14f228a7e  d3f3c796-ae26-450c-bd99-8e6a539092ac
d52bc425-ded6-4524-82ca-d9f7592535bd  d58ea921-2277-44a7-be99-95c76835424a  d7760377-264d-4f2a-b1e5-e18fa00afabc
d8b450c0-25bc-43e6-9b12-1c078bb59974  d8e93807-e1bc-4ead-88ff-72f2bb7cfd61  d934a5a3-99d7-47d4-8fca-bd249934a959
da7a0942-39d8-4fa7-b57f-891a1684c2e5  dfd2811f-3746-4dee-af05-fe20d2b8667f  e1903d53-7c3f-4c51-9b0c-516d3764392f
e29a6603-e628-4f3e-ae7f-d6b6d0cb91fb  e417c7fe-e1ea-4e2b-a2b5-dc3fcb9cef4a  e41faed3-6b1e-4657-bc69-e17d3504a998
e73c91fc-498e-4cc4-9d98-c909474078da  e7d75cc8-f235-460b-bde3-a45274bd3b99  e9e3e031-c1ce-4550-95b2-384e98a74494
e9f7f4c8-e926-41bd-81d7-fa4c211d6be8  ea1942ff-9d9e-4ae5-a6bc-6c125547024c  ea22b5b2-2938-4221-bded-4e3f32faef6a
ebcebc4f-4137-4e59-991d-2f60e744b8e4  ed10c136-5bfc-4760-a6e5-63ab25e7400c  ed8b9084-9eec-460d-95e4-6ca3210d4a9b
ee54daec-cf55-4cf1-bf67-dcd4e4180bff  ef2d27ae-6348-4f78-b4f0-56085afaec17  f05b5c32-6089-4947-a1c9-0c661b6a47af
f0f156c5-835c-40b1-9ef6-c70c1c8f8d6b  f45e8366-1693-4d6c-993c-f3ce1d19cff2  f5b1c502-3324-405c-9093-7baf4646dc9d
f64cdd66-be3c-4e30-ac22-ecc4d0a9432f  f94463b6-87b8-47eb-9c5b-f92be614bebf  fcaad027-e1b8-4f31-a6e2-900310d7edcf
fe214c1e-d54d-4bdd-9ea0-4aa3d588e517  fe73af6d-8d59-4d68-82f5-0e423321a5fa  ff3df68a-2e75-4c67-9afc-f955c4a163a7
ff3ede3c-acc8-4167-b79f-fa5d1e36d7cd
```

Yüksek güven örneği (%20):
```
077070bc-6402-421e-947c-a13f4805dd35  116cdc4c-3474-489a-841f-679df7cbce73  15f19faa-623e-4ab1-bb4f-3bc9f5acfbe7
19574617-e73c-4841-982a-b45ed3204737  2fc71062-5f29-4ce1-abac-cd21c9612cbb  338e3f57-a111-4680-8c2a-247fed2d8320
4d590eed-1a2c-456b-9b75-8ee15d3536c1  545b5cf5-32c9-4daf-8d8a-66b557da6109  5778787b-f460-4119-9799-edb3b967cfff
6b6a597b-fc3b-4a66-a00f-fa029781bd86  7d81049f-ed0d-4ef9-bc40-ea584e93ccdc  8368715c-5dd1-4230-b189-e0eb7032c37a
8ee2ab5e-3e24-4e0c-b180-38ab82213b61  983f73ec-2073-45cb-a6f8-c51e0d0e70bc  9c5232c2-f19a-4027-a3ca-a3bc0bac48ae
9e028128-998f-468d-846d-7c8797abfbc7  ae86e6a1-d442-49b5-bc8c-e567fc11cd29  c1cc91f1-0eb5-444a-80a3-81e7d271f91c
cf3ebb08-3c9b-432d-9a70-27af1361cd27  d260e58c-98ba-44b1-952f-9359a459d776  d9a9f91d-ac1b-48dd-9686-150e3deab4b3
ddfe5f8e-54cd-4dc7-a53d-5a6117c9a36d  f60a5dd6-287f-4be6-bdfd-e6361c630f4d
```

## 7. Kazanımsız kalan müfredat kazanımları (soru üretim önceliği)

Müfredat (2026-27, kodlu satırlar): **3653** benzersiz (ders, sınıf, kod). Bu sayı, tek bir kodun birden fazla haftada görünmesi nedeniyle `kazanim_etiket_tablosu`'ndan biraz farklı olabilir.
Aşağıdaki sütunlar: toplam kod; öneri verilmiş kod (tüm güven düzeyleri); yalnız yüksek/orta güvenli öneri verilmiş kod; hiç öneri almamış kod (tüm güven düzeyleri).

| Ders | Sınıf | Toplam kod | Öneri alan (tüm) | Öneri alan (yüksek/orta) | Hiç öneri almayan |
|---|---|---|---|---|---|
| Almanca (ÇYDEM) | 5 | 60 | 0 | 0 | 60 |
| Almanca (ÇYDEM) | 6 | 60 | 0 | 0 | 60 |
| Almanca (ÇYDEM) | 7 | 82 | 0 | 0 | 82 |
| Almanca (ÇYDEM) | 8 | 72 | 0 | 0 | 72 |
| Beden Eğitimi ve Oyun | 1 | 13 | 0 | 0 | 13 |
| Beden Eğitimi ve Oyun | 2 | 12 | 0 | 0 | 12 |
| Beden Eğitimi ve Oyun | 3 | 14 | 0 | 0 | 14 |
| Beden Eğitimi ve Oyun | 4 | 13 | 0 | 0 | 13 |
| Beden Eğitimi ve Spor | 5 | 16 | 0 | 0 | 16 |
| Beden Eğitimi ve Spor | 6 | 17 | 0 | 0 | 17 |
| Beden Eğitimi ve Spor | 7 | 15 | 0 | 0 | 15 |
| Beden Eğitimi ve Spor | 8 | 12 | 0 | 0 | 12 |
| Bilişim Teknolojileri ve Yazılım | 5 | 24 | 0 | 0 | 24 |
| Bilişim Teknolojileri ve Yazılım | 6 | 24 | 0 | 0 | 24 |
| Din Kültürü ve Ahlak Bilgisi | 5 | 18 | 6 | 5 | 12 |
| Din Kültürü ve Ahlak Bilgisi | 6 | 18 | 0 | 0 | 18 |
| Din Kültürü ve Ahlak Bilgisi | 7 | 17 | 0 | 0 | 17 |
| Fen Bilimleri | 3 | 20 | 5 | 5 | 15 |
| Fen Bilimleri | 4 | 43 | 8 | 7 | 35 |
| Fen Bilimleri | 5 | 27 | 13 | 11 | 14 |
| Fen Bilimleri | 6 | 36 | 4 | 4 | 32 |
| Fen Bilimleri | 7 | 35 | 7 | 6 | 28 |
| Fen Bilimleri | 8 | 61 | 8 | 8 | 53 |
| Görsel Sanatlar | 1 | 11 | 0 | 0 | 11 |
| Görsel Sanatlar | 2 | 11 | 0 | 0 | 11 |
| Görsel Sanatlar | 3 | 17 | 0 | 0 | 17 |
| Görsel Sanatlar | 4 | 16 | 0 | 0 | 16 |
| Görsel Sanatlar | 5 | 10 | 0 | 0 | 10 |
| Görsel Sanatlar | 6 | 10 | 0 | 0 | 10 |
| Görsel Sanatlar | 7 | 20 | 0 | 0 | 20 |
| Görsel Sanatlar | 8 | 20 | 0 | 0 | 20 |
| Hayat Bilgisi | 1 | 23 | 7 | 6 | 16 |
| Hayat Bilgisi | 2 | 23 | 6 | 4 | 17 |
| Hayat Bilgisi | 3 | 20 | 8 | 5 | 12 |
| Matematik | 1 | 19 | 6 | 6 | 13 |
| Matematik | 2 | 25 | 8 | 7 | 17 |
| Matematik | 3 | 33 | 6 | 6 | 27 |
| Matematik | 4 | 71 | 8 | 6 | 63 |
| Matematik | 5 | 23 | 6 | 6 | 17 |
| Matematik | 6 | 24 | 7 | 6 | 17 |
| Matematik | 7 | 30 | 7 | 7 | 23 |
| Matematik | 8 | 52 | 9 | 9 | 43 |
| Müzik | 1 | 13 | 0 | 0 | 13 |
| Müzik | 2 | 13 | 0 | 0 | 13 |
| Müzik | 3 | 22 | 0 | 0 | 22 |
| Müzik | 4 | 20 | 0 | 0 | 20 |
| Müzik | 5 | 15 | 0 | 0 | 15 |
| Müzik | 6 | 13 | 0 | 0 | 13 |
| Müzik | 7 | 18 | 0 | 0 | 18 |
| Müzik | 8 | 24 | 0 | 0 | 24 |
| Sosyal Bilgiler | 4 | 33 | 0 | 0 | 33 |
| Sosyal Bilgiler | 5 | 20 | 8 | 6 | 12 |
| Sosyal Bilgiler | 6 | 18 | 7 | 5 | 11 |
| Sosyal Bilgiler | 7 | 17 | 5 | 5 | 12 |
| T.C. İnkılap Tarihi ve Atatürkçülük | 8 | 38 | 0 | 0 | 38 |
| Teknoloji ve Tasarım | 7 | 24 | 0 | 0 | 24 |
| Teknoloji ve Tasarım | 8 | 36 | 0 | 0 | 36 |
| Türkçe | 1 | 17 | 3 | 3 | 14 |
| Türkçe | 2 | 37 | 3 | 2 | 34 |
| Türkçe | 3 | 35 | 3 | 2 | 32 |
| Türkçe | 4 | 82 | 5 | 5 | 77 |
| Türkçe | 5 | 80 | 4 | 4 | 76 |
| Türkçe | 6 | 100 | 4 | 4 | 96 |
| Türkçe | 7 | 102 | 5 | 5 | 97 |
| Türkçe | 8 | 76 | 7 | 7 | 69 |
| İngilizce | 2 | 138 | 3 | 0 | 135 |
| İngilizce | 3 | 138 | 6 | 0 | 132 |
| İngilizce | 4 | 47 | 5 | 3 | 42 |
| İngilizce | 5 | 161 | 6 | 1 | 155 |
| İngilizce | 6 | 184 | 5 | 2 | 179 |
| İngilizce | 7 | 63 | 5 | 5 | 58 |
| İngilizce | 8 | 62 | 8 | 7 | 54 |
| İngilizce (ÇYDEM) | 5 | 368 | 0 | 0 | 368 |
| İngilizce (ÇYDEM) | 6 | 182 | 0 | 0 | 182 |
| İngilizce (ÇYDEM) | 7 | 192 | 0 | 0 | 192 |
| İngilizce (ÇYDEM) | 8 | 69 | 0 | 0 | 69 |
| İnsan Hakları, Vatandaşlık ve Demokrasi | 4 | 29 | 0 | 0 | 29 |

Not: `Din Kültürü` (eşleşmedi) ve 4-8. sınıf TYMM kodları önerilmediği için kapsama dahil değil; sayılar öneri verilmiş kodların ders-sınıf bazındaki sayısıdır.

## 8. Bilinen sınırlar

- Aday üretici yalnız sözcük örtüşmesi kullanır; kazanım metinleri İngilizce olan ENG kodlarında konu (ünite) adları eşleşmediği için aday listesi çoğunlukla aynı ünitenin L/R kodlarından oluşur. V (kelime) kazanımları aday listesine girmedi. Bu yüzden İngilizce kelime soruları düşük güvenle işaretlendi.
- Sözcük örtüşmesi sıfır olan sorular (38 soru) sınıflandırılmadı; bu sorular için aday üretici genişletilmeli.
- Sınıf düzeyi: tüm adaylar soru ile aynı sınıftan. Sınıf düzeyi uyuşmazlığı tespit edilmedi; ancak sınıflandırıcı kontrolü insan incelemesine bağlı.
- `kazanim_metni` (müfredat) DB'ye yazılırken müfredattan alınmalı; bu rapor metin üretmez.
