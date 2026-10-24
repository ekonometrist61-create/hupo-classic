// Kahraman seçici: büyük kartlar (Ben, Hupo), kompakt kartlar (Ailem, Arkadaşım, Hayvan Dostlarımız,
// Araçlar), "Diğer kahraman seçenekleri" ve grup içi alt seçenekler (aile, hayvan, araç).
//
// Görseller uygulamanın karakter setinden açıkça seçilir (manifestin "ilk eşleşen" kuralına bağlı
// değil): "Başka biri" için yaşlı karakter çıkmaz. Sunucuya yalnız tür kodu gider; alt seçenek
// (ör. At, Otomobil) yalnız cihazda ad önerisi olarak kullanılır.

import 'package:flutter/material.dart';

import '../../models/okuma_kahraman.dart';
import '../../screens/okuma/okuma_tema.dart';
import '../hupo/hupo.dart';
import 'okuma_bilesenler.dart';

const _karakterler = 'assets/okuma/karakterler/karakter_';
const _kahramanlar = 'assets/okuma/kahramanlar/';

/// Grup içi alt seçenek: etiket, görsel yolu ve türü.
class KahramanAlt {
  const KahramanAlt(this.id, this.etiket, this.yol, this.tur);

  final String id;
  final String etiket;
  final String yol;
  final KahramanTuru tur;
}

/// Ailem: tür kodları sunucudaki `anne`, `baba`, `kardes`.
const kAileAlt = <KahramanAlt>[
  KahramanAlt('anne', 'Annem', '${_karakterler}insan_anne.webp', KahramanTuru.anne),
  KahramanAlt('baba', 'Babam', '${_karakterler}insan_baba.webp', KahramanTuru.baba),
  KahramanAlt('kardes', 'Kardeşim', '${_karakterler}insan_kardes_kucuk.webp', KahramanTuru.kardes),
];

/// Hayvan Dostlarımız. Hepsi sunucuda `hayvan` türüdür; etiket ad önerisi olur.
const kHayvanAlt = <KahramanAlt>[
  KahramanAlt('at', 'At', '${_karakterler}hayvan_at.webp', KahramanTuru.hayvan),
  KahramanAlt('aslan', 'Aslan', '${_kahramanlar}aslan.png', KahramanTuru.hayvan),
  KahramanAlt('fil', 'Fil', '${_kahramanlar}fil.png', KahramanTuru.hayvan),
  KahramanAlt('kartal', 'Kartal', '${_kahramanlar}kartal.png', KahramanTuru.hayvan),
  KahramanAlt('kedi', 'Kedi', '${_karakterler}hayvan_kedi.webp', KahramanTuru.hayvan),
  KahramanAlt('kopek', 'Köpek', '${_karakterler}hayvan_kopek.webp', KahramanTuru.hayvan),
  KahramanAlt('kurt', 'Kurt', '${_karakterler}hayvan_kurt.webp', KahramanTuru.hayvan),
  KahramanAlt('tilki', 'Tilki', '${_karakterler}hayvan_tilki.webp', KahramanTuru.hayvan),
  KahramanAlt('panda', 'Panda', '${_karakterler}hayvan_panda.webp', KahramanTuru.hayvan),
  KahramanAlt('kaplumbaga', 'Kaplumbağa', '${_karakterler}hayvan_kaplumbaga.webp', KahramanTuru.hayvan),
];

/// Araçlar. Hepsi sunucuda `arac` türüdür; etiket ad önerisi olur.
const kAracAlt = <KahramanAlt>[
  KahramanAlt('otomobil', 'Otomobil', '${_karakterler}arac_otomobil.webp', KahramanTuru.arac),
  KahramanAlt('tren', 'Tren', '${_karakterler}arac_tren.webp', KahramanTuru.arac),
  KahramanAlt('ucak', 'Uçak', '${_karakterler}arac_ucak.webp', KahramanTuru.arac),
  KahramanAlt('vapur', 'Vapur', '${_kahramanlar}vapur.png', KahramanTuru.arac),
  KahramanAlt('balon', 'Balon', '${_kahramanlar}balon.png', KahramanTuru.arac),
  KahramanAlt('uzay_gemisi', 'Uzay gemisi', '${_karakterler}arac_uzay_gemisi.webp', KahramanTuru.arac),
  KahramanAlt('denizalti', 'Denizaltı', '${_karakterler}arac_denizalti.webp', KahramanTuru.arac),
  KahramanAlt('arazi_araci', 'Arazi aracı', '${_karakterler}arac_arazi_araci.webp', KahramanTuru.arac),
  KahramanAlt('bisiklet', 'Bisiklet', '${_kahramanlar}bisiklet.png', KahramanTuru.arac),
  KahramanAlt('robot_arac', 'Robot araç', '${_karakterler}arac_robot_arac.webp', KahramanTuru.arac),
];

const _aileGrubu = 'aile';
const _hayvanGrubu = 'hayvan';
const _aracGrubu = 'arac';

const _kenarSecili = OkumaTema.kenarSecili;

/// Seçim bildirimi: [tur] sunucuya giden tür; [alt] alt seçenek kimliği; [isim] ad önerisi.
typedef KahramanSecildi = void Function(KahramanTuru tur, {String? alt, String? isim});

class KahramanSecici extends StatefulWidget {
  const KahramanSecici({super.key, required this.secili, required this.secilenAlt, required this.onSec});

  final KahramanTuru? secili;
  final String? secilenAlt;
  final KahramanSecildi onSec;

  @override
  State<KahramanSecici> createState() => _KahramanSeciciState();
}

class _KahramanSeciciState extends State<KahramanSecici> {
  /// Açık alt seçenek grubu (aile, hayvan, arac); yoksa null.
  String? _grup;
  bool _digerAcik = false;

  void _grubuAc(String grup) => setState(() => _grup = _grup == grup ? null : grup);

  bool _aileSecili(KahramanTuru? t) => t == KahramanTuru.anne || t == KahramanTuru.baba || t == KahramanTuru.kardes;

  @override
  Widget build(BuildContext context) {
    final t = widget.secili;
    return LayoutBuilder(
      builder: (context, kutu) {
        final ikili = (kutu.maxWidth - OkumaTema.bosluk12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                _kahramaniniSec,
                style: OkumaTema.yazi(OkumaTema.yaziSoru, kalinlik: OkumaTema.kalinlikBaslik),
              ),
            ),
            const SizedBox(height: OkumaTema.bosluk12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BuyukKart(
                      etiket: 'Ben',
                      alt: _benAlt,
                      zemin: OkumaTema.primarySoft,
                      secili: t == KahramanTuru.ben,
                      onTap: () => widget.onSec(KahramanTuru.ben),
                      gorsel: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: _Gorsel('${_karakterler}insan_erkek_neseli.webp', 76)),
                          Flexible(child: _Gorsel('${_karakterler}insan_kiz_enerjik.webp', 76)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: OkumaTema.bosluk12),
                  Expanded(
                    child: _BuyukKart(
                      etiket: 'Hupo',
                      alt: _hupoAlt,
                      zemin: OkumaTema.sunSoft,
                      secili: t == KahramanTuru.hazir,
                      onTap: () => widget.onSec(KahramanTuru.hazir),
                      gorsel: const OkumaMaskot(poz: HupoPose.hosgeldin, boyut: 104),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OkumaTema.bosluk12),
            Wrap(
              spacing: OkumaTema.bosluk12,
              runSpacing: OkumaTema.bosluk12,
              children: [
                SizedBox(
                  width: ikili,
                  child: _KompaktKart(
                    etiket: 'Ailem',
                    alt: _ailemAlt,
                    zemin: OkumaTema.coralSoft,
                    yol: '${_karakterler}insan_anne.webp',
                    secili: _aileSecili(t),
                    acik: _grup == _aileGrubu,
                    onTap: () => _grubuAc(_aileGrubu),
                  ),
                ),
                SizedBox(
                  width: ikili,
                  child: _KompaktKart(
                    etiket: 'Arkadaşım',
                    alt: _arkadasAlt,
                    zemin: OkumaTema.mintSoft,
                    yol: '${_karakterler}insan_arkadas_sapkali.webp',
                    secili: t == KahramanTuru.arkadas,
                    onTap: () => widget.onSec(KahramanTuru.arkadas),
                  ),
                ),
                SizedBox(
                  width: ikili,
                  child: _KompaktKart(
                    etiket: _hayvanBaslik,
                    alt: _hayvanAlt,
                    zemin: OkumaTema.sunSoft,
                    yol: '${_kahramanlar}aslan.png',
                    secili: t == KahramanTuru.hayvan,
                    acik: _grup == _hayvanGrubu,
                    onTap: () {
                      widget.onSec(KahramanTuru.hayvan);
                      _grubuAc(_hayvanGrubu);
                    },
                  ),
                ),
                SizedBox(
                  width: ikili,
                  child: _KompaktKart(
                    etiket: _aracBaslik,
                    alt: _aracAlt,
                    zemin: OkumaTema.primarySoft,
                    yol: '${_karakterler}arac_otomobil.webp',
                    secili: t == KahramanTuru.arac,
                    acik: _grup == _aracGrubu,
                    onTap: () {
                      widget.onSec(KahramanTuru.arac);
                      _grubuAc(_aracGrubu);
                    },
                  ),
                ),
              ],
            ),
            if (_grup != null) ...[
              const SizedBox(height: OkumaTema.bosluk12),
              _AltSecenekler(
                baslik: switch (_grup) {
                  _aileGrubu => _aileSecBaslik,
                  _hayvanGrubu => _hayvanSecBaslik,
                  _ => _aracSecBaslik,
                },
                secenekler: switch (_grup) {
                  _aileGrubu => kAileAlt,
                  _hayvanGrubu => kHayvanAlt,
                  _ => kAracAlt,
                },
                secilenAlt: widget.secilenAlt,
                secili: t,
                onSec: (a) => widget.onSec(
                  a.tur,
                  alt: a.id,
                  // Hayvan ve araçta etiket ad önerisidir; ailede çocuk kendi adını yazar.
                  isim: a.tur == KahramanTuru.hayvan || a.tur == KahramanTuru.arac ? a.etiket : null,
                ),
              ),
            ],
            const SizedBox(height: OkumaTema.bosluk12),
            Semantics(
              button: true,
              expanded: _digerAcik,
              child: OutlinedButton(
                onPressed: () => setState(() => _digerAcik = !_digerAcik),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(OkumaTema.dokunmaMin),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: OkumaTema.lineDark, width: OkumaTema.kenarVarsayilan),
                  foregroundColor: OkumaTema.ink,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _digerBaslik,
                        textAlign: TextAlign.center,
                        style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu),
                      ),
                    ),
                    const SizedBox(width: OkumaTema.bosluk8),
                    Icon(_digerAcik ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  ],
                ),
              ),
            ),
            if (_digerAcik) ...[
              const SizedBox(height: OkumaTema.bosluk12),
              Wrap(
                spacing: OkumaTema.bosluk12,
                runSpacing: OkumaTema.bosluk12,
                children: [
                  SizedBox(
                    width: ikili,
                    child: _KompaktKart(
                      etiket: 'Hayalî karakter',
                      alt: _hayaliAlt,
                      zemin: OkumaTema.sunSoft,
                      yol: '${_karakterler}fantastik_macera_kasifi.webp',
                      secili: t == KahramanTuru.hayali,
                      onTap: () => widget.onSec(KahramanTuru.hayali),
                    ),
                  ),
                  SizedBox(
                    width: ikili,
                    child: _KompaktKart(
                      etiket: 'Başka biri',
                      alt: _baskaAlt,
                      zemin: OkumaTema.line,
                      yol: '${_karakterler}insan_genc_kiz_modern.webp',
                      secili: t == KahramanTuru.baskaBiri,
                      onTap: () => widget.onSec(KahramanTuru.baskaBiri),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

const _kahramaniniSec = 'Kahramanını seç';
const _benAlt = 'Başrolde ben varım!';
const _hupoAlt = "Hupo'yla keşfet!";
const _ailemAlt = 'Annem, babam…';
const _arkadasAlt = 'Birlikte keşfet';
const _hayvanBaslik = 'Hayvan Dostlarımız';
const _hayvanAlt = 'At, aslan, fil…';
const _aracBaslik = 'Araçlar';
const _aracAlt = 'Otomobil, vapur…';
const _hayaliAlt = 'Hayal gücün';
const _baskaAlt = 'Tanıdığın biri';
const _digerBaslik = 'Diğer kahraman seçenekleri';
const _aileSecBaslik = 'Ailenden kim olsun?';
const _hayvanSecBaslik = 'Hangi hayvan olsun?';
const _aracSecBaslik = 'Hangi araç olsun?';

/// Karakter görseli. Yüklenemezse boş kutu kalır (yedek ikon kartta zaten vardır).
class _Gorsel extends StatelessWidget {
  const _Gorsel(this.yol, this.boyut);

  final String yol;
  final double boyut;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Image.asset(
          yol,
          width: boyut,
          height: boyut,
          fit: BoxFit.contain,
          cacheWidth: (boyut * MediaQuery.devicePixelRatioOf(context)).round(),
          errorBuilder: (_, __, ___) => SizedBox(width: boyut, height: boyut),
        ),
      );
}

BoxDecoration _kartKutusu({required bool secili}) => BoxDecoration(
      color: OkumaTema.surface,
      borderRadius: BorderRadius.circular(OkumaTema.koseKart),
      border: Border.all(
        color: secili ? OkumaTema.primary : OkumaTema.line,
        width: secili ? _kenarSecili : OkumaTema.kenarVarsayilan,
      ),
    );

/// Büyük kart: renkli görsel alanı, altında etiket ve kısa açıklama.
class _BuyukKart extends StatelessWidget {
  const _BuyukKart({
    required this.etiket,
    required this.alt,
    required this.zemin,
    required this.secili,
    required this.onTap,
    required this.gorsel,
  });

  final String etiket;
  final String alt;
  final Color zemin;
  final bool secili;
  final VoidCallback onTap;
  final Widget gorsel;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: secili,
        label: 'Kahraman: $etiket',
        onTap: onTap,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(OkumaTema.koseKart),
              onTap: onTap,
              child: Ink(
                decoration: _kartKutusu(secili: secili),
                padding: const EdgeInsets.all(OkumaTema.bosluk12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 124,
                      width: double.infinity,
                      decoration: BoxDecoration(color: zemin, borderRadius: BorderRadius.circular(18)),
                      child: Center(child: gorsel),
                    ),
                    const SizedBox(height: OkumaTema.bosluk8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            etiket,
                            style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikBaslik),
                          ),
                        ),
                        if (secili) const Icon(Icons.check_circle_rounded, color: OkumaTema.primary),
                      ],
                    ),
                    Text(alt, style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted, satir: 1.25)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// Kompakt kart: solda renkli görsel kutusu, sağda etiket ve açıklama.
class _KompaktKart extends StatelessWidget {
  const _KompaktKart({
    required this.etiket,
    required this.alt,
    required this.zemin,
    required this.yol,
    required this.secili,
    required this.onTap,
    this.acik = false,
  });

  final String etiket;
  final String alt;
  final Color zemin;
  final String yol;
  final bool secili;
  final bool acik;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: secili,
        expanded: acik ? true : null,
        label: 'Kahraman: $etiket',
        onTap: onTap,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(OkumaTema.koseKart),
              onTap: onTap,
              child: Ink(
                decoration: _kartKutusu(secili: secili),
                padding: const EdgeInsets.all(OkumaTema.bosluk8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: zemin, borderRadius: BorderRadius.circular(16)),
                        child: Center(child: _Gorsel(yol, 46)),
                      ),
                      const SizedBox(width: OkumaTema.bosluk8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tek kelimede kelime ortadan bölünmez (küçülerek sığar); çok kelimede satır sarar.
                            if (etiket.contains(' '))
                              Text(
                                etiket,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikBaslik, satir: 1.15),
                              )
                            else
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  etiket,
                                  maxLines: 1,
                                  style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikBaslik, satir: 1.15),
                                ),
                              ),
                            Text(
                              alt,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: OkumaTema.yazi(13, renk: OkumaTema.muted, satir: 1.2),
                            ),
                          ],
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

/// Grup içi alt seçenekler (3 sütun): görsel ve etiket.
class _AltSecenekler extends StatelessWidget {
  const _AltSecenekler({
    required this.baslik,
    required this.secenekler,
    required this.secilenAlt,
    required this.secili,
    required this.onSec,
  });

  final String baslik;
  final List<KahramanAlt> secenekler;
  final String? secilenAlt;
  final KahramanTuru? secili;
  final void Function(KahramanAlt) onSec;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(OkumaTema.bosluk12),
        decoration: BoxDecoration(
          color: OkumaTema.surface,
          borderRadius: BorderRadius.circular(OkumaTema.koseKart),
          border: Border.all(color: OkumaTema.line, width: OkumaTema.kenarVarsayilan),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(baslik, style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikBaslik)),
            ),
            const SizedBox(height: OkumaTema.bosluk12),
            LayoutBuilder(
              builder: (context, kutu) {
                final genislik = (kutu.maxWidth - 2 * OkumaTema.bosluk8) / 3;
                return Wrap(
                  spacing: OkumaTema.bosluk8,
                  runSpacing: OkumaTema.bosluk8,
                  children: [
                    for (final a in secenekler)
                      SizedBox(
                        width: genislik,
                        child: _AltKart(
                          alt: a,
                          // Hayvan ve araçta alt seçenek kimliği eşleşmeli; ailede kimlik zaten tür kodudur.
                          secili: a.tur == secili && (secilenAlt == a.id || a.id == a.tur.kod),
                          onTap: () => onSec(a),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
}

class _AltKart extends StatelessWidget {
  const _AltKart({required this.alt, required this.secili, required this.onTap});

  final KahramanAlt alt;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: secili,
        label: alt.etiket,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Ink(
                decoration: BoxDecoration(
                  color: secili ? OkumaTema.primarySoft : OkumaTema.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: secili ? OkumaTema.primary : OkumaTema.line,
                    width: secili ? _kenarSecili : OkumaTema.kenarVarsayilan,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: OkumaTema.bosluk8, horizontal: OkumaTema.bosluk4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 92),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Gorsel(alt.yol, 56),
                      const SizedBox(height: OkumaTema.bosluk4),
                      Text(
                        alt.etiket,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.15),
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
