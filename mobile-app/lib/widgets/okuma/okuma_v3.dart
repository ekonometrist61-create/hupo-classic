import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:okuma_motoru/okuma_motoru.dart' show kIkonVarlikKlasoru;

import '../../screens/okuma/okuma_tema.dart';
import '../hupo/hupo.dart';
import 'okuma_bilesenler.dart';

/// V3 görsel dili (onaylı "Renkli Okuma Macerası" mockup'ı) Hupolingo tokenlarıyla.
/// Yeni renk yoktur: `OkumaTema` ve `AppColors` kullanılır. Kelime Keşfi, Bilgi Kutusu ve
/// Düşünme soruları bu dosyada yoktur: veri sözleşmesinde karşılıkları henüz yoktur.

/// Katalog ikonu (renkli SVG). Süs amaçlıdır; ekran okuyucuda atlanır.
class OkumaKatalogIkon extends StatelessWidget {
  const OkumaKatalogIkon(this.kimlik, {super.key, this.boyut = 40});

  final String kimlik;
  final double boyut;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        '$kIkonVarlikKlasoru$kimlik.svg',
        width: boyut,
        height: boyut,
        excludeFromSemantics: true,
        placeholderBuilder: (_) => SizedBox(width: boyut, height: boyut),
      );
}

/// Tür görünümü: yumuşak zemin, vurgu rengi, katalog ikonu.
class OkumaTurStili {
  const OkumaTurStili(
      {required this.etiket,
      required this.zemin,
      required this.vurgu,
      required this.simge});

  final String etiket;
  final Color zemin;
  final Color vurgu;
  final String simge;
}

OkumaTurStili okumaTurStili(String kod) => switch (kod) {
      'gizem' => const OkumaTurStili(
          etiket: 'Gizem',
          zemin: OkumaTema.primarySoft,
          vurgu: OkumaTema.primary,
          simge: 'magnifier'),
      'macera' => const OkumaTurStili(
          etiket: 'Macera',
          zemin: OkumaTema.sunSoft,
          vurgu: OkumaTema.coralDark,
          simge: 'compass'),
      'bilim' => const OkumaTurStili(
          etiket: 'Bilim',
          zemin: Color(0x244EA9D9),
          vurgu: OkumaTema.skyDark,
          simge: 'atom'),
      'doga' => const OkumaTurStili(
          etiket: 'Doğa',
          zemin: OkumaTema.mintSoft,
          vurgu: OkumaTema.mintDark,
          simge: 'leaf'),
      'mizah' => const OkumaTurStili(
          etiket: 'Mizah',
          zemin: OkumaTema.sunSoft,
          vurgu: OkumaTema.ink,
          simge: 'joy'),
      'hayvanlar' => const OkumaTurStili(
          etiket: 'Hayvanlar',
          zemin: OkumaTema.mintSoft,
          vurgu: OkumaTema.mintDark,
          simge: 'cat'),
      'arkadaslik' => const OkumaTurStili(
          etiket: 'Arkadaşlık',
          zemin: OkumaTema.coralSoft,
          vurgu: OkumaTema.coralDark,
          simge: 'friends'),
      'fantastik' => const OkumaTurStili(
          etiket: 'Fantastik',
          zemin: OkumaTema.primarySoft,
          vurgu: OkumaTema.primaryDark,
          simge: 'castle-magic'),
      'spor' => const OkumaTurStili(
          etiket: 'Spor',
          zemin: OkumaTema.mintSoft,
          vurgu: OkumaTema.mintDark,
          simge: 'bicycle'),
      'tarih_kultur' => const OkumaTurStili(
          etiket: 'Tarih ve Kültür',
          zemin: OkumaTema.sunSoft,
          vurgu: OkumaTema.ink,
          simge: 'scroll'),
      'bilim_kurgu' => const OkumaTurStili(
          etiket: 'Bilim Kurgu',
          zemin: Color(0x244EA9D9),
          vurgu: OkumaTema.skyDark,
          simge: 'planet'),
      'gezi_kultur' => const OkumaTurStili(
          etiket: 'Gezi ve Kültür',
          zemin: OkumaTema.primarySoft,
          vurgu: OkumaTema.primary,
          simge: 'globe'),
      _ => const OkumaTurStili(
          etiket: 'Hikâye',
          zemin: OkumaTema.primarySoft,
          vurgu: OkumaTema.primaryDark,
          simge: 'book'),
    };

/// Sınıf etiketi: "4. sınıf" ya da aralık "5–6. sınıf".
String okumaSinifEtiketi(int alt, int ust) =>
    alt == ust ? '$alt. sınıf' : '$alt–$ust. sınıf';

/// Yuvarlak köşeli etiket hapı (tür, sınıf, süre çipleri).
class OkumaCip extends StatelessWidget {
  const OkumaCip({super.key, required this.zemin, required this.child});

  final Color zemin;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk4 + 2),
        decoration: BoxDecoration(
            color: zemin,
            borderRadius: BorderRadius.circular(OkumaTema.koseCip)),
        child: child,
      );
}

class OkumaTurCipi extends StatelessWidget {
  const OkumaTurCipi({super.key, required this.tur});

  final String tur;

  @override
  Widget build(BuildContext context) {
    final s = okumaTurStili(tur);
    return OkumaCip(
      zemin: s.zemin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OkumaKatalogIkon(s.simge, boyut: 18),
          const SizedBox(width: OkumaTema.bosluk8),
          Text(s.etiket,
              style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                  kalinlik: OkumaTema.kalinlikVurgu)),
        ],
      ),
    );
  }
}

/// Yaklaşık okuma süresi çipi ("N dk"). Metin, sunucudaki ve derleyicideki kuralla aynı biçimde yazılır.
class OkumaDakikaCipi extends StatelessWidget {
  const OkumaDakikaCipi({super.key, required this.dakika});

  final int dakika;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Yaklaşık $dakika dakikalık okuma',
        child: ExcludeSemantics(
          child: OkumaCip(
            zemin: OkumaTema.mintSoft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const OkumaKatalogIkon('clock', boyut: 18),
                const SizedBox(width: OkumaTema.bosluk8),
                Text(OkumaMetin.hikayeSure(dakika),
                    style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                        kalinlik: OkumaTema.kalinlikVurgu)),
              ],
            ),
          ),
        ),
      );
}

class OkumaSinifCipi extends StatelessWidget {
  const OkumaSinifCipi({super.key, required this.etiket});

  final String etiket;

  @override
  Widget build(BuildContext context) => OkumaCip(
        zemin: const Color(0x244EA9D9),
        child: Text(etiket,
            style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                kalinlik: OkumaTema.kalinlikVurgu)),
      );
}

/// Hikâye başlık bandı: büyük başlık, tür, sınıf ve süre çipleri. [maskot] açıksa sağda Hupo.
/// Okuyucuda varsayılan kapalıdır (K8: okuyucu metninde Hupo yok).
class OkumaBaslikBandi extends StatelessWidget {
  const OkumaBaslikBandi({
    super.key,
    required this.baslik,
    required this.tur,
    required this.sinifEtiketi,
    this.dakika,
    this.maskot = false,
  });

  final String baslik;
  final String tur;
  final String sinifEtiketi;

  /// Yaklaşık okuma süresi (dk); null ise çip gösterilmez.
  final int? dakika;
  final bool maskot;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(baslik,
                      style: OkumaTema.yazi(OkumaTema.yaziEkranBaslik,
                          kalinlik: OkumaTema.kalinlikBaslik, satir: 1.15)),
                ),
                const SizedBox(height: OkumaTema.bosluk8),
                Wrap(
                  spacing: OkumaTema.bosluk8,
                  runSpacing: OkumaTema.bosluk4,
                  children: [
                    OkumaTurCipi(tur: tur),
                    OkumaSinifCipi(etiket: sinifEtiketi),
                    if (dakika != null) OkumaDakikaCipi(dakika: dakika!),
                  ],
                ),
              ],
            ),
          ),
          if (maskot) ...[
            const SizedBox(width: OkumaTema.bosluk8),
            const OkumaMaskot(
                poz: HupoPose.merakEdiyor, boyut: OkumaTema.hupoBaslik),
          ],
        ],
      );
}

/// İlerleme çubuğu ve "Sayfa n / m" etiketi.
class OkumaIlerleme extends StatelessWidget {
  const OkumaIlerleme({super.key, required this.deger, required this.etiket});

  final double deger;
  final String etiket;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(OkumaTema.ilerlemeYuksekligi / 2),
              child: LinearProgressIndicator(
                value: deger,
                minHeight: OkumaTema.ilerlemeYuksekligi,
                color: OkumaTema.primary,
                backgroundColor: OkumaTema.lineDark,
              ),
            ),
          ),
          const SizedBox(width: OkumaTema.bosluk12),
          Text(etiket,
              style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                  kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted)),
        ],
      );
}

/// Numaralı adım rozeti ("1 Oku", "2 Düşün"). Aktif adım sarı dairede.
class OkumaAdimRozeti extends StatelessWidget {
  const OkumaAdimRozeti(
      {super.key,
      required this.sira,
      required this.etiket,
      required this.aktif});

  final int sira;
  final String etiket;
  final bool aktif;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: aktif,
        label: 'Adım $sira: $etiket',
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aktif ? OkumaTema.sun : OkumaTema.lineDark),
                child: Text('$sira',
                    style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                        kalinlik: OkumaTema.kalinlikBaslik)),
              ),
              const SizedBox(width: OkumaTema.bosluk8),
              Text(
                etiket,
                style: OkumaTema.yazi(
                  OkumaTema.yaziEtiket,
                  kalinlik: OkumaTema.kalinlikBaslik,
                  renk: aktif ? OkumaTema.ink : OkumaTema.muted,
                ),
              ),
            ],
          ),
        ),
      );
}

/// Sayfa sahnesi (yedek): görsel dosyası yokken türün renginde, katalog ikonlu kutu. Boş kutu göstermez.
/// Görsel sunucudan gelince bu kutu yerine kullanılır (Faz 2).
class OkumaSahne extends StatelessWidget {
  const OkumaSahne({super.key, required this.tur, this.yukseklik = 160, this.slug});

  final String tur;
  final double yukseklik;

  /// Hikâye adresi: varsa `assets/okuma/sahneler/<slug>.jpg` gösterilir; dosya yoksa tür yedeği.
  final String? slug;

  @override
  Widget build(BuildContext context) {
    final stil = okumaTurStili(tur);
    final yedek = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [stil.zemin, OkumaTema.surface],
        ),
      ),
      child: Center(
          child: ExcludeSemantics(
              child: OkumaKatalogIkon(stil.simge, boyut: yukseklik * 0.45))),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(OkumaTema.koseKart),
      child: SizedBox(
        height: yukseklik,
        width: double.infinity,
        child: slug == null
            ? yedek
            : ExcludeSemantics(
                child: Image.asset(
                  'assets/okuma/sahneler/$slug.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, hata, iz) => yedek,
                ),
              ),
      ),
    );
  }
}

/// Atasözü kartı: altın tonlu, tırnaklı söz. Dokununca anlamı açılır.
class OkumaAtasozuKarti extends StatelessWidget {
  const OkumaAtasozuKarti(
      {super.key, required this.metin, required this.onTap});

  final String metin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = BorderRadius.circular(OkumaTema.koseKart);
    return Semantics(
      button: true,
      label: 'Atasözü: $metin. Anlamı için çift dokun.',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          borderRadius: sekil,
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: sekil,
              gradient: const LinearGradient(
                colors: [OkumaTema.sunSoft, Color(0xFFFFE8A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border:
                  Border.all(color: OkumaTema.sun, width: OkumaTema.kenarUyari),
            ),
            child: InkWell(
              borderRadius: sekil,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(OkumaTema.bosluk16),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote_rounded,
                        size: OkumaTema.ikonBuyuk - 12, color: OkumaTema.ink),
                    const SizedBox(width: OkumaTema.bosluk12),
                    Expanded(
                      child: Text(
                        '“$metin”',
                        style: OkumaTema.yazi(OkumaTema.yaziKartBaslik,
                            kalinlik: OkumaTema.kalinlikBaslik, satir: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Anlamı" kutusu: açık zemin, kitap ikonu, anlam metni.
class OkumaAnlamKutusu extends StatelessWidget {
  const OkumaAnlamKutusu({super.key, required this.anlam});

  final String anlam;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(OkumaTema.bosluk16),
        decoration: BoxDecoration(
          color: OkumaTema.primarySoft,
          borderRadius: BorderRadius.circular(OkumaTema.koseGirdi),
          border: Border.all(
              color: OkumaTema.primaryLight.withValues(alpha: 0.5),
              width: OkumaTema.kenarVarsayilan),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OkumaKatalogIkon('book', boyut: 30),
            const SizedBox(width: OkumaTema.bosluk12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OkumaMetin.dusunAnlam,
                    style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                        kalinlik: OkumaTema.kalinlikBaslik,
                        renk: OkumaTema.primaryDark),
                  ),
                  const SizedBox(height: 2),
                  Text(anlam,
                      style:
                          OkumaTema.yazi(OkumaTema.yaziYardimci, satir: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Kelime, deyim veya atasözü alt sayfasının içeriği: başlıkta kapat simgesi, anlam ve örnek cümle
/// kaydırılabilir gövdede, "Kapat" düğmesi her zaman görünür altta. Kapat dokunulunca sayfa kapanır.
class OkumaKelimePaneli extends StatelessWidget {
  const OkumaKelimePaneli({
    super.key,
    required this.etiket,
    required this.metin,
    required this.anlam,
    required this.onKapat,
    this.ornek,
  });

  final String etiket;
  final String metin;
  final String anlam;
  final String? ornek;
  final VoidCallback onKapat;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk4,
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(etiket,
                        style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                            kalinlik: OkumaTema.kalinlikVurgu,
                            renk: OkumaTema.muted)),
                  ),
                  IconButton(
                    tooltip: OkumaMetin.kapat,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onKapat,
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(metin,
                            style: OkumaTema.yazi(OkumaTema.yaziSozlukKelime,
                                kalinlik: OkumaTema.kalinlikBaslik, satir: 1.2)),
                      ),
                      const SizedBox(height: OkumaTema.bosluk12),
                      Text(anlam,
                          style: OkumaTema.yazi(OkumaTema.yaziSozlukAnlam, satir: 1.5)),
                      if (ornek != null) ...[
                        const SizedBox(height: OkumaTema.bosluk16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(OkumaTema.bosluk16),
                          decoration: BoxDecoration(
                            color: OkumaTema.background,
                            borderRadius: BorderRadius.circular(OkumaTema.koseGirdi),
                            border: Border.all(
                                color: OkumaTema.lineDark,
                                width: OkumaTema.kenarVarsayilan),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(OkumaMetin.sozlukOrnek,
                                  style: OkumaTema.yazi(OkumaTema.yaziEtiket,
                                      kalinlik: OkumaTema.kalinlikVurgu,
                                      renk: OkumaTema.muted)),
                              const SizedBox(height: OkumaTema.bosluk4),
                              Text(
                                '“$ornek”',
                                style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1,
                                        satir: 1.5)
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: OkumaTema.bosluk16),
              OkumaIkincilButon(etiket: OkumaMetin.kapat, onPressed: onKapat),
            ],
          ),
        ),
      );
}
/// Otomatik geçiş geri sayımı. Hareket açıksa çubuk zamanla küçülür; hareket azaltmada
/// çubuk yerine yalnız süre metni gösterilir (animasyon yok).
class OkumaGeriSayim extends StatelessWidget {
  const OkumaGeriSayim({super.key, required this.sure});

  final Duration sure;

  @override
  Widget build(BuildContext context) {
    final sn = (sure.inMilliseconds / 1000).ceil();
    final metin = OkumaMetin.gecisSureli(sn);
    if (MediaQuery.disableAnimationsOf(context)) {
      return Semantics(
        liveRegion: true,
        child: Text(
          metin,
          textAlign: TextAlign.center,
          style: OkumaTema.yazi(OkumaTema.yaziEtiket,
              kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
        ),
      );
    }
    return Semantics(
      label: metin,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: 0),
          duration: sure,
          builder: (context, t, _) => ClipRRect(
            borderRadius:
                BorderRadius.circular(OkumaTema.ilerlemeYuksekligi / 2),
            child: LinearProgressIndicator(
              value: t,
              minHeight: OkumaTema.ilerlemeYuksekligi,
              color: OkumaTema.primary,
              backgroundColor: OkumaTema.lineDark,
            ),
          ),
        ),
      ),
    );
  }
}
