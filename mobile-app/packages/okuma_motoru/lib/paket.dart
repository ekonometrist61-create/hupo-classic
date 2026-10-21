/// Derlenmiş hikâye paketini (hikaye-paketi.v1 JSON) ve sözlüğü (sozluk.v1 JSON)
/// motorun modellerine çevirir. Derleyici: atolye/src/derle.ts.
library;

import 'hikaye_cozucu.dart';
import 'turkce_ad.dart';

Hal _hal(String ad) => Hal.values.byName(ad);

Parca parcaFromJson(Map<String, dynamic> j) {
  switch (j['t']) {
    case 'metin':
      return Metin(j['v'] as String);
    case 'kahraman':
      return KahramanAd(_hal(j['hal'] as String));
    case 'yoldas':
      return YoldasAd(_hal(j['hal'] as String), j['yedek'] as String);
    case 'vurgu':
      return Vurgu(j['v'] as String);
    case 'kelime':
      return KelimeYuva(j['yuva'] as String);
    case 'atasozu':
      return AtasozuYuva(j['yuva'] as String);
    case 'deyim':
      return DeyimCumlesi(j['yuva'] as String);
    case 'deger':
      return DegerSahnesi(j['anahtar'] as String);
    case 'hareket':
      return HareketSahnesi(j['anahtar'] as String);
    case 'ikon':
      return Ikon(j['v'] as String);
    case 'isaret':
      return Isaret(j['kod'] as String);
  }
  throw HikayeHatasi('Bilinmeyen parça türü: ${j['t']}');
}

List<Parca> _parcalar(List<dynamic> liste) =>
    [for (final p in liste) parcaFromJson(Map<String, dynamic>.from(p as Map))];

Map<String, Sahne> _sahneler(Map<String, dynamic> ham) => {
      for (final e in ham.entries)
        e.key: Sahne({
          for (final v in (e.value as Map).entries)
            v.key as String: _parcalar(v.value as List),
        }),
    };

/// Sözlük JSON'undan yuva → aday listesi (yazım ve sınıf bandı).
Map<String, List<YuvaAdayi>> yuvalarFromSozluk(Map<String, dynamic> sozluk) {
  final girdiler = <String, Map<String, dynamic>>{
    for (final g in sozluk['girdiler'] as List)
      (g as Map)['id'] as String: Map<String, dynamic>.from(g),
  };
  YuvaAdayi aday(String id) {
    final g = girdiler[id];
    if (g == null) throw HikayeHatasi('Sözlükte girdi yok: $id');
    return YuvaAdayi(g['yazim'] as String, g['sinif_alt'] as int, g['sinif_ust'] as int);
  }

  return {
    for (final y in sozluk['yuvalar'] as List)
      (y as Map)['ad'] as String: [
        for (final a in y['adaylar'] as List) aday((a as Map)['girdi'] as String),
      ],
  };
}

/// Paket JSON'undan [Hikaye] üretir. [yuvalar] sözlükten gelir ([yuvalarFromSozluk]).
Hikaye hikayeFromPaket(Map<String, dynamic> paket, Map<String, List<YuvaAdayi>> yuvalar) {
  if (paket['paket_surumu'] != 1) throw HikayeHatasi('Desteklenmeyen paket sürümü.');
  final hikaye = Map<String, dynamic>.from(paket['hikaye'] as Map);
  return Hikaye(
    sayfalar: [
      for (final s in paket['sayfalar'] as List)
        _parcalar(Map<String, dynamic>.from(s as Map)['parcalar'] as List),
    ],
    izinliTurler: List<String>.from(hikaye['izinli_turler'] as List),
    degerSahneleri: _sahneler(Map<String, dynamic>.from(paket['deger_sahneleri'] as Map)),
    hareketSahneleri: _sahneler(Map<String, dynamic>.from(paket['hareket_sahneleri'] as Map)),
    deyimCumleleri: {
      for (final e in (paket['deyim_cumleleri'] as Map).entries)
        e.key as String: _parcalar(e.value as List),
    },
    yuvalar: yuvalar,
  );
}
