/// Okuma içerik gösterim kuralları (tek kaynak). Belge: docs/OKUMA_GOSTERIM_KURALLARI.md.
///
/// Hangi parçaların vurgulanacağı ve kaç tane olacağı yalnız buradaki kurala göre belirlenir.
/// Ekranlar ve PDF bu fonksiyonu çağırır; ekran dosyasında ayrı sayı ya da seçim mantığı yazılmaz.
library;

import 'hikaye_cozucu.dart' show Cikti, Stil;

/// Bir sayfanın üst sınırları.
class SayfaButcesi {
  const SayfaButcesi({required this.vurgu, required this.kelime, required this.cikartma});

  /// Sayfadaki toplam vurgu (kelime + deyim + önemli yer).
  final int vurgu;

  /// Bunlardan en çok kaçı "kelime" (dokununca anlam açılan hap) olabilir.
  final int kelime;

  /// Satır içi çıkartma (ikon) sayısı.
  final int cikartma;
}

/// Sınıf ve moda göre sayfa bütçesi.
/// 2–5. sınıf: 3 vurgu (en çok 2 kelime), 2 çıkartma. 6. sınıf: 2 vurgu (1 kelime), 1 çıkartma.
/// 7–8. sınıf: 2 vurgu (1 kelime), çıkartma yok. Sade mod: her sınıfta 1 vurgu, çıkartma yok.
SayfaButcesi sayfaButcesi(int sinif, {required bool sade}) {
  if (sade) return const SayfaButcesi(vurgu: 1, kelime: 1, cikartma: 0);
  if (sinif <= 5) return const SayfaButcesi(vurgu: 3, kelime: 2, cikartma: 2);
  if (sinif == 6) return const SayfaButcesi(vurgu: 2, kelime: 1, cikartma: 1);
  return const SayfaButcesi(vurgu: 2, kelime: 1, cikartma: 0);
}

/// Hikâye başına üst sınırlar: en çok 2 atasözü kartı; Kelime Keşfi sayfa başına 1.
const int kHikayeAtasozuSiniri = 2;
const int kSayfaKesifSiniri = 1;

/// Bir sayfada seçilen parça indeksleri.
class SayfaSecimi {
  const SayfaSecimi({this.vurgu = const {}, this.cikartma = const {}});

  final Set<int> vurgu;
  final Set<int> cikartma;
}

String _anahtar(String s) => s.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase().trim();

bool _vurguMu(Stil s) => s == Stil.kelime || s == Stil.deyim || s == Stil.onemli;

/// Öncelik: kelime (3) > deyim (2) > önemli yer (1). Eşitlikte metindeki sıra.
int _oncelik(Stil s) => switch (s) {
      Stil.kelime => 3,
      Stil.deyim => 2,
      _ => 1,
    };

final RegExp _cumleSonu = RegExp(r'[.!?…]["”’]?\s*$');

/// Tüm hikâye için seçim. Kurallar sırayla uygulanır:
/// 1. Aynı kelime ya da deyim hikâyede yalnız İLK geçtiği yerde vurgulanır (tekrarına vurgu yok).
/// 2. Aynı cümlede en çok 1 vurgu (en yüksek öncelikli).
/// 3. Sayfa başına toplam vurgu ve kelime sınırı sınıfa/moda göre ([sayfaButcesi]).
/// 4. Çıkartma: sayfadaki ilk işaretler, sınır kadar (ikon kimliği olmayan sayılmaz).
List<SayfaSecimi> hikayeSecimi(List<List<Cikti>> sayfalar, {required int sinif, required bool sade}) {
  final b = sayfaButcesi(sinif, sade: sade);
  final gorulen = <String>{};
  final sonuc = <SayfaSecimi>[];
  for (final sayfa in sayfalar) {
    // 1) İlk geçiş + 2) cümle başına tek aday.
    final cumleAdaylari = <int, int>{}; // cümle no → seçilen parça indeksi
    var cumle = 0;
    for (var i = 0; i < sayfa.length; i++) {
      final c = sayfa[i];
      if (_vurguMu(c.stil)) {
        final tekrar = (c.stil == Stil.kelime || c.stil == Stil.deyim) && gorulen.contains(_anahtar(c.metin));
        if (!tekrar) {
          final onceki = cumleAdaylari[cumle];
          if (onceki == null || _oncelik(c.stil) > _oncelik(sayfa[onceki].stil)) cumleAdaylari[cumle] = i;
        }
      }
      if (c.stil == Stil.normal && _cumleSonu.hasMatch(c.metin)) cumle++;
    }
    // 3) Sayfa bütçesi.
    final adaylar = cumleAdaylari.values.toList()
      ..sort((a, b) {
        final p = _oncelik(sayfa[b].stil).compareTo(_oncelik(sayfa[a].stil));
        return p != 0 ? p : a.compareTo(b);
      });
    final secilen = <int>{};
    var kelime = 0;
    for (final i in adaylar) {
      if (secilen.length >= b.vurgu) break;
      if (sayfa[i].stil == Stil.kelime) {
        if (kelime >= b.kelime) continue;
        kelime++;
      }
      secilen.add(i);
    }
    for (final i in secilen) {
      final c = sayfa[i];
      if (c.stil == Stil.kelime || c.stil == Stil.deyim) gorulen.add(_anahtar(c.metin));
    }
    // 4) Çıkartma.
    final cikartma = <int>{};
    for (var i = 0; i < sayfa.length && cikartma.length < b.cikartma; i++) {
      if (sayfa[i].stil == Stil.isaret && sayfa[i].ikonId != null) cikartma.add(i);
    }
    sonuc.add(SayfaSecimi(vurgu: secilen, cikartma: cikartma));
  }
  return sonuc;
}

