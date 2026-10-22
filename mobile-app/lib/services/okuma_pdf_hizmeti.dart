// Okuma Dünyası: PDF üretimi için hafif cephe.
//
// `pdf` ve `printing` paketleri ile 259 KB'lık yazı tipi ana pakete GİRMEZ: üretim kodu
// `okuma_pdf_hikaye.dart` içindedir ve yalnız kullanıcı "PDF indir" deyince ERTELENMİŞ
// (deferred) olarak yüklenir.
//
// Gizlilik: PDF'e kahraman ya da yol arkadaşı adı girmez. Çağıran taraf sayfaları NÖTR adla
// çözüp verir (bkz. OkumaAkisDenetleyici.pdfSayfalari); PDF hikâye adı ve marka taşır.

import 'package:okuma_motoru/okuma_motoru.dart' show Cikti;

import 'okuma_pdf_hikaye.dart' deferred as pdf_uretici;

/// PDF'e giden tek bir soru. Şıklar (harf, metin) çiftleridir.
/// [dogru], yalnız bu oturumda cevaplanıp sunucudan öğrenilen sorular için doludur.
class OkumaPdfSorusu {
  const OkumaPdfSorusu({required this.metin, required this.secenekler, this.dogru});

  final String metin;
  final List<(String, String)> secenekler;
  final String? dogru;
}

/// Baskı teması: `renkli` krem zemin ve renkli ikonlar; `murekkepTasarrufu` beyaz zemin,
/// gri ikonlar ve renksiz kartlar.
enum OkumaPdfTema { renkli, murekkepTasarrufu }

class OkumaPdfIstegi {
  const OkumaPdfIstegi({
    required this.baslik,
    required this.tanitim,
    required this.dosyaAdi,
    required this.sayfalar,
    required this.sorular,
    this.sinif = 5,
    this.tema = OkumaPdfTema.renkli,
    this.sahneSlug,
  });

  final String baslik;
  final String tanitim;
  final String dosyaAdi;
  final List<List<Cikti>> sayfalar;
  final List<OkumaPdfSorusu> sorular;

  /// Ana sınıf (2–8). Tipografi ve ikon yoğunluğu buna göre seçilir.
  final int sinif;
  final OkumaPdfTema tema;

  /// Kapak görseli için hikâye adresi (assets/okuma/sahneler/<slug>.jpg). Yoksa kapakta görsel yoktur.
  final String? sahneSlug;
}

/// PDF'i üretir ve indirme/paylaşma penceresini açar (web'de dosya iner).
typedef OkumaPdfUretici = Future<void> Function(OkumaPdfIstegi istek);

/// Gerçek üretici: kodu ilk kullanımda yükler.
Future<void> okumaPdfUret(OkumaPdfIstegi istek) async {
  await pdf_uretici.loadLibrary();
  await pdf_uretici.hikayePdfIndir(istek);
}
