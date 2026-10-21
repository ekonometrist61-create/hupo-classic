import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/okuma_pdf_hikaye.dart';
import 'package:ogrenci_hazirlik/services/okuma_pdf_hizmeti.dart';
import 'package:okuma_motoru/hikaye_cozucu.dart';
import 'package:okuma_motoru/ikon_kayit.dart';
import 'package:okuma_motoru/paket.dart';

// Görsel kontrol için: HUPO_PDF_CIKTI=<klasör> flutter test test/okuma_pdf_test.dart
// Klasör verilirse her üretim dosyaya yazılır (ör. kapak/gövde/sorular/cevap sayfaları).
// Fikstür: packages/okuma_motoru/test/fixtures (Feneri Kim Yakıyor?).

// Sözcük seçimi için sınıf 5 kullanılır (fikstür sözlüğünde 8. sınıf adayı yok); PDF bandı
// [sinif] ile ayrıca verilir, böylece her sınıf bandı kendi tipografisiyle üretilir.
Future<OkumaPdfIstegi> _istek({required int sinif, required OkumaPdfTema tema, bool sorular = true}) async {
  final paket = jsonDecode(File('packages/okuma_motoru/test/fixtures/feneri-kim-yakiyor.paket.json').readAsStringSync())
      as Map<String, dynamic>;
  final sozluk = jsonDecode(File('packages/okuma_motoru/test/fixtures/sozluk.ornek.json').readAsStringSync())
      as Map<String, dynamic>;
  final hikaye = hikayeFromPaket(paket, yuvalarFromSozluk(sozluk));
  final sayfalar = sayfalariCoz(
    hikaye,
    Baglam(kahramanAdi: 'Ece', kahramanTuru: hikaye.izinliTurler.first, sinif: 5),
  );
  return OkumaPdfIstegi(
    baslik: 'Feneri Kim Yakıyor?',
    tanitim: 'Bir gece fener söndü ve denizdeki tekneler yolunu kaybetti. Işığı kim yakacak?',
    dosyaAdi: 'feneri-kim-yakiyor-$sinif-${tema.name}.pdf',
    sayfalar: sayfalar,
    sorular: sorular
        ? const [
            OkumaPdfSorusu(
              metin: 'Ece fenerin içinde ilk ne buldu?',
              secenekler: [('A', 'Bir kandil'), ('B', 'Bir masa'), ('C', 'Bir anahtar')],
              dogru: 'B',
            ),
            OkumaPdfSorusu(
              metin: 'Kapıdaki not neyi söylüyordu?',
              secenekler: [('A', 'Işığı birlikte arayın.'), ('B', 'Kapıyı kapatın.')],
            ),
          ]
        : const [],
    sinif: sinif,
    tema: tema,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cikti = Platform.environment['HUPO_PDF_CIKTI'];

  for (final sinif in [2, 5, 8]) {
    for (final tema in OkumaPdfTema.values) {
      test('PDF üretilir: $sinif. sınıf, ${tema.name}', () async {
        final bytes = await hikayePdfYap(await _istek(sinif: sinif, tema: tema));
        expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
        expect(bytes.length, greaterThan(20 * 1024));
        expect(bytes.length, lessThan(2 * 1024 * 1024));
        if (cikti != null) {
          Directory(cikti).createSync(recursive: true);
          File('$cikti/${(await _istek(sinif: sinif, tema: tema)).dosyaAdi}').writeAsBytesSync(Uint8List.fromList(bytes));
        }
      });
    }
  }

  test('89 katalog ikonunun tümü PDF\'e gömülür (SVG çizimi hatasız)', () async {
    // Her ikon kendi parçasında: kelime sayısı bütçeyi aşmaz, hiçbiri atlanmaz.
    final sayfalar = [
      for (final k in ikonKatalogu) [
        Cikti('Ece', Stil.normal),
        Cikti(' kelimesi', Stil.normal),
        Cikti('', Stil.isaret, ikonId: k.id),
      ],
    ];
    final bytes = await hikayePdfYap(
      OkumaPdfIstegi(
        baslik: 'İkon kataloğu',
        tanitim: 'Tüm ikonların PDF çizimi.',
        dosyaAdi: 'ikon-katalogu.pdf',
        sayfalar: sayfalar,
        sorular: const [],
        sinif: 3,
      ),
    );
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    final cikti = Platform.environment['HUPO_PDF_CIKTI'];
    if (cikti != null) {
      Directory(cikti).createSync(recursive: true);
      File('$cikti/ikon-katalogu.pdf').writeAsBytesSync(Uint8List.fromList(bytes));
    }
  });

  test('bilinmeyen ikon ve maskot satır içinde metni bozmaz', () async {
    final bytes = await hikayePdfYap(
      OkumaPdfIstegi(
        baslik: 'Kenar durumlar',
        tanitim: 'Kısa.',
        dosyaAdi: 'kenar.pdf',
        sayfalar: const [
          [
            Cikti('Hupo', Stil.normal),
            Cikti('🦉', Stil.isaret, ikonId: kMaskotIkonKimligi),
            Cikti('ve', Stil.normal),
            Cikti('🦄', Stil.isaret),
            Cikti(' sonra.', Stil.normal),
          ],
        ],
        sorular: const [],
        sinif: 7,
        tema: OkumaPdfTema.murekkepTasarrufu,
      ),
    );
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });

  test('cevap anahtarı olmayan istek de üretilir (sorusuz hikâye)', () async {
    final bytes = await hikayePdfYap(await _istek(sinif: 4, tema: OkumaPdfTema.renkli, sorular: false));
    expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
  });
}
