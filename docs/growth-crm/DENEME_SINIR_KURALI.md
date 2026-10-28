# Kartsız ücretsiz deneme: uygulama içi sınırlar

- **Tarih:** 2026-10-29
- **Durum:** Veritabanı uygulandı (uzak DB, migration `20261125000000`). Arayüz (veli/çocuk mesajları) yapılmadı. Hukuk metinleri onaysız.
- **Kaynak:** Proje sahibinin kararı (14 gün deneme, deneme sırasında her özellikte sınır). Sınır değerleri growth ajanının başlangıç hipotezidir; veri yoktur.
- **Teknik karşılık:** `app_settings.deneme_sinirlari` (yönetici: `admin_set_deneme_sinirlari`), sayım özelliğin kendi tablosundan, sınır dolunca `P0402`.

## 1. Sınırlar

| Özellik | Sınır | Pencere | Gerekçe |
|---|---|---|---|
| Soru çözme (`answer_events`) | 20 | günlük (İstanbul) | Ücretsiz taban ile aynı; alışkanlık sürer |
| Kelime Evreni (`kelime_denemeleri`) | 30 cevap | günlük | Tadım verir, günlük ritim korunur |
| Çarpım şifreleri (`carpim_deneme_log`) | 40 adım | günlük | Temel beceri; pratiği kesmemeli |
| Okuma hikâyesi (`okuma_oturumlari`) | 2 oturum | günlük | Ücretsiz 1/gün üstünde fark |
| Meydan okuma (`meydan_okumalar`, davet eden) | 3 | deneme süresi | Çocuklar arası davet için güvenlik freni |
| Deneme sınavı katılımı (`deneme_sinavi_katilimlari`) | 2 | deneme süresi | İki sonuç karşılaştırması gelişim gösterir |
| Günlük meydan okuma | 1 | günlük | Doğal sınır (günde bir tamamlama); ek sayım yok |

**Sınırlanmaz:** veli paneli ve gelişim raporu (satın alan velinin değeri), tekrar listesi (öğrenmenin çekirdeği), karakter koleksiyonu ve ayarlar.

**Kapsam kuralı:** Sınırlar yalnızca deneme aktifken ve hesap premium değilken uygulanır. Oturumsuz (servis, sunucu) yazımlar sınırlanmaz. Deneme bitince mevcut ücretsiz/premium kuralları geçerlidir.

## 2. Sınıf stratejisi

- Tüm sınıflar (3–8) için sınır tanımlıdır. Başlangıç değerleri eşittir: veri yok, tek mesaj sade kalır.
- Sınıfa özel değer `siniflar.<sınıf>.<özellik>` ile yönetici tarafından ayarlanır. Çocuğun `profiles.sinif` alanı kullanılır.
- Sınıf bazlı sonuç, sınıf içinde en az 30 hane olmadan gösterilmez ve değer değiştirilmez.
- 1–4. sınıf deneme sınavları GÖR-058 notu gereği kapalıdır; bu sınıflarda deneme sınavı sınırı fiilen uygulanmaz.
- Ajanın önerdiği "3–4. sınıfta çarpım sınırsız" seçeneği **alınmadı**: proje sahibi her sınıf için sınır istedi.

## 3. Açık kararlar

1. **Canlı `premium_gating`:** Kod varsayılanı kapalıdır. Kapalıysa ücretsiz kullanıcı sınırsız çözer; deneme sırasında sınır uygulanır. Deneme bitince sınırsız olmak ürün açısından bir "düşüş" hissi yaratabilir. Karar: proje sahibi.
2. **Sınır ile ücretsiz taban:** Ajan "deneme sınırı ücretsiz sınırın altına düşmemeli" dedi. Ücretsiz taban kapalı gating'de sınırsızdır; bu kuralı uygulamak mümkün değildir. Proje sahibinin açık isteği (sınır olsun) öncelikli alındı.
3. **Görünürlük:** Sınır dolunca çocuk ve veli ne görecek? Şu an yalnızca sunucu hatası döner; mobil ekranlar bu hatayı genel metinle gösterir. Arayüz metinleri yazılmadan kural şeffaf değildir.
4. **Hukuk:** "Otomatik ücret alınmaz" ve deneme bitiş bildirimi metinleri hukuk onayı bekler (`decisions.md`, 2026-10-28).

## 4. Metin taslakları (onaysız)

- Veli, deneme başı: "Ücretsiz denemeniz başladı. {gun} gün boyunca çocuğunuz günde en fazla {gunluk_soru} soru çözebilir. Otomatik ücret alınmaz. [hukuk onayı bekliyor]"
- Çocuk, deneme başı: "Denemen başladı! {gun} gün boyunca her gün {gunluk_soru} soruya kadar çözebilirsin."
- Çocuk, soru sınırı: "Bugünlük {gunluk_soru} soru tamam. Yarın yeni sorularla devam edebilirsin. Tekrar listen açık."
- Çocuk, deneme sınavı sınırı: "Bu denemedeki sınav hakkın doldu. Bu özellik için velinle devam et."
- Veli, bitiş (T-3): "Ücretsiz denemeniz {bitis_tarih} tarihinde bitiyor. Otomatik ücret alınmaz. [hukuk onayı bekliyor]"

Karanlık desen kuralı: sayaç yalnız gerektiğinde görünür, "son gün" dili yok, sınır dolunca çözüm "yarın".

## 5. Ölçüm olayları (önerilen, henüz gönderilmiyor)

`deneme_baslatildi`, `deneme_sinir_gosterildi {ozellik, sinif, pencere}`, `deneme_sinir_doldu {ozellik, sinif, pencere}`, `deneme_bitis_yaklasti {kalan_gun}`, `deneme_sonu_plan_acildi`. Yalnız hane kimliği ve sınıf; çocuk adı yok.
