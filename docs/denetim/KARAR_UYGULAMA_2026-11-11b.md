# GÖR-093 onay ve devam (2026-11-11, ek)

Kaynak: kullanıcı "hepsini onaylıyorum, devam et" dedi. Önceki uygulama: `KARAR_UYGULAMA_2026-11-11.md`. Kayıt: K-0244.

## 1. Yayına alınan (kullanıcı onayı, admin profili)

- **63 yeni taslak sürüm yayına alındı.** İnceleyen: kullanıcı profili (`e416ac41…`, admin). Eski yayındaki 62 sürüm arşive alındı. `H-dea9f9eb` (D3) için yayındaki sürüm yoktu, yeni sürüm yayında.
- Kapı kontrolü: her yeni yayındaki sürümde `insan = approved` ve inceleyen dolu. Ajan A/B sonuçları `pending` kaldı; yayın kuralı insan onayını esas alır.
- Sonuç: yayında 100 hikâye, her birinde tek sürüm. Yayında hepsi-A hikâye 0.
- Not: Bu 63 sürümün metinleri zaten insan onaylı içerikle aynı; yalnız şık sırası ve doğru harf değişti (hikâye metni, sözlük ve açıklamalar aynı). D3 sürümünde 16. sayfa editoryal notu kaldırıldı.

## 2. Taslak (yayına alınmadı)

- **`96491ac6` (8. sınıf, yeni sürüm 4):** Sorulardaki "Ekin'in" ve "Aras'ın" ifadeleri "Metinde geçen bu benzetmeye göre" ve "Metinde geçen nota göre" yapıldı. Metindeki adlar zaten yer tutucu kullanıyordu. `d4_not` alanında "yok" yazılı.
- **`9c974d9d` (8. sınıf, yeni sürüm 3):** Sorudaki "Lalin" → "Ana karakter"; açıklamadaki "Lalin" aynı şekilde; ikinci soru "Narin'e göre" → "Metinde itiraz eden öğrenciye göre". **Metin gövdesinde Narin, Melis ve Cem sabit adlarla kalıyor**; bunları yer tutucuya çevirmek her çekimde karar ister. Bu iş ayrı bir karar.
- İki taslak da insan onayı bekliyor. Onay verilirse yayındaki sürüm arşive alınıp taslak yayına geçer.
- Bilinen kalan: `96491ac6` s3'te "Mert Bey" ve "Aslı Hanım" gibi yetişkin figürler sabit ad olarak kaldı (yalnız hikâye karakteri, kahraman değil).

## 3. Açık kalanlar

- **D7 (zıt anlam ve yakın anlam politikası):** Kullanıcı onayladı. Ancak uygulanması iki yerde gerekiyor: denetçi istemleri (`docs/kelime-evreni/veritabani/kor-denetim-gemini.mjs` ve kullanılan istemler) ve kapı kuralı. Kapıyı etkileyen kayıtlar Gemini'nin yeniden çalıştırılmasını gerektiriyor (API maliyeti ve anahtar kararı). Bu iş ayrı onay ister. Politika metni hazır: `KARAR_UYGULAMA_2026-11-11.md` bölüm 2 ve Sonnet kararı.
- **26075725:** savaş ataması için kaynak doğrulaması yapılmadı; beklemede.
- **d8779a77:** beklemede; sayı aralığı yeniden yazılacak.
- **Beş reddedilmiş soru** (`3ec6fd70`, `94ec072e`, `af3ebcd2`, `2d6274b0`, `70a03f85`): değişmedi, reddedildi.
