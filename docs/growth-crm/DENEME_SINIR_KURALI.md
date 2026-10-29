# Kartsız ücretsiz deneme: uygulama içi sınırlar

- **Tarih:** 2026-10-29 (güncelleme: aynı gün, ikinci tur)
- **Durum:**
  - Veritabanı: `20261125000000` uzak DB'de uygulandı. `20261126000000` (20/20 varsayılan, görünürlük RPC'si, yönetici okuma, premium_gating açılışı) yazıldı, PGlite 39/39; **uzak DB'ye uygulama bekliyor** (otomatik mod production yazımını reddetti; proje sahibinin açık izni gerekiyor).
  - Yönetici arayüzü (`DenemeSinirlariKarti`) ve veli deneme kartı (`DenemeDurumuKarti`): kodlandı, tip denetimi temiz; **deploy edilmedi**.
  - Çocuk uygulaması (Flutter): kelime ve okuma hatalarında sınır mesajı eşlendi; **mobil sürüm çıkarılmadı**.
  - Hukuk metinleri: proje sahibi konumu onayladı ("Otomatik ücret alınmaz" + bitiş bildirimi). Metinler hukuk tarafından okunmadan yayınlanmaz.
- **Kaynak:** Proje sahibinin kararı (14 gün deneme, deneme sırasında her özellikte sınır). Değerler başlangıç hipotezidir; baseline yok.
- **Teknik karşılık:** `app_settings.deneme_sinirlari`; yönetici yazma `admin_set_deneme_sinirlari`, okuma `admin_get_deneme_sinirlari`; çocuk/veli görünürlüğü `deneme_hak_durumu(p_ogrenci)`; sınır dolunca `P0402`.

## 1. Sınırlar

| Özellik | Sınır | Pencere | Gerekçe |
|---|---|---|---|
| Soru çözme (`answer_events`) | 20 | günlük (İstanbul) | Ücretsiz taban ile aynı; alışkanlık sürer |
| Kelime Evreni (`kelime_denemeleri`) | 20 cevap | günlük | Tadım verir, günlük ritim korunur (proje sahibi kararı) |
| Çarpım şifreleri (`carpim_deneme_log`) | 20 adım | günlük | Temel beceri; pratiği kesmemeli (proje sahibi kararı) |
| Okuma hikâyesi (`okuma_oturumlari`) | 2 oturum | günlük | Ücretsiz 1/gün üstünde fark |
| Meydan okuma (`meydan_okumalar`, davet eden) | 3 | deneme süresi | Çocuklar arası davet için güvenlik freni |
| Deneme sınavı katılımı (`deneme_sinavi_katilimlari`) | 2 | deneme süresi | İki sonuç karşılaştırması gelişim gösterir |
| Günlük meydan okuma | — | — | Günde bir tamamlama zaten doğal sınır; ek sayım yok |

**Sınırlanmaz:** veli paneli ve gelişim raporu, tekrar listesi, karakter koleksiyonu ve ayarlar.

**Kapsam kuralı:** Yalnızca deneme aktifken ve hesap premium değilken uygulanır. Oturumsuz (servis, sunucu) yazımlar sınırlanmaz. Deneme bitince mevcut ücretsiz/premium kuralları geçerlidir.

## 2. Sınıf stratejisi

- Tüm sınıflar için sınır tanımlıdır; başlangıç değerleri eşittir (veri yok).
- Sınıfa özel değer `siniflar.<sınıf>.<özellik>` ile yönetici ekranından girilir. Çocuğun `profiles.sinif` alanı kullanılır.
- Sınıf bazlı sonuç, sınıf içinde en az 30 hane olmadan gösterilmez ve değer değiştirilmez.
- 1–4. sınıf deneme sınavları GÖR-058 notu gereği kapalıdır; bu sınıflarda deneme sınavı sınırı fiilen uygulanmaz.
- "3–4. sınıfta çarpım sınırsız" önerisi **alınmadı**: her sınıf için sınır istendi.

## 3. Premium gating (karar: aç; migration 20261126 içinde, uzakta bekliyor)

- Canlı değer (2026-10-29 okuma): `premium_gating = {aktif: false, ucretsiz_gunluk_soru: 20}`. Ücretsiz taban şu an sınırsız.
- Değerlendirilen seçenekler: (a) kapalı kalsın, (b) `{aktif: true, ucretsiz_gunluk_soru: 20}`, (c) hane bazlı kademe.
- Ajan önerisi: **(b)**. Gerekçe: deneme ile ücretsiz soru sınırı aynı (20) olur, düşüş yalnızca premium maddelerde ve okumada (2 → 1) hissedilir; (a) deneme sonrası sınırsızlaşmayı, (c) backend işi gerektirdiği için reddedildi.
- **Açılış koşulu:** hukuk onayı. Ayrıca salt okunur sayım: 3 veli hesabı var, üçünün de deneme kaydı yok (eski hesaplar). Gating açılırsa bu üç hesap da günlük sınıra girer; hane istisnası veya duyuru gerekir.
- **Durum:** Karar verildi (proje sahibi: hukuk onayı geliştirme aşamasında engel değil). Değer `20261126` içinde; uzakta henüz uygulanmadı.

## 4. Görünürlük (uygulanan)

- Çocuk: deneme başı bilgisi ve sınır dolunca mesaj. Sınır mesajı sunucudan gelir: "Bugünlük {etiket} hakkın doldu. Yarın yeniden açılır." (günlük) / "Bu denemedeki {etiket} hakkın doldu." (deneme penceresi). Kelime Evreni ve okuma ekranları bu metni gösterir.
- Veli: üyelik sayfasında her çocuk için "Ücretsiz deneme" kartı (`DenemeDurumuKarti`): bitiş tarihi, kalan gün, deneme boyunca sınırlar, "Kart bilgisi istenmez. Otomatik ücret alınmaz." ve T-3 uyarısı. Deneme bitince: bitiş tarihi, "Ücret alınmadı", "İlerleme verisi ve tekrar listesi açık kalır."
- Çocuk ana ekranında kalan hak satırı yok; sayaç yalnız sınırda görünür.
- Yönetici: Ayarlar sayfasında "Deneme sınırları" kartı (masaüstü): varsayılan ve sınıfa özel değerler, pencere seçimi, doğrulamalı kayıt.

## 5. Hukuk metinleri (veli, tr; hukuk onayı bekliyor)

- **Deneme başı:** "Ücretsiz denemeniz başladı. {gun} gün boyunca çocuğunuz günde en fazla {gunluk_soru} soru çözebilir. Kart bilgisi istenmez. Otomatik ücret alınmaz."
- **T-3:** "Ücretsiz denemeniz {bitis_tarih} tarihinde sona erecek. Otomatik ücret alınmaz. Devam etmek isterseniz planı kendiniz seçersiniz; ödeme ekranında tutarı görüp onaylarsınız."
- **Bitiş:** "Ücretsiz denemeniz {bitis_tarih} tarihinde sona erdi. Ücret alınmadı." + "Çocuğunuzun ilerleme verisi ve tekrar listesi açık kalır."
- Bitiş metninde ücretsiz plan kotası cümlesi **yok**: gating kapalıyken o cümle yanlış olur. Gating kararı verilince eklenir.
- Metinlerin tr ve en karşılıkları `veli-trial.{tr,en}.json` ve `yonetim-deneme.{tr,en}.json` içindedir.

## 6. Ölçüm olayları (önerilen, henüz gönderilmiyor)

`deneme_baslatildi {hane_id, gun}`, `deneme_sinir_gosterildi {hane_id, sinif, ozellik, pencere, yuzey}`, `deneme_sinir_doldu {hane_id, sinif, ozellik, pencere}`, `deneme_bitis_yaklasti {hane_id, kalan_gun}`, `deneme_bitti {hane_id}`. Çocuk adı ve konum yok. Çocuk yüzeyi olayları PostHog'a gitmez.

## 7. Açık kalanlar

1. `20261126` ve web/mobil deploy: proje sahibi onayı.
2. `premium_gating` kararının uygulanması: hukuk onayı + onay.
3. Çocuk ana ekranında kalan hak ve deneme durumu kartı (mobil): tasarlandı, kodlanmadı.
4. Mobil: çarpım ve meydan okuma ekranları sınır hatasını özel göstermiyor (bu ekranların Flutter tarafı yok veya genel hata kullanıyor).
5. Deneme bitince deneme sınavlarının kapanması: metinde var, koda yok (sınav kapısı ücretsiz plan için tanımlı değil).

## 8. Güncel durum (2026-10-29, son)

- Uzak DB: `20261125000000` ve `20261126000000` uygulandı ve doğrulandı (20/20, premium_gating açık, görünürlük RPC'si, yönetici okuma).
- Uzak DB: `20261127000000` (deneme sınavı kapısı: süresi bitmiş ya da ücretsiz hanede P0403) proje sahibinin onayıyla uygulandı ve doğrulandı.
- Web: Vercel production'a deploy edildi (`web-panel` 0.4.0 sürüm numarası, master tabanlı snapshot + bu turun dosyaları). Tip denetimi temiz.
- Mobil: çocuk "Ücretsiz deneme" kartı (profil), meydan okuma ve kelime sınır metinleri, sürüm 1.4.0+6. Analiz temiz. İmzalı yayın için `key.properties` yok; mağaza yüklemesi yapılmadı.
- Çarpım şifreleri: mobil uygulamada çağıran ekran yok (`submit_cipher_answer` yalnız model); sınır sunucuda hazır, çocuk arayüzü yok.
- Açık kalan: sürüm etiketleri (`app-v1.4.0`, `panel-v0.4.0`) master'a birleştirme sonrası.