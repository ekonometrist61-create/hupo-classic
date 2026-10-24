// Okuma Dünyası: sözlük yuvaları ve anlamlar.
//
// SÖZLEŞME BOŞLUĞU: `okuma_hikaye_getir` paketi yalnız yuva ADLARINI taşır (kelime:yuva);
// yuva adaylarını ve anlamları veren bir RPC yoktur (OKUMA_RPC_SOZLESMESI.md, "Bilinen eksikler").
// Çözüm sırası:
//   1) Paket `sozluk` anahtarı taşıyorsa (sozluk.v1 biçimi) onu kullan.
//   2) Yoksa paketin öğrenme hedeflerinden (`etiketler.ogrenme_hedefleri[].yuva` → `etiket`)
//      tek adaylı yuva kur; anlam bilgisi olmaz ("anlamı henüz eklenmedi" gösterilir).
// Sunucu sözlük ya da yuva alanı eklerse yalnız bu dosya değişir.

import 'package:okuma_motoru/okuma_motoru.dart';

import '../models/okuma_models.dart';

class OkumaSozluk {
  const OkumaSozluk({required this.yuvalar, required this.anlamlar});

  final Map<String, List<YuvaAdayi>> yuvalar;

  /// Sözcük yazımı → anlam.
  final Map<String, String> anlamlar;
}

/// Paketten sözlük kurar.
OkumaSozluk okumaSozluguKur(OkumaPaketi paket) {
  final sozluk = paket.paketSozlugu;
  if (sozluk != null) {
    return OkumaSozluk(
      yuvalar: yuvalarFromSozluk(sozluk),
      anlamlar: {
        for (final g in (sozluk['girdiler'] as List? ?? const []))
          if ((g as Map)['yazim'] is String && g['anlam'] is String) g['yazim'] as String: g['anlam'] as String,
      },
    );
  }
  final sinif = paket.anaSinif;
  return OkumaSozluk(
    yuvalar: {
      for (final h in paket.hedefler)
        if (h.yuva != null && h.etiket.isNotEmpty) h.yuva!: [YuvaAdayi(h.etiket, sinif, sinif)],
    },
    anlamlar: const {},
  );
}

/// Sunucu sözlüğünü (`okuma_sozluk_getir`) paket sözlüğünün üstüne koyar.
/// Yalnız onaylı adaylar alınır; yanıt boş, eksik ya da bozuksa paket sözlüğü aynen kalır.
OkumaSozluk okumaSozlugunuSunucuylaBirlestir(OkumaSozluk temel, Map<String, dynamic>? sunucu) {
  final yuvalar = sunucu?['yuvalar'];
  if (yuvalar is! List || yuvalar.isEmpty) return temel;
  final sonYuvalar = Map<String, List<YuvaAdayi>>.of(temel.yuvalar);
  final sonAnlamlar = Map<String, String>.of(temel.anlamlar);
  for (final y in yuvalar) {
    if (y is! Map) continue;
    final ad = y['yuva'];
    final adaylar = y['adaylar'];
    if (ad is! String || adaylar is! List) continue;
    final liste = <YuvaAdayi>[];
    for (final a in adaylar) {
      if (a is! Map || a['onayli'] != true) continue;
      final yazim = a['yazim'];
      final anlam = a['anlam'];
      final sinifAlt = a['sinif_alt'];
      final sinifUst = a['sinif_ust'];
      if (yazim is! String || anlam is! String || sinifAlt is! int || sinifUst is! int) continue;
      liste.add(YuvaAdayi(yazim, sinifAlt, sinifUst));
      sonAnlamlar[yazim] = anlam;
    }
    if (liste.isNotEmpty) sonYuvalar[ad] = liste;
  }
  return OkumaSozluk(yuvalar: sonYuvalar, anlamlar: sonAnlamlar);
}

/// Hikâyeyi cihazda çözer. Ad yalnız burada, bellekte metne girer.
List<List<Cikti>> okumaSayfalariniCoz(
  OkumaPaketi paket,
  OkumaSozluk sozluk, {
  required String kahramanAdi,
  required String kahramanTuru,
  String? yoldasAdi,
}) {
  final hikaye = hikayeFromPaket(paket.paket, sozluk.yuvalar);
  return sayfalariCoz(
    hikaye,
    Baglam(
      kahramanAdi: kahramanAdi,
      kahramanTuru: kahramanTuru,
      sinif: paket.anaSinif,
      yoldasAdi: yoldasAdi,
    ),
  );
}

/// Pakette beyan edilen hedeflerden, dokunulan metinlere karşılık gelen kimlikler.
/// Yalnız bu sürümde kayıtlı kimlikler döner (sunucu `BAD_HEDEF` ile reddeder).
List<String> dokunulanHedefKimlikleri(OkumaPaketi paket, Set<String> dokunulanMetinler) {
  String kucuk(String s) => s.toLowerCase();
  final metinler = {for (final m in dokunulanMetinler) kucuk(m)};
  final kimlikler = <String>{};
  for (final h in paket.hedefler) {
    if (metinler.contains(kucuk(h.etiket))) kimlikler.add(h.id);
  }
  return kimlikler.take(50).toList();
}
