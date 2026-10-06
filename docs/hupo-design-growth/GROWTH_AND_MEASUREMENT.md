# Hupo değer, kanıt ve ölçüm rehberi
## Veli mesaj matrisi
| İhtiyaç | Ürün faydası | Gösterilecek kanıt | Eylem |
|---|---|---|---|
| Düzenli pratik | Küçük görevlerle çalışmayı desteklemek | Gerçek günlük görev/demo | Soruların nasıl çalıştığını gör |
| Eksik konuyu görmek | Konu bazlı tekrar rehberi | Etiketli örnek rapor veya gerçek veri | Veli panelini incele |
| Dijital ortamda güven | Yaşa uygun kontrollü kullanım | Uygulanan veri/erişim/iletişim süreçleri | Güvenlik yaklaşımını oku |
| Ücretin karşılığını görmek | Net kapsam ve yönetilebilir üyelik | Gerçek entitlement ve plan karşılaştırması | Planları karşılaştır |

## Funnel
Kaynak → fayda/demo → kayıt → ilk tamamlanan öğrenme oturumu → veliye anlamlı ilerleme → plan → checkout → doğrulanmış ödeme → devam eden öğrenme.
Bu süreç öneridir; mevcut anonim kullanım/kayıt/veli ilişkilendirme mimarisine uyarlanmalıdır. Ücretsiz veya kart gerektirmeyen kullanım varmış gibi tasarlama.

## Kanıt kaydı
Her canlı iddia için: iddia, kaynak/URL veya iç rapor, tarih, hedef kitle, kapsam, izin durumu, onaylayan, sona erme/gözden geçirme tarihi, yayın durumu. Kaynak yoksa taslak/not olarak tut; canlı kanıt bloğunu gizle. “KVKK uyumlu”, “bilimsel olarak kanıtlandı”, “resmî okul partneri” ifadelerini doğrulama olmadan yayımlama.

## Event önerileri
Mevcut event adlandırması varsa onu koru. Aşağıdaki isimler öneridir.
| Event | Ne zaman | Ölçüm notu |
|---|---|---|
| marketing_cta_clicked | CTA çalıştırıldığında | surface, campaign, destination |
| signup_completed | Hesap gerçekten oluştuğunda | Çift sayımı önle |
| learning_session_completed | Görev oturumu tamamlandığında | question_count, topic_ref; soru metni/isim yok |
| parent_gate_entered | Veli kapısı açıldığında | parent_verified anlamına gelmez |
| parent_report_viewed | Gerçek rapor açıldığında | sample_count / period |
| pricing_viewed | Planlar görüntülendiğinde | price_version / surface |
| checkout_started | Checkout gerçekten oluştuğunda | plan_ref; payment secret yok |
| purchase_confirmed | Sunucu ödeme doğrulaması sonrası | idempotent işlem referansı; analytics erişimi sınırlı |
| review_session_completed | Tekrar oturumu tamamlandığında | learning outcome ile ayrı ölç |
Client tıklaması ödeme başarısı değildir. Deneyim eventlerini mevcut veri minimizasyonu/izin modeliyle uygula; isim, e-posta, serbest cevap, çocuk kimlik bilgisi ve hassas veriyi analytics'e taşıma.

## Metrik tanımları
- Activation adayı: yeni öğrencinin ilk tamamlanmış anlamlı öğrenme oturumu. Oturum kapsamı ve zaman penceresini deneyden önce tanımla.
- Conversion: aynı tanımlı cohort ve penceredeki uygun velilerden doğrulanmış ilk ücretli üyeliğe geçenler / uygun veliler. Pay/payda ve pencereyi raporda belirt.
- Retention: cohort ve dönüş davranışı (tamamlanmış öğrenme oturumu) açık olmalı; yalnızca uygulama açmakla eşitleme.
- Learning gain: geçerli başlangıç/sonuç ölçümü olmadan “öğrenme artışı” sayısı üretme. Örnek azsa veri yetersiz etiketi kullan.
- North Star adayı: haftalık anlamlı öğrenme ilerlemesi gösteren aktif öğrenci; ölçüm geçerli değilse tamamlanmış öğrenme/tekrar oturumu geçici proxy olarak, açık etiketle kullanılabilir.
- Gelir: brüt/net, tahsilat, iade, para birimi ve dönemi ayır. MRR'ı yıllık tahsilat tutarıyla eşitleme.

## Deney şablonu
Hipotez / segment / değiştirilen tek ana unsur / ana metrik / öğrenme ve kullanıcı güveni koruma metriği / baseline / örneklem ve süre yöntemi / durdurma ve karar kuralı / sonuç ve sınırlılıklar.
Yeterli trafik yoksa yapay A/B sonucu üretme; önce görev temelli küçük kullanılabilirlik incelemesi ve baseline ölçümü öner. Çocuk öğrenme akışına satış deneyi koyma.
