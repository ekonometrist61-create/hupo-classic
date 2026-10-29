import 'package:flutter/material.dart';

import '../../models/okuma_models.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/question_text.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Cevabı sunucuya gönderip sonucu döner (okuma_cevap_kontrol). Doğru anahtar istemcide yoktur.
typedef OkumaCevapKaynagi = Future<OkumaCevapSonucu> Function(
    String soruId, String secenekId);

/// Tek soru, tek deneme, anında geri bildirim (K-0036, H1). Akış: seç → Cevapla → geri bildirim.
/// Seçim cevaplamadan önce değiştirilebilir. Yanlışta kırmızı X ve ceza yok.
/// Cevaptan sonra sonraki soruya geçiş çocuğun kararıyla olur ("Sonraki soru"). Otomatik geçiş yoktur:
/// açıklama, çocuk okumadan ekran değişmez (WCAG 2.2.1). Son soruda sonuç düğmesi ekranda kalır (K-0048).
/// Geri düğmesi her zaman görünür; çıkış onay ister, çünkü yarım kalan cevaplar devam etmez.
class SorularEkrani extends StatefulWidget {
  const SorularEkrani({
    super.key,
    required this.sorular,
    required this.cevapKontrol,
    required this.onBitti,
    required this.onGeri,
  });

  final List<OkumaSoru> sorular;
  final OkumaCevapKaynagi cevapKontrol;
  final void Function(int dogruSayisi) onBitti;

  /// Geri düğmesi ve geri tuşu. Onay penceresi üst katmanda gösterilir.
  final VoidCallback onGeri;

  @override
  State<SorularEkrani> createState() => _SorularEkraniState();
}

class _SorularEkraniState extends State<SorularEkrani> {
  int _i = 0;
  int _dogru = 0;
  String? _secilen;
  OkumaCevapSonucu? _geri;
  bool _kontrol = false;
  bool _hata = false;

  /// Her sorunun sonucu: null cevaplanmadı, true doğru, false yanlış. Nokta göstergesi için.
  late List<bool?> _sonuclar;

  /// Cevap sonrası geri bildirim alanı: cevaplanınca bu alan görünür yere kaydırılır ki
  /// açıklama çocuğun seçtiği şıkkın hemen altında, ekranın içinde görünsün.
  final GlobalKey _geriKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _sonuclar = List<bool?>.filled(widget.sorular.length, null);
  }

  bool get _cevaplandi => _geri != null;
  bool get _sonSoru => _i == widget.sorular.length - 1;

  void _sec(String secenekId) {
    if (_cevaplandi || _kontrol) return;
    setState(() {
      _secilen = secenekId;
      _hata = false;
    });
  }

  Future<void> _cevapla() async {
    final secilen = _secilen;
    if (secilen == null || _kontrol || _cevaplandi) return;
    final soruId = widget.sorular[_i].id;
    final soruNo = _i;
    setState(() {
      _kontrol = true;
      _hata = false;
    });
    try {
      final g = await widget.cevapKontrol(soruId, secilen);
      if (!mounted || soruNo != _i) return;
      setState(() {
        _geri = g;
        _kontrol = false;
        _sonuclar[_i] = g.dogru;
        if (g.dogru) _dogru++;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final baglam = _geriKey.currentContext;
        if (!mounted || baglam == null) return;
        Scrollable.ensureVisible(
          baglam,
          alignment: 0.0,
          duration: MediaQuery.disableAnimationsOf(baglam)
              ? Duration.zero
              : const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _kontrol = false;
        _hata = true;
      });
    }
  }

  void _ileri() {
    if (_sonSoru) {
      widget.onBitti(_dogru);
      return;
    }
    setState(() {
      _i++;
      _secilen = null;
      _geri = null;
      _hata = false;
    });
  }

  void _ipucuAc(String ipucu) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk8,
              OkumaTema.yanBoslukTelefon,
              OkumaTema.bosluk20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const OkumaMaskot(
                      poz: HupoPose.ipucuIster, boyut: OkumaTema.hupoIpucu),
                  const SizedBox(width: OkumaTema.bosluk16),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        OkumaMetin.soruIpucuBaslik,
                        style: OkumaTema.yazi(OkumaTema.yaziSoru,
                            kalinlik: OkumaTema.kalinlikBaslik),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OkumaTema.bosluk16),
              Text(
                ipucu,
                style: OkumaTema.yazi(OkumaTema.yaziSecenek, satir: 1.5),
              ),
              const SizedBox(height: OkumaTema.bosluk20),
              OkumaIkincilButon(
                  etiket: OkumaMetin.kapat,
                  onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  _Durum _durum(String secenekId) {
    final g = _geri;
    if (g == null) return secenekId == _secilen ? _Durum.secili : _Durum.bos;
    if (secenekId == _secilen) return g.dogru ? _Durum.dogru : _Durum.yanlis;
    if (secenekId == g.dogruSecenekId) return _Durum.dogruGoster;
    return _Durum.pasif;
  }

  @override
  Widget build(BuildContext context) {
    final soru = widget.sorular[_i];
    final g = _geri;
    final ipucu = soru.dayanakSayfa == null
        ? null
        : OkumaMetin.soruIpucuSayfa(soru.dayanakSayfa!);
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.soruSayac(_i + 1, widget.sorular.length),
      geri: widget.onGeri,
      icerik: [
        Row(
          children: [
            Expanded(child: _NoktaGostergesi(sonuclar: _sonuclar, aktif: _i)),
            if (ipucu != null && !_cevaplandi)
              TextButton.icon(
                onPressed: () => _ipucuAc(ipucu),
                icon: const Icon(Icons.lightbulb_outline_rounded,
                    size: OkumaTema.ikonOrta),
                label: const Text(OkumaMetin.soruIpucu),
              ),
            const SizedBox(width: OkumaTema.bosluk4),
            const OkumaMaskot(
                poz: HupoPose.rehberSol, boyut: OkumaTema.hupoRehber),
          ],
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        Semantics(
          header: true,
          child: SoruMetni(
            soru.metin,
            highlights: soru.highlights,
            style: OkumaTema.yazi(OkumaTema.yaziSoru,
                kalinlik: OkumaTema.kalinlikVurgu, satir: OkumaTema.satirSoru),
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk24),
        for (var k = 0; k < soru.secenekler.length; k++) ...[
          _SecenekKarti(
            harf: 'ABCD'[k],
            metin: soru.secenekler[k].metin,
            durum: _durum(soru.secenekler[k].id),
            onTap: (_cevaplandi || _kontrol)
                ? null
                : () => _sec(soru.secenekler[k].id),
          ),
          if (k < soru.secenekler.length - 1)
            const SizedBox(height: OkumaTema.secenekAraligi),
        ],
        if (g != null) ...[
          const SizedBox(height: OkumaTema.bosluk20),
          KeyedSubtree(
            key: _geriKey,
            child: _GeriBildirimAlani(key: ValueKey<int>(_i), geri: g),
          ),
        ],
      ],
      altEylem: _altEylem(g),
    );
  }

  Widget _altEylem(OkumaCevapSonucu? g) {
    if (g != null) {
      return OkumaButon(
        etiket: _sonSoru ? OkumaMetin.soruSonuc : OkumaMetin.soruSonraki,
        onPressed: _ileri,
      );
    }
    if (_kontrol) {
      return const OkumaButon(
          etiket: OkumaMetin.soruCevapla, onPressed: null, yukleniyor: true);
    }
    if (_hata) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: OkumaTema.coralDark, size: OkumaTema.ikonOrta),
                const SizedBox(width: OkumaTema.bosluk8),
                Expanded(
                  child: Text(
                    OkumaMetin.soruKaydedilmedi,
                    style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                        kalinlik: OkumaTema.kalinlikVurgu,
                        renk: OkumaTema.coralDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: OkumaTema.bosluk12),
          OkumaButon(etiket: OkumaMetin.yenidenDene, onPressed: _cevapla),
        ],
      );
    }
    final secili = _secilen != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!secili) ...[
          Text(
            OkumaMetin.soruSecKisa,
            textAlign: TextAlign.center,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
          const SizedBox(height: OkumaTema.bosluk8),
        ],
        OkumaButon(
          etiket: OkumaMetin.soruCevapla,
          onPressed: secili ? _cevapla : null,
        ),
      ],
    );
  }
}

/// Şık durumları. Her durum renk YANINDA ikon ya da metinle de anlatılır.
enum _Durum { bos, secili, dogru, yanlis, dogruGoster, pasif }

class _SecenekKarti extends StatelessWidget {
  const _SecenekKarti(
      {required this.harf,
      required this.metin,
      required this.durum,
      this.onTap});

  final String harf;
  final String metin;
  final _Durum durum;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (zemin, kenar, kalinlik, rozetZemin, rozetYazi) = switch (durum) {
      _Durum.bos => (
          OkumaTema.surface,
          OkumaTema.muted,
          OkumaTema.kenarVarsayilan,
          OkumaTema.surface,
          OkumaTema.ink
        ),
      _Durum.secili => (
          OkumaTema.primarySoft,
          OkumaTema.primary,
          OkumaTema.kenarSecili,
          OkumaTema.primary,
          OkumaTema.surface
        ),
      _Durum.dogru => (
          OkumaTema.mintSoft,
          OkumaTema.mintDark,
          OkumaTema.kenarUyari,
          OkumaTema.mintDark,
          OkumaTema.surface
        ),
      _Durum.yanlis => (
          OkumaTema.coralSoft,
          OkumaTema.coralDark,
          OkumaTema.kenarUyari,
          OkumaTema.coralDark,
          OkumaTema.surface
        ),
      _Durum.dogruGoster => (
          OkumaTema.mintSoft,
          OkumaTema.mintDark,
          OkumaTema.kenarUyari,
          OkumaTema.mintDark,
          OkumaTema.surface
        ),
      _Durum.pasif => (
          OkumaTema.surface,
          OkumaTema.lineDark,
          OkumaTema.kenarVarsayilan,
          OkumaTema.lineDark,
          OkumaTema.ink
        ),
    };
    final durumEtiketi = switch (durum) {
      _Durum.secili => 'Seçili',
      _Durum.dogru => 'Doğru',
      _Durum.yanlis => 'Bu kez olmadı',
      _Durum.dogruGoster => 'Doğru cevap',
      _ => 'Seçilmedi',
    };
    final sekil = BorderRadius.circular(OkumaTema.koseButon);
    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: durum == _Durum.secili,
      label: '$harf seçeneği: $metin. $durumEtiketi.',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: zemin,
          shape: RoundedRectangleBorder(
              borderRadius: sekil,
              side: BorderSide(color: kenar, width: kalinlik)),
          child: InkWell(
            borderRadius: sekil,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: OkumaTema.secenekMinYukseklik),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: OkumaTema.bosluk16,
                    vertical: OkumaTema.bosluk12),
                child: Row(
                  children: [
                    Container(
                      width: OkumaTema.dokunmaMin - 12,
                      height: OkumaTema.dokunmaMin - 12,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: rozetZemin),
                      child: Text(
                        harf,
                        style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                            kalinlik: OkumaTema.kalinlikVurgu, renk: rozetYazi),
                      ),
                    ),
                    const SizedBox(width: OkumaTema.bosluk12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metin,
                            style: OkumaTema.yazi(OkumaTema.yaziSecenek,
                                kalinlik: OkumaTema.kalinlikVurgu,
                                satir: 1.35),
                          ),
                          // Durum etiketi metnin altında: yan yana durunca şık metnini dar bir sütuna sıkıştırıyordu.
                          _DurumEtiketi(durum: durum),
                        ],
                      ),
                    ),
                    const SizedBox(width: OkumaTema.bosluk8),
                    _DurumIkonu(durum: durum),
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

/// Şıkların sağındaki durum ikonu ve kısa etiketi (renge ek olarak).
class _DurumIkonu extends StatelessWidget {
  const _DurumIkonu({required this.durum});

  final _Durum durum;

  @override
  Widget build(BuildContext context) {
    switch (durum) {
      case _Durum.secili:
        return const Icon(Icons.check_circle_rounded,
            color: OkumaTema.primary, size: OkumaTema.ikonOrta);
      case _Durum.dogru:
        return const Icon(Icons.check_circle_rounded,
            color: OkumaTema.mintDark, size: OkumaTema.ikonOrta);
      case _Durum.yanlis:
        return const Icon(Icons.lightbulb_outline_rounded,
            color: OkumaTema.coralDark, size: OkumaTema.ikonOrta);
      case _Durum.dogruGoster:
        return const Icon(Icons.check_circle_rounded,
            color: OkumaTema.mintDark, size: OkumaTema.ikonOrta);
      case _Durum.bos:
      case _Durum.pasif:
        return const SizedBox.shrink();
    }
  }
}

/// Şık metninin altındaki kısa durum etiketi ("Seçildi", "Doğru cevap bu"); yalnız bu iki durumda.
class _DurumEtiketi extends StatelessWidget {
  const _DurumEtiketi({required this.durum});

  final _Durum durum;

  @override
  Widget build(BuildContext context) {
    final (metin, renk) = switch (durum) {
      _Durum.secili => (OkumaMetin.soruSecildi, OkumaTema.primaryDark),
      _Durum.dogruGoster => (OkumaMetin.soruDogruCevap, OkumaTema.mintDark),
      _ => (null, OkumaTema.ink),
    };
    if (metin == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: OkumaTema.bosluk4),
      child: Text(metin,
          style: OkumaTema.yazi(OkumaTema.yaziEtiket,
              kalinlik: OkumaTema.kalinlikVurgu, renk: renk)),
    );
  }
}

/// Cevap sonrası geri bildirim: Hupo tepkisi, başlık ve açıklama. Hareket azaltmada anlık.
class _GeriBildirimAlani extends StatelessWidget {
  const _GeriBildirimAlani({super.key, required this.geri});

  final OkumaCevapSonucu geri;

  @override
  Widget build(BuildContext context) {
    final dogru = geri.dogru;
    // Büyük yazıda Hupo başlığın üstüne geçer: dar sütunda başlık kelime ortasından kırılmasın.
    final buyukYazi = MediaQuery.textScalerOf(context).scale(1) > OkumaTema.sonucYaziBuyukEsigi;
    final maskot = OkumaMaskot(
      poz: dogru ? HupoPose.dogru : HupoPose.merakEdiyor,
      boyut: OkumaTema.hupoCevap,
    );
    final metin = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dogru ? OkumaMetin.soruDogru : OkumaMetin.olmadi,
          style: OkumaTema.yazi(
            OkumaTema.yaziSoru,
            kalinlik: OkumaTema.kalinlikBaslik,
            renk: dogru ? OkumaTema.mintDark : OkumaTema.coralDark,
          ),
        ),
        if (!dogru) ...[
          const SizedBox(height: OkumaTema.bosluk4),
          Text(
            OkumaMetin.soruAciklamaya,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci,
                kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: OkumaTema.sure(context, OkumaTema.hareketDogruIkon),
          curve: Curves.easeOutBack,
          builder: (context, t, child) {
            final gorunur = t < 0 ? 0.0 : (t > 1 ? 1.0 : t);
            return Transform.scale(
              scale: 0.8 + 0.2 * t,
              child: Opacity(opacity: gorunur, child: child),
            );
          },
          child: Semantics(
            liveRegion: true,
            child: buyukYazi
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [maskot, const SizedBox(height: OkumaTema.bosluk8), metin],
                  )
                : Row(
                    children: [
                      maskot,
                      const SizedBox(width: OkumaTema.bosluk12),
                      Expanded(child: metin),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: OkumaTema.sure(context, OkumaTema.hareketAciklama),
          curve: Curves.easeOut,
          builder: (context, t, child) {
            final gorunur = t < 0 ? 0.0 : (t > 1 ? 1.0 : t);
            return Opacity(
              opacity: gorunur,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * OkumaTema.hareketAciklamaYukselme),
                child: child,
              ),
            );
          },
          child: OkumaKart(
            kenar: dogru ? OkumaTema.mintDark : OkumaTema.coralDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OkumaMetin.soruAciklama,
                  style: OkumaTema.yazi(OkumaTema.yaziSecenek,
                      kalinlik: OkumaTema.kalinlikVurgu),
                ),
                const SizedBox(height: OkumaTema.bosluk8),
                Text(
                  geri.aciklama,
                  style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1,
                      satir: OkumaTema.satirGovde),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Soru ilerleme göstergesi: cevaplanan dolu nokta, şu anki soru halka, bekleyen içi boş. Renge ek olarak biçim farkı var.
class _NoktaGostergesi extends StatelessWidget {
  const _NoktaGostergesi({required this.sonuclar, required this.aktif});

  final List<bool?> sonuclar;
  final int aktif;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: OkumaMetin.soruSayac(aktif + 1, sonuclar.length),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var k = 0; k < sonuclar.length; k++)
              Padding(
                padding: const EdgeInsets.only(right: OkumaTema.bosluk8),
                child: Container(
                  width: OkumaTema.bosluk12,
                  height: OkumaTema.bosluk12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sonuclar[k] != null ? OkumaTema.primary : null,
                    border: Border.all(
                      color: k == aktif ? OkumaTema.primary : OkumaTema.muted,
                      width: k == aktif
                          ? OkumaTema.odakHalkaKalinligi
                          : OkumaTema.kenarVarsayilan,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
