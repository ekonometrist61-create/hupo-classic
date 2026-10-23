# Okuma hikâyeleri: Ajan A / Ajan B denetim talimatı (2026-10-23)

Kapsam: 20261077 migration'ındaki 45 hikâyenin yeni TASLAK sürümü (HR-001…HR-047, HR-011 ve HR-020 hariç).
12 hikâye (HR-002, 009, 014, 015, 016, 018, 021, 022, 025, 030, 031, 032) şu an test yayınında; yeni sürümleri de bu denetimden geçer.

Girdi: her hikâye düz metin olarak hazırlanmıştır (`denetim-girdi/HR-XXX.txt`). Metin, paketteki sayfaları, [KELİME], [DEYİM CÜMLESİ], [İŞARET], [YOLDAŞ] işaretlerini ve soru/sözlük alanlarını içerir.

## Yayın kapısı ile ilişki

Panelde yayın için Ajan A ve Ajan B "pass" olmalı ve insan kararı "approved" olmalıdır. Bu rapor yalnız Ajan A ve Ajan B kararını verir. İnsan okuması ve onayı bu denetimin yerini tutmaz.

## Kararlar

- `pass`: Kritik ve yüksek bulgu yok. Yalnız düşük ya da orta düzeyde, metni bozmadan düzeltilebilir notlar var.
- `review_needed`: Yüksek ya da birden fazla orta bulgu var; ya da doğrulanamayan bir iddia, uzman ya da yazar teyidi gerektiren bir nokta var.
- `fail`: Kritik bulgu var. Olgusal hata, metinle çelişen cevap anahtarı, çocuğa uygun olmayan içerik, güvenlik riski veya çocuk öğrenmesini yanlışa yönlendiren bir iddia var.

## Ajan A: olgu ve doğruluk

Sadece doğruluğa bak. Edebî kaliteyi değerlendirme; o Ajan B'nin işi.

1. Metindeki olgusal iddialar (bilim, tarih, coğrafya, kültür, hayvan ve bitki bilgisi, sağlık, güvenlik) doğru mu? Yanlış ya da abartılı olanları, doğrulanamayanları ayrı listele.
2. Sağlık ve güvenlik tavsiyesi var mı? Varsa yanlış ya da kişiyi tehlikeye atabilecek bir yönlendirme içeriyor mu?
3. Sözlük anlamları (`sozluk.girdiler[].anlam`) doğru ve sınıf düzeyine uygun mu? Deyim cümleleri, deyimin gerçek anlamıyla uyuşuyor mu?
4. Sorular: Cevap anahtarı (`dogru`) metinle destekleniyor mu? `dayanak_sayfa` gerçekten o sayfayı mı gösteriyor? Açıklama doğru mu? Çeldiriciler kesinlikle yanlış mı? Birden fazla doğru şık var mı?
5. Kurgu içi tutarlılık: olay sırası, karakter adları, sayfalar arası çelişki, işaretlerin (İŞARET, YOLDAŞ) metinle uyumu.
6. `kanit_duzeyi` ve `ogrenme_hedefleri` ile metnin iddiaları arasında çelişki var mı?

## Ajan B: uygunluk ve kalite

Çocuğa uygunluk ve kalite üzerine değerlendir.

1. Sınıf uygunluğu: cümle uzunluğu, sözcük yükü, konu ve kavram düzeyi `sinif_alt`–`sinif_ust` ve `okuma_bandi` ile uyumlu mu?
2. Güvenlik ve içerik: korku, şiddet, yetişkin temaları, ayrımcı dil ya da stereotip (cinsiyet, etnik köken, meslek), kişisel veri ya da gerçek iletişim bilgisi. `yetiskin_uygun` alanı doğru mu?
3. Vaaz ve öğreticilik: ahlak dersi diyaloğa ya da anlatıma yapışmış mı? Karakterler düşünce taşıyıcısı olmaktan çıkıp "bilgi veren" konuşuyor mu?
4. Edebî kalite: diyalog doğal mı, karakterler ayırt edilebiliyor mu, tekrar ve gereksiz açıklama var mı, sonu tatmin ediyor mu? Türkçe dil bilgisi ve yazım hataları.
5. Soru kalitesi: beceri dağılımı mantıklı mı, şık uzunlukları dengeli mi, cevap metne bakarak bulunabiliyor mu, soru tekrarları var mı?
6. Etiket tutarlılığı: `ana_sinif`, `okuma_zorlugu`, `kavram_zorlugu`, `ilgi_egilimi`, `deger_anahtarlari`, `maarif` alanları içerikle uyumlu mu?

## Rapor biçimi

Her denetçi yalnız kendi raporunu yazar. Rapor yolu:
`docs/okuma-entegrasyon/denetim/2026-10-23/HR-XXX-ajan-a.md` veya `HR-XXX-ajan-b.md`

```
# HR-XXX · <başlık> · Ajan A (olgu ve doğruluk) | Ajan B (uygunluk ve kalite)
Karar: pass | review_needed | fail
Özet: <en fazla 2 cümle>
Bulgular:
- [kritik|yüksek|orta|düşük] <yer: sayfa / soru / alan>: <sorun>. Alıntı: "<kısa alıntı>". Öneri: <ne değişmeli>.
Doğrulanamayan iddialar: <liste ya da "yok">
Güçlü yanlar: <en fazla 2 madde>
```

Kurallar:
- Hikâye, paket ya da veritabanı dosyalarını değiştirme. Yalnız kendi rapor dosyanı yaz.
- Başka denetçinin raporunu okuma. Bağımsız çalış.
- Emin olmadığın bir olgusal iddiayı "doğrulanamadı" diye işaretle; uydurma.
- WebSearch en fazla 3 kez; yalnız gerçekten belirsiz bir olgu için.
- Son mesajın kısa olsun: yalnız `HR-XXX A|B: <karar>; kritik N, yüksek N, orta N, düşük N; rapor <yol>`.
