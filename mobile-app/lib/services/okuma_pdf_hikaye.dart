// Okuma Dünyası: PDF üretimi. Bu dosya YALNIZ ertelenmiş yükleme ile içe aktarılır
// (okuma_pdf_hizmeti.dart); başka hiçbir dosya doğrudan import etmemelidir.
// Sebep: `pdf` + `printing` + yazı tipleri ana paketi büyütmesin.
//
// İşlem tamamen cihazdadır. PDF'te çocuk adı yoktur: sayfalar nötr adla çözülmüş gelir,
// başlık hikâye adıdır, alt bilgi markadır.
//
// Tasarım (direktör ortak kararı K1, K3, K5, K7, K8, K9):
// - Renkler uygulama paletidir (lib/theme/app_theme.dart, AppColors). Değişirse burası da değişmeli.
// - Başlıklar ve kitap gövdesi serif (Literata); etiketler ve sorular Nunito.
// - Kapakta hikâyenin sahne görseli basılır (maskot yok); metin içinde maskot basılmaz.
// - İkonlar emoji değil, SVG vektörüdür (`assets/okuma/hikaye_ikonlari`). Sayfa başına en fazla
//   iki ikon (2–4. sınıf) veya bir ikon (5–8. sınıf). Eksik ikon metni bozmadan atlanır.
// - Atasözü ayrı blok olarak basılır; sayfa içi tam sayfa illüstrasyon yoktur.

import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:okuma_motoru/okuma_motoru.dart' show Cikti, IkonKaydi, Stil, ikonBul, kIkonVarlikKlasoru, kMaskotIkonKimligi;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'okuma_pdf_hizmeti.dart';

const _siteAdresi = 'hupolingo.com';
const _uygulamaAdi = 'Senin Hikâyen';
const _uygulamaAdiBuyuk = 'SENİN HİKÂYEN';
const _markaSol = 'Hupolingo · Senin Hikâyen';
const _govdeNormal = 'assets/fonts/LiterataPdf-Regular.ttf';
const _govdeKalin = 'assets/fonts/LiterataPdf-Bold.ttf';
const _etiketNormal = 'assets/fonts/NunitoPdf-Regular.ttf';
const _etiketKalin = 'assets/fonts/NunitoPdf-Bold.ttf';
const _sorularBasligi = 'Sorular';
const _cevapAnahtariBasligi = 'Cevap Anahtarı';

// Renkler: AppColors ile aynı değerler.
const _ink = PdfColor.fromInt(0xFF17324D);
const _kagit = PdfColor.fromInt(0xFFFFF9ED);
const _kart = PdfColor.fromInt(0xFFFFFFFF);
const _teal = PdfColor.fromInt(0xFF147D8A);
const _tealKoyu = PdfColor.fromInt(0xFF0D5762);
const _tealAcik = PdfColor.fromInt(0xFF4FB3BF);
const _tealSoluk = PdfColor.fromInt(0xFFE8F5F7);
const _gunes = PdfColor.fromInt(0xFFF5C842);
const _gunesSoluk = PdfColor.fromInt(0xFFFEF3CC);
const _deyim = PdfColor.fromInt(0xFF8A5B00);
const _soluk = PdfColor.fromInt(0xFF4A6A85);
const _cizgi = PdfColor.fromInt(0xFFF0E6CF);

const _kenar = 56.0;

/// Sınıf bandına göre tipografi ve ikon kuralları (brief §3.2 ve §4.3, K3).
final class _Bant {
  const _Bant({
    required this.govde,
    required this.satir,
    required this.hedefKelime,
    required this.ikonBoyu,
    required this.sayfaIkonUst,
    required this.sade,
  });

  final double govde;

  /// Satır aralığı çarpanı (1.0 = tek satır).
  final double satir;

  /// Bu kadar kelimede en fazla bir ikon.
  final int hedefKelime;
  final double ikonBoyu;

  /// Bir sayfada en fazla kaç ikon (K3).
  final int sayfaIkonUst;

  /// Daha sade (düşük doygunluk) ikon varyantı kullanılsın mı?
  final bool sade;

  factory _Bant.sinif(int sinif) {
    if (sinif <= 4) {
      return const _Bant(govde: 13.5, satir: 1.6, hedefKelime: 120, ikonBoyu: 13, sayfaIkonUst: 2, sade: false);
    }
    if (sinif <= 6) {
      return const _Bant(govde: 12.5, satir: 1.5, hedefKelime: 190, ikonBoyu: 12, sayfaIkonUst: 1, sade: true);
    }
    return const _Bant(govde: 12, satir: 1.45, hedefKelime: 300, ikonBoyu: 11, sayfaIkonUst: 1, sade: true);
  }
}

/// Üretim sırasında kullanılan yazı tipleri, görseller ve ikon SVG'leri.
final class _Varlik {
  _Varlik({
    required this.govde,
    required this.govdeKalin,
    required this.etiket,
    required this.etiketKalin,
    required this.sahne,
    required this.tema,
  });

  final pw.Font govde;
  final pw.Font govdeKalin;
  final pw.Font etiket;
  final pw.Font etiketKalin;
  /// Hikâyenin ilk sayfasındaki sahne görseli (JPEG). Yoksa kapakta görsel alanı renkli zemin olur.
  final Uint8List? sahne;
  final OkumaPdfTema tema;
  final Map<String, String?> _svgler = {};

  bool get murekkep => tema == OkumaPdfTema.murekkepTasarrufu;

  /// İkonun SVG metni; yüklenemezse `null` (ikon atlanır, metin kalır).
  Future<String?> svg(IkonKaydi kayit, _Bant bant) async {
    final dosya = bant.sade ? kayit.sadeDosya : kayit.renkliDosya;
    final anahtar = '$dosya|$murekkep';
    if (_svgler.containsKey(anahtar)) return _svgler[anahtar];
    String? metin;
    try {
      metin = await rootBundle.loadString('$kIkonVarlikKlasoru$dosya');
      if (murekkep) metin = _griye(metin);
    } on Object {
      metin = null;
    }
    return _svgler[anahtar] = metin;
  }
}

/// Üretir ve cihaza kaydeder: Android'de İndirilenler'e, web'de tarayıcı indirmesi olarak.
Future<void> hikayePdfIndir(OkumaPdfIstegi istek) async {
  final bytes = await hikayePdfYap(istek);
  final ad = istek.dosyaAdi.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), '');
  await FileSaver.instance.saveFile(
    name: ad,
    bytes: bytes,
    fileExtension: 'pdf',
    mimeType: MimeType.pdf,
  );
}

Future<Uint8List> hikayePdfYap(OkumaPdfIstegi istek) async {
  final bant = _Bant.sinif(istek.sinif);
  final murekkep = istek.tema == OkumaPdfTema.murekkepTasarrufu;
  final varlik = _Varlik(
    govde: pw.Font.ttf(await rootBundle.load(_govdeNormal)),
    govdeKalin: pw.Font.ttf(await rootBundle.load(_govdeKalin)),
    etiket: pw.Font.ttf(await rootBundle.load(_etiketNormal)),
    etiketKalin: pw.Font.ttf(await rootBundle.load(_etiketKalin)),
    sahne: await _sahneGorseli(istek.sahneSlug),
    tema: istek.tema,
  );
  final tema = pw.ThemeData.withFont(base: varlik.govde, bold: varlik.govdeKalin, italic: varlik.govde);
  final zemin = murekkep ? null : _kagit;
  final dokuman = pw.Document(theme: tema, title: istek.baslik, author: _markaSol);

  // Her sayfa parçası için ikonlar önceden yüklenir (eksikler sessizce atlanır).
  final ikonlar = <String, String>{};
  for (final sayfa in istek.sayfalar) {
    for (final c in sayfa) {
      final kimlik = c.ikonId;
      if (c.stil != Stil.isaret || kimlik == null || kimlik == kMaskotIkonKimligi) continue;
      final kayit = ikonBul(kimlik);
      if (kayit == null || ikonlar.containsKey(kimlik)) continue;
      final svg = await varlik.svg(kayit, bant);
      if (svg != null) ikonlar[kimlik] = svg;
    }
  }

  pw.Widget zeminArkaPlan(pw.Context ctx) => zemin == null
      ? pw.Container()
      : pw.FullPage(ignoreMargins: true, child: pw.Container(color: zemin));

  final kapakTemasi = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(_kenar, _kenar, _kenar, _kenar),
    buildBackground: zeminArkaPlan,
  );
  final sayfaTemasi = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(_kenar, 72, _kenar, 64),
    buildBackground: zeminArkaPlan,
  );

  dokuman.addPage(_kapak(istek, varlik, kapakTemasi));

  dokuman.addPage(
    pw.MultiPage(
      pageTheme: sayfaTemasi,
      // Kapaktan sonraki ilk hikâye sayfasında başlık zaten büyük basılır; üst bilgi tekrar etmez.
      header: (ctx) => ctx.pageNumber == 2 ? pw.SizedBox() : _ustBilgi(istek.baslik, varlik),
      footer: (ctx) => _altBilgi(ctx, varlik),
      build: (ctx) => [
        _hikayeBasligi(istek, varlik),
        for (final sayfa in istek.sayfalar) ...[
          ..._paragraf(sayfa, bant, ikonlar, varlik),
          pw.SizedBox(height: bant.govde * 1.1),
        ],
      ],
    ),
  );

  if (istek.sorular.isNotEmpty) {
    dokuman.addPage(
      pw.MultiPage(
        pageTheme: sayfaTemasi,
        header: (ctx) => _ustBilgi(istek.baslik, varlik),
        footer: (ctx) => _altBilgi(ctx, varlik),
        build: (ctx) => _sorular(istek, varlik),
      ),
    );

    final anahtar = [
      for (var i = 0; i < istek.sorular.length; i++)
        if (istek.sorular[i].dogru != null) (i + 1, istek.sorular[i].dogru!),
    ];
    if (anahtar.isNotEmpty) {
      dokuman.addPage(
        pw.MultiPage(
          pageTheme: sayfaTemasi,
          header: (ctx) => _ustBilgi(istek.baslik, varlik),
          footer: (ctx) => _altBilgi(ctx, varlik),
          build: (ctx) => _cevapAnahtari(anahtar, varlik),
        ),
      );
    }
  }

  return dokuman.save();
}

/// Kapak: marka, hikâye başlığı, tanıtım ve hikâyenin sahne görseli.
pw.Page _kapak(OkumaPdfIstegi istek, _Varlik v, pw.PageTheme tema) => pw.Page(
      pageTheme: tema,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_uygulamaAdiBuyuk, style: pw.TextStyle(font: v.etiketKalin, fontSize: 10, letterSpacing: 1.8, color: _tealKoyu)),
          pw.SizedBox(height: 26),
          pw.Text(istek.baslik, style: pw.TextStyle(font: v.govdeKalin, fontSize: 38, lineSpacing: 6, color: _ink)),
          pw.SizedBox(height: 14),
          pw.Container(
            width: 56,
            height: 5,
            decoration: pw.BoxDecoration(color: _gunes, borderRadius: pw.BorderRadius.circular(3)),
          ),
          pw.SizedBox(height: 18),
          pw.Text(istek.tanitim, style: pw.TextStyle(font: v.govde, fontSize: 14.5, lineSpacing: 5, color: _ink)),
          pw.SizedBox(height: 30),
          pw.Expanded(child: _kapakSahnesi(v)),
          pw.SizedBox(height: 22),
          _altBilgiCizgisi(v),
        ],
      ),
    );

/// Kapak görseli: hikâyenin sahne görseli kapağın tamamını kaplar. Görsel yoksa turkuaz zemin ve dalgalar
/// basılır; Hupo maskotu kapakta yer almaz. Mürekkep tasarrufunda yalnız çerçeve basılır.
pw.Widget _kapakSahnesi(_Varlik v) {
  if (v.murekkep) {
    return pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all(color: _cizgi, width: 0.9)));
  }
  final sahne = v.sahne;
  if (sahne != null) {
    return pw.SizedBox.expand(child: pw.Image(pw.MemoryImage(sahne), fit: pw.BoxFit.cover));
  }
  return pw.Container(
    color: _tealSoluk,
    child: pw.CustomPaint(painter: _kapakCizimi, child: pw.SizedBox.expand()),
  );
}
void _kapakCizimi(PdfGraphics canvas, PdfPoint boyut) {
  final w = boyut.x;
  final h = boyut.y;
  canvas
    ..setFillColor(_gunesSoluk)
    ..drawEllipse(w * 0.70 - 80, h * 0.64 - 80, 160, 160)
    ..fillPath();
  _dalga(canvas, w, h * 0.24, h * 0.07, _tealAcik);
  _dalga(canvas, w, h * 0.12, h * 0.05, _teal);
}

/// Dört eşit parçalı yumuşak dalga; alt kenara kadar dolu.
void _dalga(PdfGraphics canvas, double w, double taban, double genlik, PdfColor renk) {
  const parca = 4;
  final adim = w / parca;
  final yler = [taban, taban + genlik, taban, taban - genlik, taban];
  canvas
    ..setFillColor(renk)
    ..moveTo(0, 0)
    ..lineTo(0, yler.first);
  for (var i = 0; i < parca; i++) {
    final x0 = adim * i;
    final x1 = adim * (i + 1);
    canvas.curveTo(x0 + adim / 2, yler[i], x1 - adim / 2, yler[i + 1], x1, yler[i + 1]);
  }
  canvas
    ..lineTo(w, 0)
    ..closePath()
    ..fillPath();
}

pw.Widget _ustBilgi(String baslik, _Varlik v) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _cizgi, width: 0.8))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(baslik, style: pw.TextStyle(font: v.etiket, fontSize: 9, color: _soluk)),
          pw.Text(_uygulamaAdi, style: pw.TextStyle(font: v.etiketKalin, fontSize: 9, letterSpacing: 0.6, color: _teal)),
        ],
      ),
    );

pw.Widget _altBilgi(pw.Context ctx, _Varlik v) => pw.Column(
      children: [
        pw.SizedBox(height: 8),
        _altBilgiCizgisi(v, sayfa: ctx.pageNumber),
      ],
    );

pw.Widget _altBilgiCizgisi(_Varlik v, {int? sayfa}) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(_markaSol, style: pw.TextStyle(font: v.etiket, fontSize: 8.5, color: _soluk)),
        pw.Text(sayfa == null ? _siteAdresi : '$_siteAdresi  ·  $sayfa', style: pw.TextStyle(font: v.etiket, fontSize: 8.5, color: _soluk)),
      ],
    );

/// Hikâyenin ilk sayfasındaki başlık bloğu.
pw.Widget _hikayeBasligi(OkumaPdfIstegi istek, _Varlik v) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('HİKÂYE', style: pw.TextStyle(font: v.etiketKalin, fontSize: 9, letterSpacing: 1.6, color: _tealKoyu)),
        pw.SizedBox(height: 6),
        pw.Text(istek.baslik, style: pw.TextStyle(font: v.govdeKalin, fontSize: 26, lineSpacing: 4, color: _ink)),
        pw.SizedBox(height: 10),
        pw.Container(width: 44, height: 4, decoration: pw.BoxDecoration(color: _gunes, borderRadius: pw.BorderRadius.circular(2))),
        pw.SizedBox(height: 20),
      ],
    );

/// Bir sayfa parçası. Metin kelime sınırında kırılır; ikon kendi sözcüğünün arkasına gelir
/// ve asla sözcüğü bölmez. Atasözü, metni bölen ayrı bir blok olur.
List<pw.Widget> _paragraf(List<Cikti> parcalar, _Bant bant, Map<String, String> ikonlar, _Varlik v) {
  final kelimeSayisi = parcalar.fold<int>(0, (n, c) => n + (c.stil == Stil.isaret ? 0 : c.metin.split(RegExp(r'\s+')).where((k) => k.isNotEmpty).length));
  // Seçici ikonlandırma: yaklaşık `hedefKelime` başına bir ikon, sayfa üst sınırıyla (K3).
  final ikonButcesi = (kelimeSayisi ~/ bant.hedefKelime).clamp(1, bant.sayfaIkonUst);
  var kullanilan = 0;
  final gorulen = <String>{};

  final kutular = <pw.Widget>[];
  var yayilim = <pw.InlineSpan>[];

  void duzyaziyiBitir() {
    if (yayilim.isEmpty) return;
    kutular.add(pw.RichText(text: pw.TextSpan(children: yayilim), textAlign: pw.TextAlign.left));
    yayilim = <pw.InlineSpan>[];
  }

  for (final c in parcalar) {
    if (c.stil == Stil.atasozu) {
      duzyaziyiBitir();
      kutular.add(_atasozuBlok(c.metin, bant, v));
      continue;
    }
    if (c.stil == Stil.isaret) {
      final kimlik = c.ikonId;
      // Maskot metin içine basılmaz (K5, K8); yalnız kapakta yer alır.
      if (kimlik == null || kimlik == kMaskotIkonKimligi || kullanilan >= ikonButcesi || !gorulen.add(kimlik)) continue;
      final child = _ikonSatiri(kimlik, ikonlar, bant);
      if (child == null) continue;
      kullanilan++;
      yayilim.add(pw.WidgetSpan(child: child, baseline: 1));
      continue;
    }
    // Atasözü bloğundan sonra paragraf boşlukla başlamasın.
    final metin = yayilim.isEmpty ? c.metin.trimLeft() : c.metin;
    yayilim.add(pw.TextSpan(text: metin, style: _stil(c.stil, bant, v)));
  }
  duzyaziyiBitir();
  return kutular;
}

pw.Widget _atasozuBlok(String metin, _Bant bant, _Varlik v) => pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.symmetric(vertical: 8),
      padding: const pw.EdgeInsets.fromLTRB(16, 12, 14, 12),
      decoration: const pw.BoxDecoration(
        color: _gunesSoluk,
        border: pw.Border(left: pw.BorderSide(color: _gunes, width: 4)),
      ),
      child: pw.Text(
        metin.trim(),
        style: pw.TextStyle(
          font: v.govde,
          fontStyle: pw.FontStyle.italic,
          fontSize: bant.govde + 0.5,
          lineSpacing: bant.govde * (bant.satir - 1),
          color: _deyim,
        ),
      ),
    );

pw.Widget? _ikonSatiri(String kimlik, Map<String, String> ikonlar, _Bant bant) {
  final svg = ikonlar[kimlik];
  if (svg == null) return null;
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 1.5),
    child: pw.SvgImage(svg: svg, width: bant.ikonBoyu, height: bant.ikonBoyu),
  );
}

pw.TextStyle _stil(Stil s, _Bant bant, _Varlik v) {
  final taban = pw.TextStyle(
    font: v.govde,
    fontSize: bant.govde,
    lineSpacing: bant.govde * (bant.satir - 1),
    color: _ink,
  );
  return switch (s) {
    Stil.onemli => taban.copyWith(font: v.govdeKalin),
    Stil.kelime => taban.copyWith(font: v.govdeKalin, color: _tealKoyu),
    Stil.deyim => taban.copyWith(font: v.govdeKalin, color: _deyim),
    _ => taban,
  };
}

/// Bölüm başlığı: serif başlık ve kısa renkli çizgi.
pw.Widget _bolumBasligi(String metin, _Varlik v, PdfColor vurgu) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(metin, style: pw.TextStyle(font: v.govdeKalin, fontSize: 24, color: _ink)),
        pw.SizedBox(height: 8),
        pw.Container(width: 44, height: 4, decoration: pw.BoxDecoration(color: vurgu, borderRadius: pw.BorderRadius.circular(2))),
        pw.SizedBox(height: 18),
      ],
    );

/// Sorular: her biri ayrı kart; seçenekler boş daire ile işaretlenebilir.
List<pw.Widget> _sorular(OkumaPdfIstegi istek, _Varlik v) => [
      _bolumBasligi(_sorularBasligi, v, _teal),
      for (var i = 0; i < istek.sorular.length; i++) ...[
        _soruKarti(i + 1, istek.sorular[i], v),
        pw.SizedBox(height: 12),
      ],
    ];

pw.Widget _soruKarti(int no, OkumaPdfSorusu soru, _Varlik v) => pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: v.murekkep ? null : _kart,
        border: pw.Border.all(color: _cizgi, width: 0.9),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 22,
                height: 22,
                alignment: pw.Alignment.center,
                decoration: const pw.BoxDecoration(color: _teal, shape: pw.BoxShape.circle),
                child: pw.Text('$no', style: pw.TextStyle(font: v.etiketKalin, fontSize: 10.5, color: _kart)),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(soru.metin, style: pw.TextStyle(font: v.etiketKalin, fontSize: 13, lineSpacing: 2, color: _ink)),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          for (final (harf, metin) in soru.secenekler)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 32, bottom: 5),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(color: _teal)),
                  ),
                  pw.SizedBox(width: 9),
                  pw.Expanded(child: pw.Text('$harf) $metin', style: pw.TextStyle(font: v.etiket, fontSize: 12.5, color: _ink))),
                ],
              ),
            ),
        ],
      ),
    );

/// Cevap anahtarı: ayrı son sayfa; çocuk etkinlik sayfasında yer almaz.
List<pw.Widget> _cevapAnahtari(List<(int, String)> anahtar, _Varlik v) => [
      _bolumBasligi(_cevapAnahtariBasligi, v, _gunes),
      pw.Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final (no, dogru) in anahtar)
            pw.Container(
              width: 104,
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: pw.BoxDecoration(color: _tealSoluk, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Soru $no', style: pw.TextStyle(font: v.etiket, fontSize: 11, color: _soluk)),
                  pw.Text(dogru, style: pw.TextStyle(font: v.etiketKalin, fontSize: 14, color: _tealKoyu)),
                ],
              ),
            ),
        ],
      ),
    ];

/// Kapak görseli: hikâyenin sahne görseli (assets/okuma/sahneler/<slug>.jpg). Yoksa null.
Future<Uint8List?> _sahneGorseli(String? slug) async {
  if (slug == null || slug.isEmpty) return null;
  try {
    final veri = await rootBundle.load('assets/okuma/sahneler/$slug.jpg');
    return veri.buffer.asUint8List();
  } on Object {
    return null;
  }
}

/// Mürekkep tasarrufu: SVG renklerini gri tonlara çevirir (parlaklık ortalaması).
String _griye(String svg) => svg.replaceAllMapped(RegExp(r'#([0-9A-Fa-f]{6})'), (m) {
      final v = int.parse(m.group(1)!, radix: 16);
      final y = (0.299 * ((v >> 16) & 0xFF) + 0.587 * ((v >> 8) & 0xFF) + 0.114 * (v & 0xFF)).round().clamp(0, 255);
      final h = y.toRadixString(16).padLeft(2, '0');
      return '#$h$h$h';
    });
