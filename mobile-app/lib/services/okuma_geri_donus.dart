// Okuma Dünyası: uygulama içi geri dönüş mesajı.
//
// Çocuk 3 gün ya da daha uzun süredir hikâye okumadıysa Öğren kartında ve hikâye listesinde
// nazik bir mesaj gösterilir. Push bildirimi YOKTUR: çocuk hesabında uzaktan bildirim için
// veli onayı ve hukuk onayı (GÖR-045) bekleniyor. Zaman damgası yalnız cihazda tutulur.

const int kGeriDonusGunEsigi = 3;

bool geriDonusGerekli({
  required DateTime? sonOkuma,
  required DateTime simdi,
  int gunEsigi = kGeriDonusGunEsigi,
}) {
  if (sonOkuma == null) return false; // Henüz okuma yoksa baskı yapılmaz.
  return simdi.difference(sonOkuma).inDays >= gunEsigi;
}

/// Mesaj metni: çocuk diliyle, suçlamadan.
String geriDonusMetni(int gun) => '$gun gündür yeni bir hikâye okumadın. Seni bekliyoruz!';
