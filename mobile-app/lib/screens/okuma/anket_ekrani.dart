import 'package:flutter/material.dart';

import '../../models/okuma_models.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';


/// Hikâyeyi sevme anketi. Hedef: çocuk hikâyeyi puanlar (1–5 yıldız zorunlu, sunucu sözleşmesi) ve isterse
/// nasıl daha iyi olacağını seçer. Ödülsüz, atlanabilir, serbest metin yok. Ana eylem: "Gönder" (yıldız
/// seçilince açılır); ikincil: "Şimdi değil". Yanıtlar yalnız hikâye geliştirme içindir.

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

  bool get _yanitVar => _yildiz != null;

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
        const SizedBox(height: OkumaTema.bosluk24),
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
              for (var i = 1; i <= 5; i++) _YildizDugmesi(deger: i, secili: yildiz != null && i <= yildiz, onTap: () => _yildizSec(i)),
            ],
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk8),
        Center(
          child: Text(
            yildiz == null ? OkumaMetin.anketYildizBos : OkumaMetin.anketYildiz(yildiz),
            style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu),
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk24),
        Text(
          OkumaMetin.anketDaha,
          style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1, kalinlik: OkumaTema.kalinlikVurgu),
        ),
        const SizedBox(height: OkumaTema.bosluk8),
        Wrap(
          spacing: OkumaTema.bosluk8,
          runSpacing: OkumaTema.bosluk8,
          children: [
            for (final (kod, etiket) in OkumaMetin.anketSecenekleri)
              FilterChip(
                label: Text(etiket),
                selected: _iyilestirmeler.contains(kod),
                onSelected: (v) => _iyilestirmeDegistir(kod, v),
              ),
          ],
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
        const SizedBox(height: OkumaTema.bosluk24),
        _EvetHayir(
          soru: OkumaMetin.anketBaskaKahraman,
          deger: _baskaKahraman,
          onSec: (v) => setState(() => _baskaKahraman = v),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        _EvetHayir(
          soru: OkumaMetin.anketBaskaHikaye,
          deger: _ayniTur,
          onSec: (v) => setState(() => _ayniTur = v),
        ),
        if (!_yanitVar) ...[
          const SizedBox(height: OkumaTema.bosluk24),
          Text(
            OkumaMetin.anketPasif,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
          ),
        ],
      ],
      altEylem: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OkumaButon(etiket: OkumaMetin.anketGonder, onPressed: _yanitVar ? _gonder : null),
          const SizedBox(height: OkumaTema.bosluk8),
          OkumaIkincilButon(
            etiket: OkumaMetin.anketSimdiDegil,
            onPressed: () => widget.onBitti(null),
          ),
        ],
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
        Wrap(
          spacing: OkumaTema.bosluk8,
          runSpacing: OkumaTema.bosluk8,
          children: [
            ChoiceChip(label: const Text(OkumaMetin.anketEvet), selected: deger == true, onSelected: (_) => onSec(true)),
            ChoiceChip(label: const Text(OkumaMetin.anketHayir), selected: deger == false, onSelected: (_) => onSec(false)),
          ],
        ),
      ],
    );
  }
}
