/// Akıllı soru vurgulama: saf mantık (web'deki src/lib/soru-vurgu.ts ile birebir aynı sözleşme).
///
///  - Metin DEĞİŞMEZ; vurgu ayrı metadata'dır: highlights = [{start, end}].
///  - start/end KOD NOKTASI (Unicode code point) ofsetidir, soru KÖKÜ metnine göredir;
///    start dahil, end hariç. Dart'ın UTF-16 indeksi (String.length) DEĞİLDİR; `runes` ile
///    sayılır, emoji gibi vekil çiftli metinde de doğru kesilir.
///  - Aralıklar artan sırada, çakışmasız ve 0 <= start < end <= kod noktası sayısı olmalı.
///    Biri geçersizse TÜM vurgu düşer ve düz metin gösterilir (sessiz düşüş, hata atmaz).
///  - Seçenek metinleri ve doğru cevap durumuyla ilgisi yoktur.
library;

class VurguAraligi {
  const VurguAraligi(this.start, this.end);

  final int start;
  final int end;

  @override
  bool operator ==(Object other) =>
      other is VurguAraligi && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'VurguAraligi($start, $end)';
}

class VurguParcasi {
  const VurguParcasi(this.metin, this.vurgulu);

  final String metin;
  final bool vurgulu;
}

/// Ham jsonb değerini (List of Map) ayrıştırır. Biçim bozuksa (dizi değil, tam sayı olmayan
/// alan vb.) boş liste döner; aralık doğrulaması [vurguParcalari] içinde, metin uzunluğuyla yapılır.
/// Geçersiz biçimi AYIRT edebilmek için tek bir bozuk öğe tüm listeyi boşaltır.
List<VurguAraligi> vurguAraliklariCoz(Object? ham) {
  if (ham is! List || ham.isEmpty) return const [];
  final sonuc = <VurguAraligi>[];
  for (final oge in ham) {
    if (oge is! Map) return const [];
    final s = oge['start'];
    final e = oge['end'];
    if (s is! num || e is! num) return const [];
    if (s != s.truncate() || e != e.truncate()) return const [];
    sonuc.add(VurguAraligi(s.toInt(), e.toInt()));
  }
  return sonuc;
}

/// Aralıkları metin uzunluğuna karşı doğrular; geçerliyse aynı listeyi, değilse null döner.
List<VurguAraligi>? vurguAraliklariniDogrula(
    int kodNoktasiSayisi, List<VurguAraligi>? araliklar) {
  if (araliklar == null || araliklar.isEmpty) return null;
  var onceki = 0;
  for (final a in araliklar) {
    if (a.start < onceki || a.end <= a.start || a.end > kodNoktasiSayisi) {
      return null;
    }
    onceki = a.end;
  }
  return araliklar;
}

/// Metni vurgulu/vurgusuz parçalara böler; birleşim her zaman özgün metne eşittir.
/// Geçersiz veya boş aralıklarda tek parça (düz metin) döner.
List<VurguParcasi> vurguParcalari(String metin, List<VurguAraligi>? araliklar) {
  final duz = [VurguParcasi(metin, false)];
  if (metin.isEmpty) return duz;
  final kn = metin.runes.toList(growable: false);
  final gecerli = vurguAraliklariniDogrula(kn.length, araliklar);
  if (gecerli == null) return duz;

  final parcalar = <VurguParcasi>[];
  var imlec = 0;
  for (final a in gecerli) {
    if (a.start > imlec) {
      parcalar.add(VurguParcasi(
          String.fromCharCodes(kn.sublist(imlec, a.start)), false));
    }
    parcalar.add(
        VurguParcasi(String.fromCharCodes(kn.sublist(a.start, a.end)), true));
    imlec = a.end;
  }
  if (imlec < kn.length) {
    parcalar.add(VurguParcasi(String.fromCharCodes(kn.sublist(imlec)), false));
  }
  return parcalar;
}
