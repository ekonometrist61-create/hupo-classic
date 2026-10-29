# Soru Uzmanı V3 + 2026 bağlam temelli MEB + OYSS — sınav motoru

## Kaynak ve örneklem sıralaması
(1) yürürlükteki **resmî ders programı/öğrenme çıktısı**, (2) resmî yıl/dönem **konu-soru dağılımı ve okul senaryosu**, (3) ilgili sınıf-yıl MEB **örnek yazılı soruları**, (4) resmî İOKBS/LGS kitapçığı yalnız **ilgili mod** için, (5) yayınevi soru bankası ancak izin ve metadata/sorunun *anatomisini* çıkarmak için. Kitapçıklardan metin ve görsel klonlaması yasak.

## Blueprint-first
`curriculum_version × grade × subject × unit/theme × verified_learning_outcome × process_skill × cognitive_action × modality × item_type × expected_difficulty × situation/context × assessment_mode`.

- Zorluk: `editor_expected_difficulty` kolay/orta/zor, ölçülmüş güçlük `p_correct` ve ayırtedicilik ayrı. Görülme sıklığı, sınıf başarı oranı ve popülerlik ayrı alanlar. Kalibrasyonsuz dağılımları «MEB gerçek oranı» diye sunma.
- Soru anatomisi: uyarıcı türü, verilen veri, kök, istenen eylem, yanıt formatı, çoklu adım, dil yükü, temsil yükü, olası yanlış kavram, kanıt, çözüm yol(lar)ı.
- Bağlam işlevselliği: Metni/görseli çıkartınca doğru cevap hâlâ bulunabiliyorsa gerçek bağlam değildir. Ancak her soru bağlamlı olmak zorunda değil; temel beceri ölçen kısa madde de geçerlidir.
- Çeldirici atlası: işlem/birim, neden-sonuç tersliği, parçada örtük olmayan çıkarım, veri dizisi karışması, kavram sınıfı karışması, öncül okuma, grafikte eksen-hücre kaydırma. Rastgele yanıltma yok; tek, savunulabilir doğru.
- Açık uçlu: 0/1/2/3 veya probleme uygun 0..n basamaklı analitik rubrik, yanıt örnekleri ve alternatif doğru yollar; soru metninde hangi kanıtın istendiği açık.

## Sınav modu
| Mod | Kullanım | Kaynak/denetim |
|---|---|---|
| `formative` | Günlük düşük riskli geri çağırma | Öğrenme hedefi, kısa dönüt |
| `school_written` | Okul zümresinin seçtiği senaryo | Yıl, dönem, ders, okul seçimi bilinmeli |
| `oyss_style` | 2026–27 5–7 kapsamı hakkında MEB 20.10.2026 duyurusu | OYSS gerçekten yetkili öğretmen uygulamasıdır; Hupo örnek taslak verebilir; MEB havuzu diye sunamaz |
| `iokbs_style` | 5–8 bursluluk sınavına hazırlık | Resmî yıl kitapçıkları ve müfredat |
| `lgs_style` | 8. sınıf merkezi sınava hazırlık | 8. sınıf yürürlükteki program ve ilgili yıl kılavuzu |

**Önemli:** 20 Ekim 2026 MEB duyurusuna göre OYSS, 2026–27 5,6,7 sınıf ortaokul derslerinde başlayacak; **7. sınıf İngilizce bu uygulamanın dışında**. Seçili senaryoda iki öğrenme çıktısına yönelik ikişer değil **toplam iki açık uçlu soru** ve rubrik öğretmen tarafından hazırlanıyor; diğer sorular öğretmenlerce havuzdan seçiliyor. Bu, Hupo'nun dışarıdan resmî OYSS'yi yönettiği anlamına gelmez.

## Çift bağımsız QA
- Pedagoji uzmanı: program, bilişsel eylem, dil, yanıltıcı öge, çeldirici adaleti.
- Alan uzmanı: bilimsel/sayısal doğruluk, birimler, seçenek benzersizliği, ispat ve alternatif çözüm.
- Ürün editörü: mobil sunum, erişilebilirlik, telif, yazım, test verisi, sürümleme.
- İnsan kararı: `draft → editorial_review → curriculum_verified → piloted → approved → published`.

## Saha analizi
Yalnız **gerçek öğrenci cevapları** ile doğru cevap oranı (`p_correct`), yanılgı dağılımı, gerekçe rubriği uyumu, süre, tekrar kazancı; yeterli ve uygun örneklem varsa ayırtedicilik. Kayıp veri ve yanıt ipuçlarını ayrıca raporla. Gözlemsel ilişkiyi nedensel öğrenme etkisi diye sunma. Öğrenci verisini mümkün olduğunca takma isimli, asgari ve izinli tut.
