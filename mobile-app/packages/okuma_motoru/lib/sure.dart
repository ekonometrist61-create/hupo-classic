/// Okuma süresi etiketi ("N dk"). Kural tek kaynaktır: docs/okuma-entegrasyon/OKUMA_GOSTERIM_KURALLARI.md §7.
/// Derleyici (`atolye/src/derle.ts`) aynı tabloyu ve aynı yuvarlamayı kullanır; iki yer değişirse
/// kart ve okuyucu farklı süre gösterir.
library;

import 'hikaye_cozucu.dart' show Cikti, Stil;

/// Sınıfa göre ortalama sesli olmayan okuma hızı (kelime/dk). Süre ETİKETİ içindir, ölçüm değildir.
/// 2. sınıf 60, 3: 75, 4: 90, 5: 105, 6: 115, 7: 125, 8: 135. Aralık dışı en yakın uca sıkışır.
int okumaHizi(int sinif) => switch (sinif.clamp(2, 8)) {
      2 => 60,
      3 => 75,
      4 => 90,
      5 => 105,
      6 => 115,
      7 => 125,
      _ => 135,
    };

/// Hikâyenin yaklaşık okuma süresi (dakika, yukarı yuvarlanır, en az 1). Çıkartmalar sayılmaz.
int okumaDakikasi(List<List<Cikti>> sayfalar, int sinif) {
  var kelime = 0;
  for (final sayfa in sayfalar) {
    for (final c in sayfa) {
      if (c.stil == Stil.isaret) continue;
      kelime += c.metin.split(RegExp(r'\s+')).where((x) => x.isNotEmpty).length;
    }
  }
  final dakika = (kelime / okumaHizi(sinif)).ceil();
  return dakika < 1 ? 1 : dakika;
}
