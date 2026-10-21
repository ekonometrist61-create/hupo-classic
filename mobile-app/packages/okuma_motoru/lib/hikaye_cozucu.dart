/// Hikâye birleştirici (F1, ikinci parça).
///
/// Sayfa parçalarını (metin, kahraman adı, yol arkadaşı, sözlük yuvası, değer ve
/// kahraman türü sahneleri) bağlama göre düz metne çevirir. Her parça bir [Stil]
/// taşır; arayüz bunu kalın/renk olarak gösterir.
library;

import 'ikon_kayit.dart';
import 'turkce_ad.dart';

sealed class Parca {
  const Parca();
}

final class Metin extends Parca {
  const Metin(this.v);
  final String v;
}

final class KahramanAd extends Parca {
  const KahramanAd([this.hal = Hal.yalin]);
  final Hal hal;
}

/// Yol arkadaşı adı; seçilmemişse editörün verdiği [yedek] metin kullanılır.
final class YoldasAd extends Parca {
  const YoldasAd(this.hal, this.yedek);
  final Hal hal;
  final String yedek;
}

/// Önemli yer: kalın ve renkli.
final class Vurgu extends Parca {
  const Vurgu(this.v);
  final String v;
}

final class KelimeYuva extends Parca {
  const KelimeYuva(this.yuva);
  final String yuva;
}

final class AtasozuYuva extends Parca {
  const AtasozuYuva(this.yuva);
  final String yuva;
}

/// Deyim cümlesi; hikâyenin `deyimCumleleri` tablosundan gelir.
final class DeyimCumlesi extends Parca {
  const DeyimCumlesi(this.yuva);
  final String yuva;
}

/// Veli değer sahnesi (öncelik sırasına göre seçilir).
final class DegerSahnesi extends Parca {
  const DegerSahnesi(this.anahtar);
  final String anahtar;
}

/// Kahraman türüne göre hareket sahnesi.
final class HareketSahnesi extends Parca {
  const HareketSahnesi(this.anahtar);
  final String anahtar;
}

final class Isaret extends Parca {
  const Isaret(this.kod);
  final String kod;
}

/// Kavram ikonu: derleyici sözlükteki kavramdan otomatik üretir; değer doğrudan emoji.
final class Ikon extends Parca {
  const Ikon(this.v);
  final String v;
}

enum Stil { normal, onemli, kelime, deyim, atasozu, isaret }

final class Cikti {
  const Cikti(this.metin, this.stil, {this.ikonId});

  /// Ekranda gösterilecek düz metin (işaretler için eski emoji karakteri).
  final String metin;
  final Stil stil;

  /// Semantik ikon kimliği (`ikon_kayit.dart`). Yalnız işaret parçalarında doludur;
  /// PDF gibi çıktılar bunu kullanır, tanınmayan ikonda `null` kalır.
  final String? ikonId;
}

/// Bir sahnenin varyantları: anahtar (D kodu ya da kahraman türü) → parçalar.
/// Her sahnede `_default` bulunmak zorundadır.
final class Sahne {
  const Sahne(this.varyantlar);
  final Map<String, List<Parca>> varyantlar;
}

final class YuvaAdayi {
  const YuvaAdayi(this.metin, this.sinifAlt, this.sinifUst);
  final String metin;
  final int sinifAlt;
  final int sinifUst;
}

final class Hikaye {
  const Hikaye({
    required this.sayfalar,
    required this.izinliTurler,
    this.degerSahneleri = const {},
    this.hareketSahneleri = const {},
    this.deyimCumleleri = const {},
    this.yuvalar = const {},
  });

  /// Her sayfa bir parça listesidir.
  final List<List<Parca>> sayfalar;
  final List<String> izinliTurler;
  final Map<String, Sahne> degerSahneleri;
  final Map<String, Sahne> hareketSahneleri;
  final Map<String, List<Parca>> deyimCumleleri;
  final Map<String, List<YuvaAdayi>> yuvalar;
}

/// Okurun bu hikâyeyi çözmek için seçtiği bağlam.
final class Baglam {
  const Baglam({
    required this.kahramanAdi,
    required this.kahramanTuru,
    required this.sinif,
    this.yoldasAdi,
    this.degerler = const [],
    this.gorulen = const {},
  });

  final String kahramanAdi;
  final String? yoldasAdi;
  final String kahramanTuru;

  /// Veli tarafından seçilen D kodları, öncelik sırasıyla (en çok 5).
  final List<String> degerler;
  final int sinif;

  /// Son oturumlarda görülen sözlük adaylarının metinleri (tekrarı azaltmak için).
  final Set<String> gorulen;
}

/// Hikâye veri hatası: eksik sahne, uygun olmayan tür, bulunamayan yuva vb.
class HikayeHatasi implements Exception {
  const HikayeHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => 'HikayeHatasi: $mesaj';
}

const _isaretler = {
  'ipucu': '🔎',
  'yildiz': '⭐',
  'kitap': '📖',
  'anahtar': '🔑',
  'hupo': '🦉',
  'roket': '🚀',
  'kalp': '💛',
  'kedi': '🐱',
  'kus': '🐦',
  'ay': '🌙',
  'bulut': '☁️',
  'ucak': '✈️',
  'balik': '🐟',
  'orman': '🌲',
  'deniz': '🌊',
  'gunes': '☀️',
};
const _enDerin = 4;

/// Tüm sayfaları bağlama göre çözer.
List<List<Cikti>> sayfalariCoz(Hikaye hikaye, Baglam baglam) {
  if (!hikaye.izinliTurler.contains(baglam.kahramanTuru)) {
    throw const HikayeHatasi('Bu kahraman türü bu hikâyede desteklenmiyor.');
  }
  return [
    for (final sayfa in hikaye.sayfalar) _coz(sayfa, hikaye, baglam, 0),
  ];
}

List<Cikti> _coz(List<Parca> parcalar, Hikaye h, Baglam b, int derinlik) {
  if (derinlik > _enDerin) throw const HikayeHatasi('Parça derinliği aşıldı.');
  final cikti = <Cikti>[];
  for (final p in parcalar) {
    switch (p) {
      case Metin(:final v):
        cikti.add(Cikti(v, Stil.normal));
      case KahramanAd(:final hal):
        cikti.add(Cikti(ekle(b.kahramanAdi, hal), Stil.normal));
      case YoldasAd(:final hal, :final yedek):
        final ad = b.yoldasAdi;
        cikti.add(Cikti(ad == null ? yedek : ekle(ad, hal), Stil.normal));
      case Vurgu(:final v):
        cikti.add(Cikti(v, Stil.onemli));
      case KelimeYuva(:final yuva):
        cikti.add(Cikti(_yuvaSec(h, b, yuva), Stil.kelime));
      case AtasozuYuva(:final yuva):
        cikti.add(Cikti(_yuvaSec(h, b, yuva), Stil.atasozu));
      case DeyimCumlesi(:final yuva):
        final cumle = h.deyimCumleleri[yuva];
        if (cumle == null) throw HikayeHatasi('Deyim cümlesi yok: $yuva');
        cikti.addAll(_coz(cumle, h, b, derinlik + 1));
      case DegerSahnesi(:final anahtar):
        cikti.addAll(_coz(_sahneSec(h.degerSahneleri, anahtar, b.degerler, anahtar), h, b, derinlik + 1));
      case HareketSahnesi(:final anahtar):
        cikti.addAll(_coz(_sahneSec(h.hareketSahneleri, anahtar, [b.kahramanTuru], anahtar), h, b, derinlik + 1));
      case Ikon(:final v):
        // Derleyicinin kavram ikonu: doğrudan emoji (K-0047).
        cikti.add(Cikti(v, Stil.isaret, ikonId: ikonKimligiCoz(v)));
      case Isaret(:final kod):
        final emoji = _isaretler[kod];
        if (emoji == null) throw HikayeHatasi('Bilinmeyen işaret: $kod');
        cikti.add(Cikti(emoji, Stil.isaret, ikonId: ikonKimligiCoz(kod)));
    }
  }
  return cikti;
}

/// Sahne seçimi: önce [tercihler] sırasıyla eşleşen varyant, yoksa `_default`.
List<Parca> _sahneSec(Map<String, Sahne> sahneler, String anahtar, List<String> tercihler, String ad) {
  final sahne = sahneler[anahtar];
  if (sahne == null) throw HikayeHatasi('Sahne yok: $ad');
  for (final t in tercihler) {
    final v = sahne.varyantlar[t];
    if (v != null) return v;
  }
  final d = sahne.varyantlar['_default'];
  if (d == null) throw HikayeHatasi('Sahnede _default yok: $ad');
  return d;
}

/// Sözlük yuvası: sınıfa uyan adaylar arasından, görülmemiş olanı tercih eder.
String _yuvaSec(Hikaye h, Baglam b, String yuva) {
  final adaylar = (h.yuvalar[yuva] ?? const <YuvaAdayi>[])
      .where((a) => b.sinif >= a.sinifAlt && b.sinif <= a.sinifUst)
      .toList();
  if (adaylar.isEmpty) throw HikayeHatasi('Bu sınıf için aday yok: $yuva');
  final yeni = adaylar.where((a) => !b.gorulen.contains(a.metin));
  return (yeni.isNotEmpty ? yeni.first : adaylar.first).metin;
}
