---
name: hupo-platform-review
description: "Hupolingo mobil, web, veli paneli ve admin tasarımlarını platform davranışı, erişilebilirlik, performans, tüm ekran durumları ve gerçek görevlerle değerlendirir. Uygulama teslimi, responsive kontrolü, admin toplu yükleme veya tasarım kalite incelemesinde kullan."
---
# Hupo platform tasarımı ve kalite incelemesi
## İş akışı
1. Mevcut stack, ekran sözleşmesi, ilgili kod ve komutları oku. Mobil web ile native uygulamayı ayır; repo dili ve araçlarını koru.
2. Görevi bir kullanıcı gibi yürüt: giriş, eylem, geri bildirim, sonuç, geri dönüş. Loading, empty, success, validation error, network error, disabled ve permission durumlarından geçerli olanlarını incele.
3. Web'de 360/390, 768 ve 1280 genişliklerinde; native'de mevcut emülatör/cihaz boyutları ve güvenli alanlarla kontrol et. Uzun Türkçe metin, klavye, scroll, yön değişimi ve büyük yazıyla dene.
4. Çalışan ekranların görüntülerini al; yalnızca kod okuyarak görsel onay verme. Tarayıcı/cihaz aracı yoksa bu sınırı yaz; statik incelemeyle doğrulanmış maddeleri ayır.
5. Erişilebilirlikte etiket, odak, klavye, okuma sırası, contrast, text scaling, renk dışında işaret ve reduced motion kontrol et. Otomatik taramayı manuel görev kontrolünün yerine sayma.
6. Mevcut uygun build/lint/test komutlarını çalıştır. Kritik davranışta hedefli regresyon kontrolü yap. Çalıştırılmamış testi başarılı diye raporlama.
7. Sorunları P0/P1/P2 olarak, dosya/ekran, tekrar adımı, kullanıcı etkisi ve düzeltmeyle yaz. Uygulama yetkisi varsa kapsam içindeki sorunları düzelt ve ilgili kontrolü tekrarla.

## Mobil
- Mevcut native platform kılavuzlarını kontrol et; hedef dokunma alanı iOS'ta yaklaşık 44 pt, Android'de 48 dp yaklaşımını platforma göre uygula. Çocukta daha geniş alan tercih et.
- Safe area, geri hareketi, klavye açılması, küçük ekran ve bağlantı kopmasını tasarla. Test etmediğin cihaz uyumluluğunu garanti etme.
- Cevap gönderiminde çift tıklama koruması; bekleyen, yeniden gönderilen ve sunucunun onayladığı durumları ayrı göster.
- XP/ödül sadece sunucu doğrulamasıyla kesinleşsin. Client görseli ile gerçek bakiye farklıysa sessizce ikinci ödül oluşturma.

## Web ve veli paneli
- Klavye navigasyonu, görünür focus, dialog focus yönetimi ve grafiğe metinsel alternatif sağla.
- Raporda tarih aralığı, örnek sayısı ve ölçüm tanımı görünür olsun. Yanlış cevapları damgalayıcı “başarısız çocuk” etiketine dönüştürme.
- Animasyon/görsel yükünü ölç; düşük cihazda gereksiz sürekli efektleri azalt. Performans iddiasına ölçüm/cihaz/tarih ekle.

## Admin
- İçerik akışı: Draft → Review → Approved → Published → Archived. Geçişleri rol ve backend yetkisiyle eşleştir; yalnızca gizlenen buton güvenlik sağlamaz.
- Toplu yükleme: şablon → yükle → kolon eşleştir/önizle → satır hataları → duplicate kontrolü → taslak → editör onayı → yayın. Kısmi başarı/başarısızlık sayılarını açık göster; tekrar gönderimde duplicate yaratma.
- Büyük tabloda arama, filtre, pagination, seçili öğe sayısı ve filtre değişiminde seçim davranışı tasarla. “Tümünü seç” geçerli sayfa mı bütün sonuç mu açık olsun.
- Yayımlama, silme ve iade gibi işlemlerde etkiyi ve geri alınabilirliği belirt. Audit kaydı ve geri alma yalnızca sistem destekliyorsa göster.
- Sosyal kanıt CMS'sinde kaynak, izin, onay ve son geçerlilik kontrolü; kanıtsız kayıt yayına çıkmasın.

## Çıktı
PASS / NEEDS_FIX / BLOCKED kararı; incelenen yüzeyler; bulgular; düzeltmeler; gerçek kontrol komutları ve sonuçları; görsel kanıt; doğrulanmayan maddeler. P0/P1 açıkken tamamlandı deme. Görsel uyum, ürün faydası ve ticari başarıyı ayrı değerlendir.

## Ortak bağlam
Proje köküne göre `docs/hupo-design-growth/PROJECT_CONTEXT.md` dosyasını oku. İlgili mevcut brief, kod ve tasarım kararlarını kontrol et; repo dışındaki geçmiş konuşmalara erişimin varmış gibi davranma. Eksik ama kritik olmayan bilgiyi varsayım olarak işaretleyerek ilerle. Güncel kullanıcı talimatını esas al; çelişkileri kısa kaydet.
Talep yalnızca analiz ise uygulama kodunu değiştirme. Uygulama istenmişse mevcut stack ve bileşenlerle çalış. Kaynak dosyaları, çalıştırılan kontrolleri ve doğrulanamayan noktaları raporla. Başarı/gelir/öğrenme etkisi garantisi verme.
