// Okuma Dünyası ("Senin Hikâyen"): ölçü ve metin sabitleri.
//
// Renkler ayrı bir tema DEĞİLDİR: hepsi uygulamanın `AppColors` değerlerine bağlıdır. Burada
// yalnız okuma/soru ekranlarına özgü ölçüler (yazı boyutu, boşluk, dokunma alanı, hareket süresi)
// ve Türkçe metin sabitleri vardır (AGENTS.md §4: metinler const). Ölçüler tasarım ajanınca
// onaylı prototipten (flutter_prototip/lib/tema.dart) alınmıştır.

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

abstract final class OkumaTema {
  // ── Renk (AppColors takma adları; yeni renk yok) ───────────────────────────
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color sun = AppColors.sun;
  static const Color sunSoft = AppColors.sunSoft;
  static const Color mint = AppColors.mint;
  static const Color mintDark = AppColors.mintDark;
  static const Color mintSoft = AppColors.mintSoft;
  static const Color coral = AppColors.coral;
  static const Color coralDark = AppColors.coralDark;
  static const Color coralSoft = AppColors.coralSoft;
  static const Color skyDark = AppColors.skyDark;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color ink = AppColors.ink;
  static const Color muted = AppColors.muted;
  static const Color line = AppColors.line;
  static const Color lineDark = AppColors.lineDark;

  /// Okuyucuda önemli yer alt çizgisi (K-0036 H3, onaylı; kontrastı 4.5:1'in üstündedir).
  static const Color vurguAmber = Color(0xFF8A5B00);

  // ── Yazı boyutu (sp) ──────────────────────────────────────────────────────
  static const double yaziEtiket = 14;
  static const double yaziYardimci = 16;
  static const double yaziHata = 15;
  static const double yaziSecenek = 18;
  static const double yaziKartBaslik = 20;
  static const double yaziSoru = 22;
  static const double yaziEkranBaslik = 26;
  static const double yaziOkuma = 19;
  static const double yaziOkumaBuyuk = 23;
  static const double yaziSozlukKelime = 26;
  static const double yaziSozlukAnlam = 19;
  static const double cikartmaFarki = 6;

  static const FontWeight kalinlikGovde = FontWeight.w600;
  static const FontWeight kalinlikVurgu = FontWeight.w800;
  static const FontWeight kalinlikBaslik = FontWeight.w900;

  static const double satirGovde = 1.5;
  static const double satirOkuma = 1.75;
  static const double satirOkumaBuyuk = 1.7;
  static const double satirSoru = 1.4;

  /// Yazı tipi aileleri (ikisi de uygulamada tanımlıdır). Okuyucuda "Standart" / "Okuma dostu".
  static const String yaziAileVarsayilan = 'Nunito';
  static const String yaziAileOkuma = 'Lexend';

  // ── Boşluk (4'lü ölçek) ───────────────────────────────────────────────────
  static const double bosluk4 = 4;
  static const double bosluk8 = 8;
  static const double bosluk12 = 12;
  static const double bosluk16 = 16;
  static const double bosluk20 = 20;
  static const double bosluk24 = 24;
  static const double bosluk32 = 32;

  static const double yanBoslukTelefon = 20;
  static const double yanBoslukGenis = 32;
  static const double secenekAraligi = 12;

  // ── Köşe ──────────────────────────────────────────────────────────────────
  static const double koseKart = 22;
  static const double koseButon = 18;
  static const double koseGirdi = 18;
  static const double koseCip = 24;
  static const double koseAltSayfa = 28;

  // ── Dokunma ve bileşen ölçüsü (dp) ────────────────────────────────────────
  static const double dokunmaMin = 48;
  static const double secenekMinYukseklik = 64;
  static const double butonYukseklik = 56;
  static const double ilerlemeYuksekligi = 8;
  static const double ikonKucuk = 18;
  static const double ikonOrta = 22;
  static const double ikonBuyuk = 44;
  static const double kartMinYukseklik = 128;
  static const double yildizDokunma = 56;

  static const double odakHalkaKalinligi = 2;
  static const double kenarSecili = 3;
  static const double kenarVarsayilan = 1.5;
  static const double kenarUyari = 2;

  // ── Hupo boyutları (dp) ───────────────────────────────────────────────────
  static const double hupoKarsilama = 88;
  static const double hupoBaslik = 80;
  static const double hupoOrta = 72;
  static const double hupoBos = 64;
  static const double hupoRehber = 56;
  static const double hupoIpucu = 88;
  static const double hupoCevap = 96;
  static const double hupoSonuc = 160;
  static const double hupoSonucKisa = 120;
  static const double hupoSonucBuyukYazi =
      72; // kısa ekran + büyük yazı: başlığa yer açar
  static const double sonucKabukPay = 8;
  static const double sonucKonfetiTasma = 32;
  static const double sonucYildizBoyut = 88;
  static const double hupoKapakCikartma = 56;
  static const double hupoKart = 64;

  // ── İçerik genişliği ve kırılım (dp) ──────────────────────────────────────
  static const double icerikTablet = 720;
  static const double kirilimGenis = 600;
  static const double kisaEkranYukseklik = 700;
  static const double sonucYaziBuyukEsigi = 1.3;
  static const double sonucAltEylemOrani = 0.45;

  // ── Hareket (ms). sure(context, ms): hareket azaltmada 0 ──────────────────
  static const int hareketSayfa = 240;
  static const int hareketAltSayfa = 260;
  static const int hareketDogruIkon = 180;
  static const int hareketAciklama = 220;
  static const int hareketYildiz = 160;
  static const double hareketSayfaKaymasi = 16;
  static const double hareketAciklamaYukselme = 8;

  // ── Kabartma ──────────────────────────────────────────────────────────────
  static const double kabartmaKart = 4;

  static const List<BoxShadow> kartGolge = [
    BoxShadow(color: Color(0x1417324D), blurRadius: 18, offset: Offset(0, 6)),
  ];

  // ── Okuma kuralları (sayfa başına üst sınırlar) ───────────────────────────
  static const int okumaVurguZengin = 3;
  static const int okumaCikartmaZengin = 2;
  static const int okumaVurguSade = 1;
  static const int okumaCikartmaSade = 0;

  /// Hareket süresi: hareket azaltma açıksa sıfır (uygulamanın "Hareketi azalt" ayarı da buna yansır).
  static Duration sure(BuildContext context, int ms) =>
      MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: ms);

  /// Yazı stili: boyut, kalınlık, renk ve satır yüksekliği tek yerden. [aile] null ise
  /// uygulamanın seçili yazı tipi (Nunito/Lexend) geçerlidir.
  static TextStyle yazi(
    double boyut, {
    FontWeight kalinlik = kalinlikGovde,
    Color renk = ink,
    double? satir,
    double? harf,
    String? aile,
  }) =>
      TextStyle(
        fontFamily: aile,
        fontSize: boyut,
        fontWeight: kalinlik,
        color: renk,
        height: satir,
        letterSpacing: harf,
      );
}

/// Türkçe arayüz metinleri. Ton: 2. tekil "sen", kısa cümle, suçlama yok; kırmızı X ve ceza dili yok.
class OkumaMetin {
  const OkumaMetin._();

  static const uygulamaAdi = 'Senin Hikâyen';
  static const geri = 'Geri';
  static const kapat = 'Kapat';
  static const yenidenDene = 'Yeniden dene';
  static const hikayelereDon = 'Hikâyelere dön';
  static const beklemeUzadi =
      'Bu biraz sürdü. Hikâyelere dönüp sonra yeniden deneyebilirsin.';
  static const sorudanCikBaslik = 'Sorulardan çıkılsın mı?';
  static const sorudanCikAciklama =
      'Çıkarsan bu sorulara kaldığın yerden devam edemezsin.';
  static const sorudanKal = 'Sorulara dön';
  static const sorudanCik = 'Çık';

  // ── Öğren kartı ───────────────────────────────────────────────────────────
  static const kartBaslik = 'Bugünkü hikâye';
  static const kartAciklama =
      'Kendini ya da sevdiğin birini kahraman yap, hikâyeyi oku.';
  static const kartBasla = 'Hikâyeye başla';
  static String kartSeri(int gun) => '$gun günlük okuma serisi';
  static const kartKotaDolu =
      'Bugünkü hikâyeni okudun. Yarın yeni bir hikâye seni bekliyor.';
  static const kartOkuduklarim = 'Okuduklarım';
  static const kartOkudukSayi = 'hikâye okudun';

  // ── Kahraman ──────────────────────────────────────────────────────────────
  static const kahramanBaslik = 'Kahramanın kim olsun?';
  static const kahramanAlt =
      'Kendini, bir aile üyeni, bir hayvanı ya da hayalî bir karakteri seçebilirsin.';
  static const kahramanUst = 'HAYDİ, HİKÂYE BAŞLASIN!';
  static const kahramanOnerilen = 'Ya da birini seç:';
  static const kahramanAdEtiket = 'Kahramanın adı';
  static const kahramanAdIpucu = 'Adını yaz';
  static String kahramanProfilOneri(String ad) => 'Profil adımı kullan: $ad';
  static const kahramanYoldas = 'Yol arkadaşı ekle (isteğe bağlı)';
  static const kahramanYoldasAd = 'Yol arkadaşının adı';
  static const kahramanYoldasAdHata = 'Yol arkadaşının adını yaz.';
  static const kahramanDevam = 'Hikâyeleri gör';
  static const kahramanDevamPasif = 'Önce bir kahraman seç.';
  static const kahramanDegistir = 'Kahramanı değiştir';
  static const kahramanGizlilik = 'Yazdığın adlar yalnızca bu cihazda kalır.';
  static const kahramanKaydet = 'Bu kahramanı bu cihaza kaydet';
  static const kahramanlarimBaslik = 'Kahramanlarım';
  static const kahramanlarimAlt =
      'Bu cihaza kaydettiklerin. Dokununca hemen devam edersin.';
  static String kahramanSilEtiket(String ad) => '$ad kahramanını sil';
  static const kahramanSilindi = 'Kahraman silindi.';

  // ── Hikâye seçimi ─────────────────────────────────────────────────────────
  static const hikayeBaslik = 'Hangi hikâyeyi okuyalım?';
  static String hikayeAlt(String kahraman) =>
      '$kahraman için hikâyeler seçtim.';
  static const hikayeHepsi = 'Hepsi';
  static const hikayeBasla = 'Hikâyeye başla';
  static const hikayeBos = 'Bu filtrede hikâye yok.';
  static const hikayeBosIpucu = 'Konu ya da türü değiştirerek bak.';
  static const hikayeFiltreTemizle = 'Filtreleri temizle';
  static const hikayeKahramanYok =
      'Bu kahramanla şimdilik uygun bir hikâye yok. Başka bir kahraman deneyebilirsin.';
  static const hikayeKahramanYokBaslik = 'Bu kahramana uygun hikâye yok';
  static const hikayeYukleniyor = 'Hikâyeler hazırlanıyor…';
  static const hikayeAciliyor = 'Hikâyen hazırlanıyor…';
  static const hikayeYeni = 'Yeni';
  static const hikayeCevrimdisi =
      'İnternet yok. Bu hikâyeyi cihazından okuyorsun; sorular için bağlanman gerekir.';
  static String hikayeSure(int dk) => '$dk dk';
  static String hikayeSoru(int n) => '$n soru';

  // ── Okuyucu ──────────────────────────────────────────────────────────────
  static String okuyucuSayfa(int n, int toplam) => 'Sayfa $n / $toplam';
  static String gecisSureli(int sn) => '$sn sn sonra sonraki soruya geçilecek';
  static const sonrakiSayfa = 'Sonraki sayfa';
  static const onceki = 'Önceki';
  static const sorularaGec = 'Sorulara geç';
  static const okuyucuAyar = 'Okuma ayarları';
  static const okuyucuKelimeler = 'Sayfadaki kelimeler';
  static const okuyucuKelimeYok = 'Bu sayfada açıklanacak kelime yok.';
  static const okuyucuMod = 'Okuma modu';
  static const sade = 'Sade';
  static const zengin = 'Zengin';
  static const modSadeNot =
      'Daha sakin bir sayfa. Önemli yer ve çıkartmalar gizlenir.';
  static const modZenginNot =
      'Önemli yerler, kelimeler ve çıkartmalar renkle öne çıkar.';
  static const okuyucuYazi = 'Yazı boyutu';
  static const normal = 'Normal';
  static const buyukYazi = 'Büyük';
  static const okuyucuHarf = 'Harf stili';
  static const harfStandart = 'Standart';
  static const harfOkuma = 'Okuma dostu';
  static const sozlukKelime = 'Kelime';
  static const sozlukDeyim = 'Deyim';
  static const sozlukAtasozu = 'Atasözü';
  static const sozlukOrnek = 'Hikâyeden';
  static const anlamYok = 'Bu sözcüğün anlamı henüz eklenmedi.';
  static const adimOku = 'Oku';
  static const adimDusun = 'Düşün';
  static const dusunIpucu =
      'İstersen bu sözü kendi hayatından bir örnekle düşünebilirsin.';
  static const dusunAnlam = 'Anlamı';
  static const sozlugeEkle = 'Sözlüğe ekle';
  static const sozlugeEklendi = 'Defterine eklendi.';
  static const okuduklarimSekme = 'Okuduklarım';
  static const sozlugumSekme = 'Sözlüğüm';
  static const sozlugumAlt =
      'Hikâyelerden eklediğin atasözleri ve anlamları. Yalnız bu cihazda saklanır.';
  static const sozlugumBos =
      'Sözlüğün henüz boş. Bir hikâyenin sonundaki Düşün bölümünden atasözü ekleyebilirsin.';
  static const okuyucuBos = 'Bu hikâye şu an açılamıyor.';

  // ── Sorular ──────────────────────────────────────────────────────────────
  static String soruSayac(int n, int toplam) => 'Soru $n / $toplam';
  static const soruIpucu = 'İpucu';
  static const soruIpucuBaslik = 'Bir ipucu';
  static String soruIpucuSayfa(int sayfa) =>
      'Cevabı bulmak için hikâyenin $sayfa. sayfasına bakabilirsin.';
  static const soruCevapla = 'Cevapla';
  static const soruSecKisa = 'Bir şık seç, sonra cevapla.';
  static const soruSecildi = 'Seçtin';
  static const soruDogru = 'Doğru!';
  static const olmadi = 'Bu kez olmadı.';
  static const soruAciklamaya = 'Açıklamaya bakalım.';
  static const soruDogruCevap = 'Doğru cevap bu';
  static const soruAciklama = 'Açıklama';
  static const soruSonraki = 'Sonraki soru';
  static const soruSonuc = 'Sonucu gör';
  static const soruKaydedilmedi = 'Cevabın kaydedilmedi. Yeniden dene.';
  static const soruBos = 'Bu hikâyede sorular hazırlanamadı.';

  // ── Anket ────────────────────────────────────────────────────────────────
  static const anketBaslik = 'Bu hikâye nasıldı?';
  static const anketAlt =
      'Birkaç dokunuşla bitirebilirsin. Yazı yazmak zorunda değilsin.';
  static const anketYildizBos = 'Bir yıldız seçebilirsin.';
  static String anketYildiz(int n) => '$n / 5 yıldız';
  static const anketDaha = 'Nasıl daha iyi olurdu?';
  static const anketEnFazla = 'En fazla 3 tane seçebilirsin.';
  static const anketBaskaKahraman = 'Başka bir kahraman ister misin?';
  static const anketBaskaHikaye = 'Bu türden başka hikâye ister misin?';
  static const anketEvet = 'Evet';
  static const anketHayir = 'Hayır';
  static const anketGonder = 'Gönder';
  static const anketSimdiDegil = 'Şimdi değil';
  static const anketAtla = 'Atla';
  static const anketIstegeBagli = 'İsteğe bağlı. Hiçbirini seçmeden de geçebilirsin.';
  static const anketPuanBaslik = 'Puan';
  static const anketOneriBaslik = 'Nasıl daha iyi olurdu?';
  static const anketSonrakiBaslik = 'Sonraki hikâyeler';
  static const anketPasif =
      'Göndermek için bir yıldız seç ya da şimdi değil de.';
  static const anketGonderilemedi =
      'Yanıtın gönderilemedi, ama sorun değil. Hikâyeni bitirdin!';

  /// Sunucu beyaz listesindeki kodlar → çocuğa gösterilen etiket (sıra sabit).
  static const anketSecenekleri = <(String, String)>[
    ('daha_kisa', 'Daha kısa olsun'),
    ('daha_uzun', 'Daha uzun olsun'),
    ('daha_komik', 'Daha komik olsun'),
    ('daha_gizemli', 'Daha gizemli olsun'),
    ('daha_kolay', 'Daha kolay olsun'),
    ('daha_zor', 'Daha zor olsun'),
    ('daha_cok_macera', 'Daha çok macera olsun'),
    ('daha_cok_bilgi', 'Daha çok bilgi olsun'),
  ];

  // ── Sonuç ────────────────────────────────────────────────────────────────
  static const sonucHepsiBaslik = 'Hepsini doğru bildin!';
  static const sonucHepsiAlt = 'Harika bir okuma oldu.';
  static const sonucBitti = 'Hikâyeyi bitirdin.';
  static const sonucYuksek = 'Neredeyse hepsini bildin.';
  static const sonucOrta = 'İyi gidiyorsun.';
  static const sonucDusuk = 'İstersen sayfalara dönüp tekrar bakabilirsin.';
  static const sonucTesvik = 'Bir sonraki hikâyede daha da iyi olacaksın.';
  static const sonucTekrarGel =
      'Yakında tekrar gel, seni bekleyen yeni bir hikâye var!';
  static const sonucPdf = 'Hikâyeyi PDF olarak indir';
  static const sonucYeni = 'Yeni hikâye seç';
  static String sonucOzet(int toplam, int dogruSayisi) =>
      '$toplam sorudan $dogruSayisi tanesini bildin.';
  static String sonucXp(int xp) => '+$xp XP kazandın';
  static String sonucSeri(int gun) => '$gun günlük okuma serisi';
  static const sonucSiradaki = 'Sıradaki hikâye';
  static const sonucSiradakiBasla = 'Bu hikâyeyi oku';
  static const sonucYarin =
      'Bugünkü hikâyeni okudun. Yarın yeni bir hikâye seni bekliyor.';
  static const sonucYukleniyor = 'Sonucun hazırlanıyor…';

  // ── Kota ve PDF ──────────────────────────────────────────────────────────
  static const kotaBaslik = 'Bugünkü hikâyeni okudun';
  static const kotaAciklama =
      'Yarın yeni bir hikâye seni bekliyor. Şimdi kısa bir mola verebilirsin.';
  static const kotaTamam = 'Tamam';
  static const pdfHazirlaniyor = 'PDF hazırlanıyor…';
  static const pdfHazir = 'PDF hazır.';
  static const pdfHata = 'PDF hazırlanamadı. Birazdan yeniden dene.';
  static const pdfHakBaslik = 'PDF hakkın bu ay doldu';
  static const pdfHakAciklama =
      'Bu özellik için velinle devam et. Okuma ve sorular her zaman açık.';

  // ── Okuduklarım ──────────────────────────────────────────────────────────
  static const okuduklarimBaslik = 'Okuduklarım';
  static const okuduklarimBos =
      'Henüz bir hikâye bitirmedin. İlk hikâyeni seçmeye ne dersin?';
  static const okuduklarimAlt = 'Bitirdiğin hikâyeler bu cihazda saklanır.';
  static const okuduklarimTekrar = 'Yeniden oku';

  // ── HupoRead vitrini (Öğren) ve Tüm hikâyeler ─────────────────────────────
  static const vitrinBaslik = 'HupoRead';
  static const vitrinAlt = 'Hikâye ve macera dünyan';
  static const vitrinTumu = 'Tüm hikâyeler';
  static const vitrinKesif = 'Keşfetmeye hazır mısın?';
  static const vitrinKesifBaslik = 'Hikâyeleri keşfet';
  static const vitrinKesifBos = 'Şu an gösterilecek hikâye yok. Yakında yenileri eklenecek.';
  static const vitrinYeniEtiket = 'Sana özel macera';
  static const vitrinYeniBaslik = 'Bu hikâyenin kahramanı sensin!';
  static const vitrinYeniAlt = 'Kendini ya da sevdiğin birini kahraman yap.';
  static const vitrinOlustur = 'Hikâyemi oluştur';
  static const vitrinDevamBaslik = 'Maceran seni bekliyor!';
  static const vitrinDevam = 'Kaldığın yerden devam et';
  static const vitrinDevamBolum = 'Yarım kalan hikâye';
  static const vitrinKotaGovde = 'Yarın yeni bir hikâye seni bekliyor.';
  static const vitrinKatalogHata = 'Hikâyeler şu an yüklenemedi.';
  static String vitrinSayfa(int n, int toplam) => 'Sayfa $n / $toplam';
  static String vitrinSayi(int n) => '$n hikâye';
}
