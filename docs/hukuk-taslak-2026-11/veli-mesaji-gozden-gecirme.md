> Hukuk onayı bekliyor, yayın yok. (GÖR-081 taslağı; mağaza politikası yorumu kesin hüküm değil, risk değerlendirmesidir.)

# "Premium'u veli panelinden açabilir misin?" mesajı

## Bulgu
- Metin: `mobile-app/lib/widgets/veli_mesaji_sheet.dart` satır 9-11, `kVeliMesaji`: "Merhaba, Hupolingo'da bugünkü ücretsiz sorularımı tamamladım. Yarın yeni sorularla devam edebilirim. Premium'u veli panelinden açabilir misin?"
- Gösterildiği yerler: `quiz_screen.dart` satır 154 (günlük kota dolunca "Velime mesaj hazırla"), `membership_card.dart` satır 136, `profile_screen.dart` satır 423.
- Mekanizma: Mesaj yalnızca panoya kopyalanır (`Clipboard.setData`); uygulama içinde fiyat, ödeme sayfası veya bağlantı yok. Kodda yorum: "Çocuk uygulamasında satın alma bağlantısı YOKTUR".
- Dosya yorumu "baskı ya da suçluluk dili kullanılmaz" diyor. Bu mesajda açık baskı dili yok; çocuk adı veya kişisel veri yok.

## Risk değerlendirmesi (kesin hüküm değil)

1. Mağaza ödeme politikaları (Apple 3.1.1 ve 3.1.3, Google Play Ödemeler): Uygulama içinde dış ödeme yoluna yönlendirme, fiyat veya "bunu web'den al" yönlendirmesi risk taşır. Burada yönlendirme uygulama dışına çıkan bir bağlantı değil, çocuğun velisine söyleyeceği bir cümle. Yine de "veli panelinden aç" ifadesi, uygulama içi satın alma yerine web kanalını işaret ediyor. Bir inceleyici bunu "alternatif ödeme yoluna yönlendirme" saymayabilir ama sayabilir; belirsiz. Risk: düşük-orta. Güncel politika metni bu görevde okunmadı (doğrulanmadı), hukuk ve mağaza politikası kontrolü gerekir.
2. Çocuk kategorisi (Apple Kids, Google Aileler Politikası): Çocuğa yönelik uygulamada satın almaya teşvik eden ifadeler ve çocuğun veliyi ikna etmesine yönelik kurgu ("nag" davranışı) hassas bölgedir. "Ücretsiz sorularımı tamamladım, devam edebilmem için Premium aç" çerçevesi çocuğa bir isteği veliye ilettirir. Hedef kitle kararı (13 yaş altı / Kids) henüz verilmemiş (`VERI_GUVENLIGI_VE_GIZLILIK.md` §6). Risk: orta, kategori kararına bağlı.
3. Tüketici hukuku ve çocuğa yönelik ticari iletişim: Çocuğa doğrudan satın alma çağrısı yapılması haksız ticari uygulama ve reklam mevzuatı bakımından hassas olabilir; burada çağrı çocuğa değil veliye yönelik bir ileti, çocuk aracı. Kesin değerlendirme hukuka ait.
4. Marka tutarlılığı: Mesajdaki "Premium" adı ve "veli panelinden aç" ifadesi, ödeme mimarisi kararına (satın alma veli alanında) uyuyor. "Premium" paket adı panelden düzenlenebilir olmalı (paketler kodda sabit olmaz kararı); metin bu adı sabitliyor. Doğrulanmadı: güncel paket adı.
5. Doğruluk: Mesaj "veli panelinden açabilir misin?" diyor; veli panelinde satın alma akışının canlı olduğu doğrulanmadı. Akış yoksa mesaj boşa yönlendirir.
6. Çocuk tarafı metni: Diyaloğun "Velime mesaj hazırla" düğmesi çocuğa kısa ve nötr; bu iyi. Açıklama satırı "Ücretli sürüm kararı velinin" ifadesi karar yetkisini veliye bırakıyor; korunması önerilir.

## Alternatif metinler (mesajdan fiyat, plan adı ve eylem çağrısını çıkarır)

Seçenek A (nötr bilgilendirme, en düşük risk):
"Merhaba, Hupolingo'da bugünkü ücretsiz sorularımı tamamladım. Yarın yeni sorularla devam edebilirim. Uygulamanın üyelik seçeneklerini sen incelemek ister misin?"

Seçenek B (veli kararını öne çıkarır):
"Merhaba, bugün Hupolingo'daki sorularımı bitirdim. Üyelik konusunu senin kararına bırakıyorum. İstersen veli panelinden bilgi alabilirsin."

Seçenek C (satın almayı hiç anmaz, en güvenli):
"Merhaba, bugün Hupolingo'daki ücretsiz sorularımı tamamladım. Yarın devam edeceğim. Hupolingo hakkında konuşmak ister misin?"

Öneri: Seçenek A veya B. Her ikisinde "Premium", "aç", "satın al" ve "veli panelinden" kalıbı yok; yine de veliye bilgi yolu açık. Seçenek C satın alma amacını kaybettirir; ürün hedefiyle çelişebilir.

Uygulama metni için ek notlar:
- Başlık ve açıklama ("Ücretli sürüm kararı velinin") kalabilir.
- Mesajda çocuğun adı, e-posta veya kod olmamaya devam etmeli.
- Mesaj panoya kopyalanır, uygulama paylaşım uygulamasını açmaz; bu tercih riski azaltıyor (dış bağlantı yok).

## Karar / onay gereken noktalar
1. Hedef kitle kararı (Kids/Aileler) verilmeden bu mesajın sınıflandırması kesinleşmez.
2. Hukuk: çocuğun veliye satın alma yönlü mesaj ilettirmesinin tüketici ve mağaza politikası açısından kabulü.
3. Mağaza politikası metninin güncel hali kontrol edilmedi (doğrulanmadı); inceleme öncesi okunmalı.
4. Veli panelinde satın alma akışının canlı olup olmadığı ve güncel paket adı (doğrulanmadı).
5. Kod değiştirilmedi; seçilen metin için `kVeliMesaji` sabiti güncellenir, ilgili testler (varsa) gözden geçirilir.
