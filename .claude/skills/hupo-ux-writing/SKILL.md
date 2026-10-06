---
name: hupo-ux-writing
description: "Hupolingo için Türkçe marka ve arayüz metinleri, veli pazarlama mesajları, çocuk motivasyonu, CTA, hata/boş durum, bildirim ve abonelik iletişimi yazar. Metin, ton, iletişim veya microcopy talebinde kullan."
---
# Hupo iletişim ve UX yazımı
## İş akışı
1. Hedef kitleyi ve bağlamı seç: çocuk öğrenme, veli pazarlama, veli raporu, admin operasyonu. Kullanıcının o anda bilmesi veya yapması gereken tek şeyi belirle.
2. Gerçek eylem, ürün kapsamı ve ekran durumunu kontrol et. UI metnini kod veya backend'in henüz sunmadığı davranışa bağlama.
3. Kısa, doğal Türkçe yaz; sistem terimlerini kullanıcı diliyle anlat. Aynı eylemin adını tüm akışta koru.
4. Butonları somut eylemle adlandır: “Sorulara başla”, “Tekrar et”, “Önizlemeyi aç”, “Taslağı kaydet”. “Tamam/Gönder” yalnızca anlam açık ise kullan.
5. Hata metninde ne oldu + çözüm + gerekirse verinin korunup korunmadığını belirt. Teknik log veya token gösterme; backend kanıtı olmadan “kaydedildi” deme.
6. Boş durumda neden boş + ilk yararlı eylemi ver. Loading durumunda süre uydurma. Bekleyen/başarısız ödeme ile aktif üyeliği ayrı ifade et.
7. Metinleri mevcut i18n düzenine bağla; Türkçe karakterleri ve çoğulları kontrol et. Uzun başlık, öğrenci adı ve değişken değerleriyle taşmayı dene.

## Hupo sesleri
- Çocuk: sıcak, kısa, cesaretlendirici; bebek dili, küçümseme veya her cümlede emoji yok.
- Veli: açık fayda, somut kapsam, sakin güven. İçerik ve gizlilik süreçlerini gerçekten uygulanıyorsa anlat.
- Admin: kısa, kesin, operasyon odaklı. “Harikasın!” gibi kutlamalar yerine “24 soru taslak olarak oluşturuldu.” gibi doğrulanmış sonuç ver.

## Bağlamsal örnekler
- Yanlış cevap: “Bu kez olmadı. Açıklamaya bakalım, sonra yeniden deneyelim.”
- İpucu: “Önce soruda verilenleri bul.” Konuya uygun gerçek ipucu üret; sırf moral cümlesini ipucu diye sunma.
- Görev tamamlandı: “Görev tamamlandı! Şimdi kısa bir mola verebilirsin.”
- Veri az: “Bu konuda değerlendirme için henüz yeterli soru çözülmedi.”
- Premium kapısı: “Bu özellik için velinle devam et.”
- Bağlantı sorunu: “Bağlantı kurulamadı. Yeniden dene.” Cevabın kaydedilme durumuna göre ek cümle seç.
- Veli hero adayı: “Soru çözme alışkanlığını küçük görevlerle destekleyin.” Alt metin: “Çocuğunuz pratik yapsın; siz ilerlediği ve tekrar etmesi gereken konuları görün.” Bunları sonuç garantisi olarak yorumlama.
- Admin yayımla: “Seçilen 24 soruyu yayımla”. Sayı gerçek seçimden gelsin; hatalı sorular varsa devam eylemi sunmadan düzeltme yolu ver.

## Bildirimler ve abonelik
- Çocuk bildirimi merak/davet taşısın; “Serin bitecek, Hupo üzülüyor” gibi suçluluk dili kullanma.
- Sessiz saat, frekans sınırı ve opt-out ile uyumlu tasarla. Sağlanmayan tercihi metinde vaat etme.
- Abonelikte toplam ücret, dönem, yenileme, deneme bitişi ve iptal sonucunu açık yaz; şartları küçücük dipnota saklama.
- Kanıtlanmayan başarı, kullanıcı sayısı veya uzman onayı yazma. Örnekleri müşteri yorumu gibi biçimlendirme.

## Çıktı
Ekran/durum → nihai metin → eylem hedefi → değişkenler → kısa gerekçe tablosu. Yeni kampanya için en fazla üç anlamlı seçenek; rutin UI için doğrudan tek öneri ver. Metni bağlamdaki görsel yerleşimle birlikte kontrol et.

## Ortak bağlam
Proje köküne göre `docs/hupo-design-growth/PROJECT_CONTEXT.md` dosyasını oku. İlgili mevcut brief, kod ve tasarım kararlarını kontrol et; repo dışındaki geçmiş konuşmalara erişimin varmış gibi davranma. Eksik ama kritik olmayan bilgiyi varsayım olarak işaretleyerek ilerle. Güncel kullanıcı talimatını esas al; çelişkileri kısa kaydet.
Talep yalnızca analiz ise uygulama kodunu değiştirme. Uygulama istenmişse mevcut stack ve bileşenlerle çalış. Kaynak dosyaları, çalıştırılan kontrolleri ve doğrulanamayan noktaları raporla. Başarı/gelir/öğrenme etkisi garantisi verme.
