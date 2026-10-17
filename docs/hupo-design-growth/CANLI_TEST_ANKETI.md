# Canlı test anketi: hazırlık ve yayın adımları

Tarih: 2026-10-16
Amaç: Mevcut anket akışını canlıda uçtan uca denemek: kart, yanıt, kayıt, kapatma, arşiv.
Kapsam dışı: bütçe (24 saatte 1 kart), atlama takvimi (3/14/90), çocuk kapsamı, yayın anı arşivi. Bunlar henüz kodlanmadı.

## 1. Kritik kısıtlar

- **Anket tüm velilere görünür.** `anket_aktif_listem` yayındaki her anketi, yanıtlamamış her veliye döndürür. Hedefleme yok.
- **NPS kullanılmaz.** Kimlikli bir NPS yanıtı 6 ve altıysa `destek_gorevleri` kaydı oluşur ve bir veliyi destek listesine düşürür.
- **Anket silinmez.** Test bitince kapatılır ve arşive alınır. Yanıtlar veritabanında kalır.
- **Yanıtlar gerçek veri.** Test yanıtları analitiğe girer. Başlığa `[TEST]` konur, ki sonradan ayıklanabilsin.

## 2. Anket içeriği (yönetim paneli formuna girilecek değerler)

| Alan | Değer |
|---|---|
| Ad | `[TEST] Anket akışı denemesi` |
| Anonimlik | **Kimlikli** (anonim değil; yanıt hesapla eşleşsin ki doğrulayabilelim) |
| Tekrar gösterim | **1 gün** (aynı hesap ertesi gün tekrar görebilsin, test tekrarlanabilsin) |
| Yayın mecrası | **Yalnızca "Veli paneli"** (diğerlerini işaretlemeyin; `web_sitesi` artık anket için yok) |

Sorular (sırayla):

1. **Tek seçim.** Başlık: `[TEST] Anket kartını nerede gördünüz?`
   Seçenekler: `Veli paneli ana sayfası` · `Başka bir sayfa` · `Hatırlamıyorum`
2. **Kısa metin.** Başlık: `[TEST] Bir sorun fark ettiniz mi? (isteğe bağlı)`
3. **Onay.** Başlık: `[TEST] Bu soru ekranda doğru göründü mü?`

Üç soru, her biri zorunlu olmayan bir denemeyle ölçülür; ikinci soru kısa metin olduğu için isteğe bağlı davranışı ayrıca sınanır.

## 3. Yayın adımları (yönetici oturumu)

1. `https://hupolingo.com/yonetim-giris` ile yönetici olarak girin.
2. **Formlar & anketler** bölümünde **Anketler** sekmesine gidin (`/yonetim/anketler`). **+ Anket oluştur** deyin.
3. Yukarıdaki değerleri girin. **Önizle** ile üç sorunun göründüğünü kontrol edin.
4. **Kaydet** (taslak olarak kaydedilir; henüz kimse görmez).
5. Listede anketin satırında **Yayımla** deyin. Bu andan itibaren anket tüm velilerin veli panelinde görünür.
6. Yayımlandıktan sonra bana haber verin; yanıt ve katılım kayıtlarını salt okuma ile kontrol edeyim.

## 4. Test kontrol listesi (kullanıcı)

- [ ] Kendi veli hesabınızla `hupolingo.com/veli-paneli` açınca kart görünüyor mu? Başlık doğru mu?
- [ ] "Sonra" düğmesine basınca kart kayboluyor mu? Sayfayı yenileyince geri geliyor mu? (Beklenen: yerel erteleme, bu yalnızca tarayıcıda; sunucu kaydı yok.)
- [ ] Anketi tamamlayınca teşekkür mesajı çıkıyor mu? Kart bir daha görünmüyor mu?
- [ ] Aynı hesapla tekrar açınca (test sonrası) kart görünmemeli; 1 gün sonra tekrar görünebilmeli.
- [ ] Kısa metin sorusunu boş bırakınca hata olmadan gönderilebiliyor mu?
- [ ] Mobil uygulamada (hesapla) kart görünüyor mu? (Mobil için ayrıca yayın mecrası gerekir; yalnızca veli paneli seçildiyse görünmez. Bu beklenen davranış.)

## 5. Kapatma ve arşiv (test bitince)

1. Anketi **Kapat** (durum: kapalı). Kapalı anket yeniden açılamaz.
2. **Arşivle.** Anket arşiv sekmesinde kalır, silinmez.
3. Kontrol: veli panelinde kart artık görünmüyor olmalı.

## 6. Bana bırakılacak kontroller (salt okuma)

- `anketler`: kayıt var, durum ve yüzey doğru.
- `anket_yanitlari`: yanıt sayısı = test yanıtlarınız, `yuzey = 'veli_paneli'`.
- `anket_katilimlari`: katılım kaydı var.
- `destek_gorevleri`: bu anket için yeni görev yok (NPS yok).
- `anket_surumleri`: bu tablo henüz yok; sürüm kaydı beklenmiyor.

## 7. Bilinen beklenmeyen davranışlar (test için beklenen değil ama kabul edilebilir)

- Kart her veli paneli sayfasında çıkabilir (eski `layout.tsx` yerleşimi, E11).
- Bütçe yok: aynı gün birden çok anket kartı çıkabilir (yalnızca bu anket yayında olduğu sürece sorun olmaz).
- "Sonra" yalnızca tarayıcıda tutulur.
