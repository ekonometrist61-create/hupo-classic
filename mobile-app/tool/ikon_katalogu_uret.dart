// Genel semantik ikon kataloğu üreticisi.
//
// Kaynak: assets/okuma/hikaye_ikonlari/manifest.json (+ renkli ve sade SVG'ler).
// Çıktı: packages/okuma_motoru/lib/ikon_katalogu.g.dart — elle düzenlenmez.
//
// Kullanım (mobile-app klasöründen):
//   dart run tool/ikon_katalogu_uret.dart
//
// Yeni ikon eklemek için: SVG (renkli + `.muted.svg`) ve manifest girdisini ekle, sonra
// bu komutu çalıştır. Üretici şunları doğrular: dosya varlığı, benzersiz kimlik, güvensiz
// SVG öğeleri (script, dış bağlantı, metin, gömülü görsel) ve zorunlu alanlar.

import 'dart:convert';
import 'dart:io';

const _kaynakKlasor = 'assets/okuma/hikaye_ikonlari';
const _hedef = 'packages/okuma_motoru/lib/ikon_katalogu.g.dart';

final _yasakli = <RegExp>[
  RegExp(r'<\s*script', caseSensitive: false),
  RegExp(r'<\s*(image|text|foreignObject|style|use|a)\b', caseSensitive: false),
  RegExp(r'\bhref\s*=', caseSensitive: false),
  RegExp(r'\bon[a-z]+\s*=', caseSensitive: false),
  RegExp(r'url\s*\(', caseSensitive: false),
  RegExp(r'@import', caseSensitive: false),
];

void main() {
  final manifest = jsonDecode(File('$_kaynakKlasor/manifest.json').readAsStringSync()) as Map<String, dynamic>;
  final ikonlar = (manifest['icons'] as List).cast<Map<String, dynamic>>();
  final hatalar = <String>[];
  final gorulen = <String>{};
  final satirlar = <String>[];

  for (final k in ikonlar) {
    final id = k['id'] as String?;
    if (id == null || !RegExp(r'^[a-z0-9-]+$').hasMatch(id)) {
      hatalar.add('Geçersiz id: $id');
      continue;
    }
    if (!gorulen.add(id)) hatalar.add('Yinelenen id: $id');
    final dosyalar = k['files'] as Map<String, dynamic>;
    for (final anahtar in ['color', 'muted']) {
      final ad = dosyalar[anahtar] as String?;
      if (ad == null) {
        hatalar.add('$id: $anahtar dosyası tanımsız');
        continue;
      }
      final dosya = File('$_kaynakKlasor/$ad');
      if (!dosya.existsSync()) {
        hatalar.add('$id: dosya yok ($ad)');
        continue;
      }
      final svg = dosya.readAsStringSync();
      if (!svg.contains('viewBox')) hatalar.add('$id/$anahtar: viewBox yok');
      for (final r in _yasakli) {
        if (r.hasMatch(svg)) hatalar.add('$id/$anahtar: güvensiz öğe ($r)');
      }
    }
    final etiket = k['label_tr'] as String?;
    if (etiket == null || etiket.isEmpty) hatalar.add('$id: label_tr boş');

    final etiketler = [for (final t in (k['tags_tr'] as List? ?? const [])) t as String];
    satirlar.add('''  IkonKaydi(
    id: ${_s(id)},
    kategori: ${_s(k['category'] as String? ?? 'genel')},
    etiket: ${_s(etiket ?? id)},
    etiketler: [${etiketler.map(_s).join(', ')}],
    sinifAraligi: ${_s(k['grade_recommendation'] as String? ?? '2-8')},
    oncelik: ${_s(k['priority'] as String? ?? 'medium')},
    dekoratif: ${k['decorative_default'] == true},
    satirIci: ${k['inline_allowed'] == true},
    renkliDosya: ${_s(dosyalar['color'] as String)},
    sadeDosya: ${_s(dosyalar['muted'] as String)},
  ),''');
  }

  if (hatalar.isNotEmpty) {
    stderr.writeln('Katalog doğrulanamadı:\n - ${hatalar.join('\n - ')}');
    exitCode = 1;
    return;
  }

  final cikti = StringBuffer()
    ..writeln('// GENERATED: tool/ikon_katalogu_uret.dart çalıştırılarak üretildi. Elle düzenleme.')
    ..writeln('// Kaynak: $_kaynakKlasor/manifest.json (${ikonlar.length} kavram).')
    ..writeln()
    ..writeln("import 'ikon_kayit.dart';")
    ..writeln()
    ..writeln('const List<IkonKaydi> ikonKatalogu = [')
    ..writeAll(satirlar, '\n')
    ..writeln()
    ..writeln('];');
  File(_hedef).writeAsStringSync(cikti.toString());
  stdout.writeln('${ikonlar.length} ikon yazıldı -> $_hedef');
}

String _s(String v) => "'${v.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";
