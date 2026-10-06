---
name: hupo-ux-strategy
description: "Hupolingo için kullanıcı araştırması, ürün konumlandırması, öğrenci ve veli yolculukları, onboarding, sınav hazırlığı, bilgi mimarisi ve ekran hedeflerini tanımlar. Yeni özellik, kullanıcı akışı, PRD, ana ekran veya veli paneli planlanırken kullan."
---
# Hupo UX stratejisi
## İş akışı
1. Yüzeyi belirle: öğrenci, veli, public satış sitesi veya admin. Yaş/sınıf, görev, giriş noktası, cihaz ve temel engeli yaz.
2. `docs/hupo-design-growth/SCREEN_CONTRACT.md` şablonuyla ekran sözleşmesi oluştur. Bir ana eylem seç; ikincil eylemleri açıkça geriye al.
3. Kullanıcı ihtiyacını özellikten ayır. Her özellik için kullanıcı faydasını bir cümleyle yaz; mevcut verilerle desteklenen bilgi, varsayım ve araştırma sorusunu ayrı tut.
4. Yolculuğu giriş → görev → sonuç → sonraki adım olarak tasarla. Geri dönüş, oturumu sürdürme, vazgeçme ve bağlantı kesilmesi yollarını ekle.
5. Yeni görsel yön gerekiyorsa iki kısa alternatif üret; hedef kitle, bilişsel yük, marka ve uygulanabilirlikle seçimini gerekçelendir. Küçük düzeltmelerde alternatif töreni yapma.
6. Üç-beş gözlenebilir kabul kriteri tanımla. Kullanıcının görevi tamamlamasını ölç; buton tıklamasını tek başına değer olarak sayma.
7. Mevcut TASKS.md fazlarına bağla; kapsam dışında kalan işleri açıkça yaz. Özellikleri sırf brief'te var diye tek seferde uygulama.

## Hupo yolculukları
- Öğrenci: sınıf/konu → kısa görev → soru → ipucu/açıklama → tekrar → öğrenme sonucu → ödül/sonraki görev. İlk oturumda uzun form, tüm koleksiyon veya ödeme gösterme.
- Veli: faydayı anlama → gerçek deneyimi görme → uygunluk kontrolü → hesap/çocuk ilişkisi → ilk anlamlı rapor → plan değerlendirmesi. Deneme süresi ve ücretsiz kapsamı yalnızca gerçek yapı destekliyorsa belirt.
- Ankara proje ortaokulu hazırlığı: 4→5 geçişi ilk odak olarak ele al; 8–14 geniş ürün vizyonunu koru. Okul adı kullanmak resmî iş birliği veya sınav içeriği lisansı anlamına gelmez. Sınav tarihi/formatı ve güncel müfredatı kaynaklardan doğrula; bulunamazsa bilinmiyor yaz.
- Veli raporu: nerede ilerledi → neye tekrar gerekiyor → bugün nasıl destek olabilirim. Deneme verisi veya az örnek varsa kesin yeterlilik sonucu çıkarma.

## Öğrenme ve motivasyon
- XP ve hız ile konu öğrenmesini ayrı göster. Mastery için ölçüm tanımı ve yeterli örnek şartı iste.
- Hatalı cevabı açıklama ve yeniden denemeye bağla; utandırma, seri kaybıyla suçluluk veya çocuğun satın almasını teşvik etme.
- Görevi bitirmeyi ve mola vermeyi destekle. Bildirim sıklığı, sessiz saat ve kapatma tercihini akışa koy.
- Soru sırasında okuma alanını, görseli ve seçenekleri önceliklendir. Hupo yardımcı olsun, cevabı kapatmasın veya ele vermesin.

## Çıktı
Yüzey/hedef; kanıt ve varsayımlar; akış; ekran sözleşmeleri; kapsam; kabul kriterleri; ölçüm planı. Tasarım önerilerini kullanıcı araştırması sonucu diye sunma.

## Ortak bağlam
Proje köküne göre `docs/hupo-design-growth/PROJECT_CONTEXT.md` dosyasını oku. İlgili mevcut brief, kod ve tasarım kararlarını kontrol et; repo dışındaki geçmiş konuşmalara erişimin varmış gibi davranma. Eksik ama kritik olmayan bilgiyi varsayım olarak işaretleyerek ilerle. Güncel kullanıcı talimatını esas al; çelişkileri kısa kaydet.
Talep yalnızca analiz ise uygulama kodunu değiştirme. Uygulama istenmişse mevcut stack ve bileşenlerle çalış. Kaynak dosyaları, çalıştırılan kontrolleri ve doğrulanamayan noktaları raporla. Başarı/gelir/öğrenme etkisi garantisi verme.
