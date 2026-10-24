import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_kahraman.dart';
import '../../providers/app_providers.dart';
import '../../providers/okuma_providers.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/kahraman_gorsel.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Kahraman seçimi. Hedef: çocuk hikâyesinin kahramanını kendi seçer (cinsiyet sorusu yok).
/// Ana eylem: "Hikâyeleri gör". Ad ve yol arkadaşı adı yalnız cihaz belleğinde kalır;
/// "Kahramanlarım" rafı kullanıcı isterse (varsayılan kapalı) bu cihaza kaydeder, çıkışta silinir.
class KahramanSecimEkrani extends ConsumerStatefulWidget {
  const KahramanSecimEkrani({super.key, required this.onDevam, this.onGeri});

  /// Seçim tamamlandı. Ad sunucuya gitmez.
  final void Function(KahramanSecimi secim) onDevam;
  final VoidCallback? onGeri;

  @override
  ConsumerState<KahramanSecimEkrani> createState() => _KahramanSecimEkraniState();
}

class _KahramanSecimEkraniState extends ConsumerState<KahramanSecimEkrani> {
  KahramanTuru? _tur;
  final _ad = TextEditingController();
  final _yoldasAd = TextEditingController();
  bool _yoldasVar = false;
  bool _kaydet = false;
  late List<KahramanSecimi> _raf;

  @override
  void initState() {
    super.initState();
    _raf = ref.read(okumaCihazDeposuProvider).kahramanlarim();
  }

  @override
  void dispose() {
    _ad.dispose();
    _yoldasAd.dispose();
    super.dispose();
  }

  /// Çocuğun profil adının ilk sözcüğü (öneri için; yalnız cihazda kullanılır).
  String get _profilAdi {
    final tam = ref.watch(profileProvider).valueOrNull?.fullName?.trim() ?? '';
    return tam.isEmpty ? '' : tam.split(RegExp(r'\s+')).first;
  }

  /// Devam engelinin nedeni; null ise seçim tamamdır. Pasif düğmenin yanında gösterilir.
  String? get _neden {
    final t = _tur;
    if (t == null) return OkumaMetin.kahramanDevamPasif;
    if (t.adIster) {
      final hata = adKontrol(_ad.text, tur: t);
      if (hata != null) return hata;
    }
    if (_yoldasVar && adKontrol(_yoldasAd.text) != null) return OkumaMetin.kahramanYoldasAdHata;
    return null;
  }

  Future<void> _devam() async {
    final t = _tur!;
    final secim = KahramanSecimi(
      tur: t,
      ad: t.adIster ? _ad.text.trim() : kHazirKahramanAdi,
      yoldasAd: _yoldasVar ? _yoldasAd.text.trim() : null,
    );
    // Raf yalnız kullanıcı açıkça isterse ve gerçek bir ad varsa güncellenir.
    if (_kaydet && t.adIster) await ref.read(okumaCihazDeposuProvider).kahramanKaydet(secim);
    widget.onDevam(secim);
  }

  void _isimYaz(String isim) {
    _ad.value = TextEditingValue(text: isim, selection: TextSelection.collapsed(offset: isim.length));
    setState(() {});
  }

  Future<void> _rafSil(KahramanSecimi k) async {
    await ref.read(okumaCihazDeposuProvider).kahramanSil(k);
    if (!mounted) return;
    setState(() => _raf = ref.read(okumaCihazDeposuProvider).kahramanlarim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(OkumaMetin.kahramanSilindi)));
  }

  @override
  Widget build(BuildContext context) {
    final t = _tur;
    final neden = _neden;
    final profil = _profilAdi;
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      geri: widget.onGeri,
      icerik: [
        const BaslikSatiri(
          baslik: OkumaMetin.kahramanBaslik,
          alt: OkumaMetin.kahramanAlt,
          maskot: OkumaMaskot(poz: HupoPose.hosgeldin, boyut: OkumaTema.hupoKarsilama),
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        if (_raf.isNotEmpty) ...[
          _KahramanlarimRafi(raf: _raf, onSec: widget.onDevam, onSil: _rafSil),
          const SizedBox(height: OkumaTema.bosluk20),
        ],
        _KahramanIzgara(
          secili: t,
          onSec: (tur) => setState(() => _tur = tur),
        ),
        if (t != null && kOnerilenIsimler[t] != null) ...[
          const SizedBox(height: OkumaTema.bosluk20),
          Text(
            OkumaMetin.kahramanOnerilen,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu),
          ),
          const SizedBox(height: OkumaTema.bosluk8),
          Wrap(
            spacing: OkumaTema.bosluk8,
            runSpacing: OkumaTema.bosluk8,
            children: [
              for (final isim in kOnerilenIsimler[t]!) ActionChip(label: Text(isim), onPressed: () => _isimYaz(isim)),
            ],
          ),
        ],
        if (t != null && t.adIster) ...[
          const SizedBox(height: OkumaTema.bosluk24),
          _AdAlani(
            denetleyici: _ad,
            tur: t,
            hint: _ipucu(t),
            onChanged: () => setState(() {}),
            profilOnerisi: t == KahramanTuru.ben && profil.isNotEmpty && _ad.text.isEmpty ? profil : null,
            onProfilOneri: () => _isimYaz(profil),
          ),
        ],
        const SizedBox(height: OkumaTema.bosluk24),
        OkumaKart(
          padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16, vertical: OkumaTema.bosluk8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      OkumaMetin.kahramanYoldas,
                      style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1, kalinlik: OkumaTema.kalinlikVurgu),
                    ),
                  ),
                  Switch(value: _yoldasVar, onChanged: (v) => setState(() => _yoldasVar = v)),
                ],
              ),
              if (_yoldasVar)
                Padding(
                  padding: const EdgeInsets.only(bottom: OkumaTema.bosluk12),
                  child: TextField(
                    controller: _yoldasAd,
                    maxLength: 24,
                    buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: OkumaMetin.kahramanYoldasAd,
                      errorText: _yoldasAd.text.isEmpty ? null : adKontrol(_yoldasAd.text),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk12),
        if (t != null && t.adIster)
          OkumaKart(
            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16, vertical: OkumaTema.bosluk8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    OkumaMetin.kahramanKaydet,
                    style: OkumaTema.yazi(OkumaTema.yaziSecenek - 1, kalinlik: OkumaTema.kalinlikVurgu),
                  ),
                ),
                Switch(value: _kaydet, onChanged: (v) => setState(() => _kaydet = v)),
              ],
            ),
          ),
        const SizedBox(height: OkumaTema.bosluk12),
        Row(
          children: [
            const Icon(Icons.lock_outline_rounded, size: OkumaTema.ikonKucuk, color: OkumaTema.muted),
            const SizedBox(width: OkumaTema.bosluk8),
            Expanded(
              child: Text(
                OkumaMetin.kahramanGizlilik,
                style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
              ),
            ),
          ],
        ),
      ],
      altEylem: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (neden != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                neden,
                textAlign: TextAlign.center,
                style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
              ),
            ),
            const SizedBox(height: OkumaTema.bosluk8),
          ],
          OkumaButon(etiket: OkumaMetin.kahramanDevam, onPressed: neden == null ? _devam : null),
        ],
      ),
    );
  }

  String _ipucu(KahramanTuru t) => switch (t) {
        KahramanTuru.hayvan => 'Örn. Pati',
        KahramanTuru.arac => 'Örn. Mavi Şimşek',
        KahramanTuru.hayali => 'Örn. Işık Muhafızı',
        _ => OkumaMetin.kahramanAdIpucu,
      };
}

/// "Kahramanlarım": bu cihaza kaydedilenler. Dokununca hemen devam edilir; çöp kutusu siler.
class _KahramanlarimRafi extends StatelessWidget {
  const _KahramanlarimRafi({required this.raf, required this.onSec, required this.onSil});

  final List<KahramanSecimi> raf;
  final void Function(KahramanSecimi) onSec;
  final void Function(KahramanSecimi) onSil;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            OkumaMetin.kahramanlarimBaslik,
            style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikBaslik),
          ),
        ),
        const SizedBox(height: OkumaTema.bosluk4),
        Text(
          OkumaMetin.kahramanlarimAlt,
          style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
        ),
        const SizedBox(height: OkumaTema.bosluk8),
        Wrap(
          spacing: OkumaTema.bosluk8,
          runSpacing: OkumaTema.bosluk8,
          children: [
            for (final k in raf)
              InputChip(
                key: ValueKey('kahraman-raf-${k.tur.kod}-${k.ad}'),
                avatar: Icon(_ikon(k.tur), size: OkumaTema.ikonKucuk, color: OkumaTema.primaryDark),
                label: Text(k.ad),
                onPressed: () => onSec(k),
                deleteIcon: const Icon(Icons.delete_outline_rounded, size: OkumaTema.ikonKucuk),
                deleteButtonTooltipMessage: OkumaMetin.kahramanSilEtiket(k.ad),
                onDeleted: () => onSil(k),
              ),
          ],
        ),
      ],
    );
  }
}

IconData _ikon(KahramanTuru t) => switch (t) {
      KahramanTuru.hazir => Icons.auto_awesome_rounded,
      KahramanTuru.ben => Icons.face_rounded,
      KahramanTuru.anne || KahramanTuru.baba => Icons.family_restroom_rounded,
      KahramanTuru.kardes => Icons.people_rounded,
      KahramanTuru.arkadas => Icons.people_alt_rounded,
      KahramanTuru.baskaBiri => Icons.person_outline_rounded,
      KahramanTuru.hayvan => Icons.pets_rounded,
      KahramanTuru.arac => Icons.directions_car_rounded,
      KahramanTuru.hayali => Icons.stars_rounded,
    };

/// Ad alanı: etiket, 24 karakter sınırı, sayaç ve isteğe bağlı profil önerisi.
class _AdAlani extends StatelessWidget {
  const _AdAlani({
    required this.denetleyici,
    required this.tur,
    required this.hint,
    required this.onChanged,
    required this.onProfilOneri,
    this.profilOnerisi,
  });

  final TextEditingController denetleyici;
  final KahramanTuru tur;
  final String hint;
  final VoidCallback onChanged;
  final String? profilOnerisi;
  final VoidCallback onProfilOneri;

  @override
  Widget build(BuildContext context) {
    final metin = denetleyici.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(OkumaMetin.kahramanAdEtiket, style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu)),
        const SizedBox(height: OkumaTema.bosluk8),
        TextField(
          controller: denetleyici,
          maxLength: 24,
          buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(hintText: hint, errorText: metin.isEmpty ? null : adKontrol(metin, tur: tur)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: OkumaTema.bosluk4),
            child: Text('${metin.runes.length}/24', style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted)),
          ),
        ),
        if (profilOnerisi != null) ...[
          const SizedBox(height: OkumaTema.bosluk8),
          ActionChip(
            avatar: const Icon(Icons.person_rounded, size: OkumaTema.ikonKucuk),
            label: Text(OkumaMetin.kahramanProfilOneri(profilOnerisi!)),
            onPressed: onProfilOneri,
          ),
        ],
      ],
    );
  }
}

/// Kahraman renk ailesi: yumuşak zemin ve vurgu (kenar, ikon). Yalnız AppColors.
class _KartRengi {
  const _KartRengi(this.zemin, this.vurgu);
  final Color zemin;
  final Color vurgu;
}

_KartRengi _rengi(KahramanTuru t) => switch (t) {
      KahramanTuru.hazir => const _KartRengi(OkumaTema.sunSoft, OkumaTema.primaryDark),
      KahramanTuru.ben => const _KartRengi(OkumaTema.primarySoft, OkumaTema.primary),
      KahramanTuru.anne => const _KartRengi(OkumaTema.coralSoft, OkumaTema.coralDark),
      KahramanTuru.baba => const _KartRengi(OkumaTema.mintSoft, OkumaTema.mintDark),
      KahramanTuru.kardes => const _KartRengi(OkumaTema.sunSoft, OkumaTema.primaryDark),
      KahramanTuru.arkadas => const _KartRengi(OkumaTema.mintSoft, OkumaTema.primaryDark),
      KahramanTuru.baskaBiri => const _KartRengi(OkumaTema.line, OkumaTema.skyDark),
      KahramanTuru.hayvan => const _KartRengi(OkumaTema.coralSoft, OkumaTema.coralDark),
      KahramanTuru.arac => const _KartRengi(OkumaTema.primarySoft, OkumaTema.primaryDark),
      KahramanTuru.hayali => const _KartRengi(OkumaTema.sunSoft, OkumaTema.primary),
    };

/// Kahraman ızgarası. Geniş ekranda 5 sütun, telefonda 3; yazı çok büyükse 2 sütun.
/// Satırlar IntrinsicHeight ile eşit yükseklikte olur; etiket metni sarar.
class _KahramanIzgara extends StatelessWidget {
  const _KahramanIzgara({required this.secili, required this.onSec});

  final KahramanTuru? secili;
  final ValueChanged<KahramanTuru> onSec;

  @override
  Widget build(BuildContext context) {
    final yaziOlcegi = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, kisit) {
        final sutun = kisit.maxWidth >= OkumaTema.kirilimGenis ? 5 : (yaziOlcegi > 1.3 ? 2 : 3);
        const turler = KahramanTuru.values;
        final satirlar = <Widget>[];
        for (var i = 0; i < turler.length; i += sutun) {
          final bitis = i + sutun > turler.length ? turler.length : i + sutun;
          final parca = turler.sublist(i, bitis);
          satirlar.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final t in parca)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(OkumaTema.bosluk4),
                        child: _KahramanKarti(tur: t, secili: secili == t, onTap: () => onSec(t)),
                      ),
                    ),
                  for (var k = parca.length; k < sutun; k++) const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          );
        }
        return Column(children: satirlar);
      },
    );
  }
}

class _KahramanKarti extends StatelessWidget {
  const _KahramanKarti({required this.tur, required this.secili, required this.onTap});

  final KahramanTuru tur;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = _rengi(tur);
    final kenar = secili ? r.vurgu : OkumaTema.muted;
    final sekil = BorderRadius.circular(OkumaTema.koseKart);
    return Semantics(
      button: true,
      selected: secili,
      label: 'Kahraman: ${tur.etiket}',
      onTap: onTap,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(boxShadow: const [BoxShadow(color: OkumaTema.lineDark, offset: Offset(0, OkumaTema.kabartmaKart))], borderRadius: sekil),
          child: Material(
            color: secili ? r.zemin : OkumaTema.surface,
            shape: RoundedRectangleBorder(
              borderRadius: sekil,
              side: BorderSide(color: kenar, width: secili ? OkumaTema.kenarSecili : OkumaTema.kenarVarsayilan),
            ),
            child: InkWell(
              borderRadius: sekil,
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: OkumaTema.kartMinYukseklik),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8, vertical: OkumaTema.bosluk12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: OkumaTema.hupoKapakCikartma,
                        height: OkumaTema.hupoKapakCikartma,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            if (tur == KahramanTuru.hazir)
                              const OkumaMaskot(poz: HupoPose.hosgeldin, boyut: OkumaTema.hupoKapakCikartma)
                            else
                              KahramanGorsel(
                                turKodu: tur.kod,
                                boyut: OkumaTema.hupoKapakCikartma,
                                yedek: Container(
                                  width: OkumaTema.hupoKapakCikartma,
                                  height: OkumaTema.hupoKapakCikartma,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: secili ? OkumaTema.surface : r.zemin),
                                  child: Icon(_ikon(tur), color: r.vurgu, size: OkumaTema.ikonBuyuk - 16),
                                ),
                              ),
                            if (secili)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Icon(Icons.check_circle_rounded, color: r.vurgu, size: OkumaTema.ikonOrta),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: OkumaTema.bosluk8),
                      Text(
                        tur.etiket,
                        textAlign: TextAlign.center,
                        style: OkumaTema.yazi(OkumaTema.yaziHata, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
