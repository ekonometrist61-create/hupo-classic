# Araştırma Durumu — 4. sınıftan 5. sınıfa geçiş sınavları

## Kritik doğruluk kararı

Bu proje için hedeflenen içerik **çıkmış sınav soruları** olmalıdır. İnternette bulunan genel 4. sınıf soru bankaları, ders kitabı etkinlikleri ve deneme soruları çıkmış proje okulu sınavı olarak etiketlenemez. Kaynağı, sınav yılı ve okul adı bulunmayan maddeler bu nedenle `taslak_ornek` statüsünde tutulur ve uygulama veritabanına onaylı soru olarak aktarılmaz.

## Araştırma bulgusu

Türkiye'de 4. sınıftan 5. sınıfa geçiş yapan tüm proje okulları için merkezi, tek tip ve MEB tarafından yayımlanan bir sınav arşivi tespit edilmedi. Bu sınavlar okul/kurum bazında değişebildiği için kaynak kaydı en az şu alanları içermelidir:

- Okulun tam adı
- Sınav yılı ve mümkünse sınav tarihi
- Kitapçık veya resmî okul duyurusu URL'si
- Soru kitapçığı ile cevap anahtarının aynı sınava ait olduğuna dair kanıt
- Sorunun kitapçıktaki sayfa/soru numarası
- İçerik lisansı veya kamuya açık yayımlanma durumu

## Güvenilir başlangıç kaynakları

- [MEB 4. sınıf İngilizce Türkiye Yüzyılı Maarif Modeli](https://tymm.meb.gov.tr/ingilizce-dersi-temel-egitim/unite/639) — kazanım ve kapsam doğrulaması için; çıkmış sınav kaynağı değildir.
- [MEB 2025-2026 eğitim ve öğretim yılı genelgesi](https://www.meb.gov.tr/bakan-tekinin-imzasiyla-illere-giden-2025-2026-egitim-ve-ogretim-yilina-iliskin-is-ve-islemler-konulu-genelge-yayimlandi/haber/38072/tr) — eğitim yılı ve müfredat bağlamı için; soru kaynağı değildir.
- [MEB/ODSGM kazanım testleri sayfası](https://odsgm.meb.gov.tr/www/7-sinif-ingilizce-kazanim-testleri-2022-2023/icerik/852) — resmî çalışma materyali örneği; 4. sınıftan 5. sınıfa proje okulu sınavı olarak kullanılmamalıdır.
- [MEB BİLSEM duyurusu](https://orgm.meb.gov.tr/www/2025-bilim-ve-sanat-merkezleri-muzik-yetenek-alaninda-bireysel-degerlendirmeye-alinacak-ogrenciler-icin-tanitim-videosu-yayimlandi/icerik/3197) — BİLSEM sürecinin ayrı bir değerlendirme olduğunu gösterir; proje okuluna geçiş sınavı değildir.

## Mevcut dosyaların statüsü

Soru havuzunda şu an 6 ders dosyası bulunur; hepsi 4. sınıf kazanımlarına uygun, proje okulu seçme sınavı tarzından **mülhem örnek soru tipleridir**. Çıkmış soru değildir ve her dosyanın üst kısmında bu durum açıkça belirtilmiştir. Her maddenin cevabı tek ve kesin olacak şekilde denetlenmiştir.

| Dosya | Ders | Madde |
|---|---|---|
| `matematik-bolum-1.md` | Matematik | 50 |
| `turkce-bolum-1.md` | Türkçe | 20 |
| `fen-bilimleri-bolum-1.md` | Fen Bilimleri | 20 |
| `sosyal-bilgiler-bolum-1.md` | Sosyal Bilgiler | 20 |
| `din-kulturu-bolum-1.md` | Din Kültürü ve Ahlak Bilgisi | 20 |
| `ingilizce-bolum-1.md` | İngilizce | 20 |

Bu maddeler `taslak_ornek` statüsündedir; doğrulanmış kaynak (okul adı, sınav yılı, kitapçık URL'si) eklenmeden uygulama veritabanına `onaylandi` olarak yüklenmemelidir.

## Sonraki veri toplama kuralı

Yeni bir madde ancak şu üç kontrolden sonra `kaynakli_taslak` yapılabilir:

1. Soru görseli/PDF'si veya okulun resmî yayımladığı metin bulunur.
2. Cevap anahtarı ya da bağımsız ikinci doğrulama bulunur.
3. Araştırmacı, denetçi ve pedagojik açıklama alanları kaynak kaydıyla birlikte tamamlanır.

Bu kanıtlar olmadan 500 sayıya ulaşmak için soru üretmek, kullanıcının “soruları yeni üretmeyeceğiz” şartını ihlal eder.
