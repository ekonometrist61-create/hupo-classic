import 'package:flutter/material.dart';

import '../../models/okuma_models.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Hikâyeyi sevme anketi. Hedef: çocuk isterse hikâyeyi puanlar ve nasıl daha iyi olacağını seçer.
/// Hiçbiri zorunlu değildir: hiçbir şey seçilmeden "Atla" ile geçilir (sunucuya yanıt yazılmaz).
/// Ödülsüz, serbest metin yok. Yanıtlar yalnız hikâye geliştirme içindir.

/// En çok iyileştirme seçimi.
const _enFazlaIyilestirme = 3;

class AnketEkrani extends StatefulWidget {
  const AnketEkrani({super.key, required this.onBitti});

  /// Yanıt gönderildi (dolu) ya da atlandı (null).
  final void Function(OkumaAnketYaniti? yanit) onBitti;

  @override
  State<AnketEkrani> createState() => _AnketEkraniState();
}

class _AnketEkraniState extends State<AnketEkrani> {
  int? _yildiz;
  int _yildizSayaci = 0;
  final Set<String> _iyilestirmeler = {};
  bool? _baskaKahraman;
  bool? _ayniTur;
  String? _uyari;

  /// Hiçbir yanıt yoksa "Atla" görünür; varsa "Gönder".
  bool get _yanitVar =>
      _yildiz != null ||
      _iyilestirmeler.isNotEmpty ||
      _baskaKahraman != null ||
      _ayniTur != null;

  void _gonder() {
    widget.onBitti(OkumaAnketYaniti(
      yildiz: _yildiz,
      iyilestirmeKodlari: Set.of(_iyilestirmeler),
      baskaKahraman: _baskaKahraman ?? false,
      ayniTurden: _ayniTur ?? false,
    ));
  }

  void _yildizSec(int i) {
    setState(() {
      _yildiz = i;
      _yildizSayaci++;
    });
  }

  void _iyilestirmeDegistir(String secenek, bool secili) {
    setState(() {
      if (!secili) {
        _iyilestirmeler.remove(secenek);
        _uyari = null;
      } else if (_iyilestirmeler.length < _enFazlaIyilestirme) {
        _iyilestirmeler.add(secenek);
        _uyari = null;
      } else {
        _uyari = OkumaMetin.anketEnFazla;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final yildiz = _yildiz;
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      icerik: [
        const BaslikSatiri(
          baslik: OkumaMetin.anketBaslik,
          alt: OkumaMetin.anketAlt,
          maskot: OkumaMaskot(poz: HupoPose.hazirMisin, boyut: OkumaTema.hupoBos),
          maskotSolda: false,
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        _Bolum(
          baslik: OkumaMetin.anketPuanBaslik,
          child: Column(
            children: [
              // Yıldızlar: büyük dokunma alanı, seçili yıldız sarı dolgu ve koyu kenar taşır.
              TweenAnimationBuilder<double>(
                key: ValueKey<int>(_yildizSayaci),
                tween: Tween<double>(begin: 0.92, end: 1),
                duration: OkumaTema.sure(context, OkumaTema.hareketYildiz),
                curve: Curves.easeOutBack,
                builder: (context, t, child) => Transform.scale(scale: t, child: child),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 1; i <= 5; i++)
                      _YildizDugmesi(deger: i, secili: yildiz != null && i <= yildiz, onTap: () => _yildizSec(i)),
                  ],
                ),
              ),
              const SizedBox(height: OkumaTema.bosluk4),
              Text(
                yildiz == null ? OkumaMetin.anketYildizBos : OkumaMetin.anketYildiz(yildiz),
                style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu),
              ),
            ],
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        _Bolum(
          baslik: OkumaMetin.anketOneriBaslik,
          child: LayoutBuilder(
            builder: (context, kisit) {
              // İki sütunlu, eşit kutular: dağınık chip akışı yerine düzenli bir ızgara.
              final yarim = (kisit.maxWidth - OkumaTema.bosluk8) / 2;
              return Wrap(
                spacing: OkumaTema.bosluk8,
                runSpacing: OkumaTema.bosluk8,
                children: [
                  for (final (kod, etiket) in OkumaMetin.anketSecenekleri)
                    SizedBox(
                      width: yarim,
                      child: _SecimKutusu(
                        etiket: etiket,
                        secili: _iyilestirmeler.contains(kod),
                        onTap: () => _iyilestirmeDegistir(kod, !_iyilestirmeler.contains(kod)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (_uyari != null) ...[
          const SizedBox(height: OkumaTema.bosluk8),
          Semantics(
            liveRegion: true,
            child: Text(
              _uyari!,
              style: OkumaTema.yazi(OkumaTema.yaziHata, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.coralDark),
            ),
          ),
        ],
        const SizedBox(height: OkumaTema.bosluk16),
        _Bolum(
          baslik: OkumaMetin.anketSonrakiBaslik,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EvetHayir(
                soru: OkumaMetin.anketBaskaKahraman,
                deger: _baskaKahraman,
                onSec: (v) => setState(() => _baskaKahraman = v),
              ),
              const SizedBox(height: OkumaTema.bosluk12),
              _EvetHayir(
                soru: OkumaMetin.anketBaskaHikaye,
                deger: _ayniTur,
                onSec: (v) => setState(() => _ayniTur = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk12),
        Text(
          OkumaMetin.anketIstegeBagli,
          textAlign: TextAlign.center,
          style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
        ),
      ],
      altEylem: OkumaButon(
        etiket: _yanitVar ? OkumaMetin.anketGonder : OkumaMetin.anketAtla,
        onPressed: _yanitVar ? _gonder : () => widget.onBitti(null),
      ),
    );
  }
}

/// Ekranın bir bölümü: küçük başlık ve içerik. Bölümler arasında tutarlı boşluk.
class _Bolum extends StatelessWidget {
  const _Bolum({required this.baslik, required this.child});

  final String baslik;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          baslik,
          style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1, kalinlik: OkumaTema.kalinlikBaslik),
        ),
        const SizedBox(height: OkumaTema.bosluk8),
        child,
      ],
    );
  }
}

/// Öneri kutusu: eşit yükseklik, seçili olduğunda dolgu ve onay simgesi (renk tek başına taşımaz).
class _SecimKutusu extends StatelessWidget {
  const _SecimKutusu({required this.etiket, required this.secili, required this.onTap});

  final String etiket;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sekil = BorderRadius.circular(OkumaTema.koseButon);
    return Semantics(
      button: true,
      selected: secili,
      label: etiket,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: secili ? OkumaTema.primarySoft : OkumaTema.surface,
          shape: RoundedRectangleBorder(
            borderRadius: sekil,
            side: BorderSide(
              color: secili ? OkumaTema.primary : OkumaTema.muted,
              width: secili ? OkumaTema.kenarSecili : OkumaTema.kenarVarsayilan,
            ),
          ),
          child: InkWell(
            borderRadius: sekil,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: OkumaTema.butonYukseklik - 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk8),
                child: Row(
                  children: [
                    Icon(
                      secili ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: OkumaTema.ikonOrta,
                      color: secili ? OkumaTema.primary : OkumaTema.muted,
                    ),
                    const SizedBox(width: OkumaTema.bosluk8),
                    Expanded(
                      child: Text(
                        etiket,
                        style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.25),
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

/// Tek yıldız: 56 dp dokunma alanı, 44 dp ikon. Seçili yıldız sarı dolgu ve ink kenarla (kenar metni taşır).
class _YildizDugmesi extends StatelessWidget {
  const _YildizDugmesi({required this.deger, required this.secili, required this.onTap});

  final int deger;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$deger yıldız',
      child: Semantics(
        button: true,
        selected: secili,
        label: '$deger yıldız',
        onTap: onTap,
        child: ExcludeSemantics(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: OkumaTema.yildizDokunma,
              height: OkumaTema.yildizDokunma,
              child: Center(
                child: secili
                    ? const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.star_rounded, color: OkumaTema.sun, size: OkumaTema.ikonBuyuk),
                          Icon(Icons.star_outline_rounded, color: OkumaTema.ink, size: OkumaTema.ikonBuyuk),
                        ],
                      )
                    : const Icon(Icons.star_outline_rounded, color: OkumaTema.muted, size: OkumaTema.ikonBuyuk),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EvetHayir extends StatelessWidget {
  const _EvetHayir({required this.soru, required this.deger, required this.onSec});

  final String soru;
  final bool? deger;
  final ValueChanged<bool> onSec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(soru, style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1, kalinlik: OkumaTema.kalinlikVurgu)),
        const SizedBox(height: OkumaTema.bosluk8),
        Row(
          children: [
            ChoiceChip(label: const Text(OkumaMetin.anketEvet), selected: deger == true, onSelected: (_) => onSec(true)),
            const SizedBox(width: OkumaTema.bosluk8),
            ChoiceChip(label: const Text(OkumaMetin.anketHayir), selected: deger == false, onSelected: (_) => onSec(false)),
          ],
        ),
      ],
    );
  }
}
