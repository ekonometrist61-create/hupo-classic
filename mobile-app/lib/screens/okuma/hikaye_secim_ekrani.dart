import 'package:flutter/material.dart';

import '../../models/okuma_models.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Hikâye seçme ekranı. Hedef: çocuk, kahramanına uygun hikâyelerden birini seçer.
/// Ana eylem: bir hikâye kartına dokunmak. Durumlar: yükleniyor, hata (yeniden dene), boş
/// (bu kahramana uygun hikâye yok), filtre boş, geri dönüş mesajı.
class HikayeSecimEkrani extends StatefulWidget {
  const HikayeSecimEkrani({
    super.key,
    this.ilkTur,
    required this.katalog,
    required this.kahramanAdi,
    required this.onSec,
    required this.onGeri,
    this.yukleniyor = false,
    this.hata,
    this.onYenidenDene,
    this.onOkuduklarim,
    this.geriDonusMesaji,
  });

  final List<OkumaKatalogSatiri> katalog;

  /// Verilirse liste bu türle filtreli açılır (kategori kapağından).
  final String? ilkTur;

  /// Başlıkta gösterilir; yalnız cihazda kalır.
  final String kahramanAdi;
  final void Function(OkumaKatalogSatiri) onSec;
  final VoidCallback onGeri;
  final bool yukleniyor;
  final String? hata;
  final VoidCallback? onYenidenDene;

  /// null ise "Okuduklarım" düğmesi gösterilmez.
  final VoidCallback? onOkuduklarim;

  /// Uzun süre okumayan çocuk için nazik geri dönüş mesajı (null ise gösterilmez).
  final String? geriDonusMesaji;

  @override
  State<HikayeSecimEkrani> createState() => _HikayeSecimEkraniState();
}

class _HikayeSecimEkraniState extends State<HikayeSecimEkrani> {
  late String? _tur = widget.ilkTur;

  @override
  Widget build(BuildContext context) {
    final uygunlar = widget.katalog;
    final turler = {for (final h in uygunlar) h.tur}.toList();
    final liste = uygunlar.where((h) => _tur == null || h.tur == _tur).toList();
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      geri: widget.onGeri,
      eylemler: [
        if (widget.onOkuduklarim != null)
          IconButton(
            tooltip: OkumaMetin.okuduklarimBaslik,
            icon: const Icon(Icons.auto_stories_rounded),
            onPressed: widget.onOkuduklarim,
          ),
      ],
      icerik: [
        BaslikSatiri(
          baslik: OkumaMetin.hikayeBaslik,
          alt: OkumaMetin.hikayeAlt(widget.kahramanAdi),
          maskotSolda: false,
          maskot: const OkumaMaskot(poz: HupoPose.merakEdiyor, boyut: OkumaTema.hupoBaslik),
        ),
        if (widget.geriDonusMesaji != null) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          Container(
            padding: const EdgeInsets.all(OkumaTema.bosluk16),
            decoration: BoxDecoration(color: OkumaTema.sunSoft, borderRadius: BorderRadius.circular(OkumaTema.koseKart)),
            child: Text(
              widget.geriDonusMesaji!,
              style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu),
            ),
          ),
        ],
        const SizedBox(height: OkumaTema.bosluk20),
        if (widget.yukleniyor)
          const _Yukleniyor()
        else if (widget.hata != null)
          DurumEkrani(
            poz: HupoPose.birDahaDene,
            baslik: widget.hata!,
            birincilEtiket: OkumaMetin.yenidenDene,
            birincil: widget.onYenidenDene,
            ikincilEtiket: OkumaMetin.kahramanDegistir,
            ikincil: widget.onGeri,
          )
        else ...[
          if (turler.isNotEmpty)
            Wrap(
              spacing: OkumaTema.bosluk8,
              runSpacing: OkumaTema.bosluk8,
              children: [
                ChoiceChip(
                  label: const Text(OkumaMetin.hikayeHepsi),
                  selected: _tur == null,
                  onSelected: (_) => setState(() => _tur = null),
                ),
                for (final t in turler)
                  ChoiceChip(
                    label: Text(_turStili(t).etiket),
                    selected: _tur == t,
                    onSelected: (_) => setState(() => _tur = t),
                  ),
              ],
            ),
          const SizedBox(height: OkumaTema.bosluk20),
          if (uygunlar.isEmpty)
            DurumEkrani(
              poz: HupoPose.dusunuyor,
              baslik: OkumaMetin.hikayeKahramanYokBaslik,
              aciklama: OkumaMetin.hikayeKahramanYok,
              birincilEtiket: OkumaMetin.kahramanDegistir,
              birincil: widget.onGeri,
            )
          else if (liste.isEmpty)
            DurumEkrani(
              poz: HupoPose.dusunuyor,
              baslik: OkumaMetin.hikayeBos,
              aciklama: OkumaMetin.hikayeBosIpucu,
              birincilEtiket: OkumaMetin.hikayeFiltreTemizle,
              birincil: () => setState(() => _tur = null),
            )
          else
            for (final h in liste)
              Padding(
                padding: const EdgeInsets.only(bottom: OkumaTema.bosluk16),
                child: _HikayeKapak(hikaye: h, onTap: () => widget.onSec(h)),
              ),
        ],
      ],
    );
  }
}

class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: OkumaMetin.hikayeYukleniyor,
      child: Column(
        children: [
          const OkumaMaskot(poz: HupoPose.dusunuyor, boyut: OkumaTema.hupoOrta),
          const SizedBox(height: OkumaTema.bosluk16),
          Text(
            OkumaMetin.hikayeYukleniyor,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
          const SizedBox(height: OkumaTema.bosluk16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

/// Tür görünümü: bant rengi, bant üstü metin rengi ve ikon. Renkler yalnız AppColors'tan gelir.
class _TurStili {
  const _TurStili({required this.etiket, required this.bant, required this.bantMetin, required this.ikon, required this.ikonRengi});

  final String etiket;
  final Color bant;
  final Color bantMetin;
  final IconData ikon;
  final Color ikonRengi;
}

_TurStili _turStili(String kod) => switch (kod) {
      'gizem' => const _TurStili(
          etiket: 'Gizem', bant: OkumaTema.primary, bantMetin: OkumaTema.surface, ikon: Icons.search_rounded, ikonRengi: OkumaTema.primary),
      'macera' => const _TurStili(
          etiket: 'Macera', bant: OkumaTema.coralDark, bantMetin: OkumaTema.surface, ikon: Icons.explore_rounded, ikonRengi: OkumaTema.coralDark),
      'bilim' => const _TurStili(
          etiket: 'Bilim', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.science_rounded, ikonRengi: OkumaTema.primaryDark),
      'doga' => const _TurStili(
          etiket: 'Doğa', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.eco_rounded, ikonRengi: OkumaTema.mintDark),
      'mizah' => const _TurStili(
          etiket: 'Mizah', bant: OkumaTema.sun, bantMetin: OkumaTema.ink, ikon: Icons.sentiment_very_satisfied_rounded, ikonRengi: OkumaTema.ink),
      'hayvanlar' => const _TurStili(
          etiket: 'Hayvanlar', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.pets_rounded, ikonRengi: OkumaTema.mintDark),
      'arkadaslik' => const _TurStili(
          etiket: 'Arkadaşlık', bant: OkumaTema.coralDark, bantMetin: OkumaTema.surface, ikon: Icons.people_rounded, ikonRengi: OkumaTema.coralDark),
      'fantastik' => const _TurStili(
          etiket: 'Fantastik', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.auto_awesome_rounded, ikonRengi: OkumaTema.primaryDark),
      'spor' => const _TurStili(
          etiket: 'Spor', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.directions_bike_rounded, ikonRengi: OkumaTema.mintDark),
      'tarih_kultur' => const _TurStili(
          etiket: 'Tarih ve Kültür', bant: OkumaTema.sun, bantMetin: OkumaTema.ink, ikon: Icons.account_balance_rounded, ikonRengi: OkumaTema.ink),
      'bilim_kurgu' => const _TurStili(
          etiket: 'Bilim Kurgu', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.rocket_launch_rounded, ikonRengi: OkumaTema.primaryDark),
      'gezi_kultur' => const _TurStili(
          etiket: 'Gezi ve Kültür', bant: OkumaTema.primary, bantMetin: OkumaTema.surface, ikon: Icons.public_rounded, ikonRengi: OkumaTema.primary),
      _ => const _TurStili(
          etiket: 'Hikâye', bant: OkumaTema.lineDark, bantMetin: OkumaTema.ink, ikon: Icons.auto_stories_rounded, ikonRengi: OkumaTema.primaryDark),
    };

class _HikayeKapak extends StatelessWidget {
  const _HikayeKapak({required this.hikaye, required this.onTap});

  final OkumaKatalogSatiri hikaye;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stil = _turStili(hikaye.tur);
    final tanitim = hikaye.tanitim.isEmpty ? null : hikaye.tanitim;
    final sinifEtiketi = '${hikaye.anaSinif}. sınıf';
    final sure = hikaye.tahminiSureDk;
    final ayrinti = [
      sinifEtiketi,
      if (sure != null && sure > 0) OkumaMetin.hikayeSure(sure),
      if (hikaye.soruSayisi > 0) OkumaMetin.hikayeSoru(hikaye.soruSayisi),
    ].join(' · ');
    return Semantics(
      button: true,
      label: 'Hikâye: ${hikaye.baslik}. ${stil.etiket}, $ayrinti.${tanitim == null ? '' : ' $tanitim'}'
          '${hikaye.gorulmedi ? ' Yeni.' : ''} ${OkumaMetin.hikayeBasla}.',
      onTap: onTap,
      child: ExcludeSemantics(
        child: OkumaKart(
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Renkli üst bant ve merak simgesi (bandın alt kenarına taşar).
                SizedBox(
                  height: OkumaTema.hupoBos,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: OkumaTema.hupoBos,
                        color: stil.bant,
                        padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(stil.ikon, color: stil.bantMetin, size: OkumaTema.ikonOrta),
                            const SizedBox(width: OkumaTema.bosluk8),
                            Text(
                              stil.etiket,
                              style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: stil.bantMetin),
                            ),
                            if (hikaye.gorulmedi) ...[
                              const SizedBox(width: OkumaTema.bosluk8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OkumaTema.sunSoft,
                                  borderRadius: BorderRadius.circular(OkumaTema.koseCip),
                                ),
                                child: Text(
                                  OkumaMetin.hikayeYeni,
                                  style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: OkumaTema.bosluk16,
                        bottom: -OkumaTema.bosluk24,
                        child: Container(
                          width: OkumaTema.hupoKapakCikartma,
                          height: OkumaTema.hupoKapakCikartma,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: OkumaTema.surface,
                            border: Border.all(color: stil.bant, width: OkumaTema.kenarSecili),
                            boxShadow: OkumaTema.kartGolge,
                          ),
                          child: Icon(Icons.question_mark_rounded, color: stil.ikonRengi, size: OkumaTema.ikonBuyuk - 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(OkumaTema.bosluk16, OkumaTema.bosluk32, OkumaTema.bosluk16, OkumaTema.bosluk16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hikaye.baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.25),
                      ),
                      if (tanitim != null) ...[
                        const SizedBox(height: OkumaTema.bosluk8),
                        Text(
                          tanitim,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4),
                        ),
                      ],
                      const SizedBox(height: OkumaTema.bosluk12),
                      Wrap(
                        spacing: OkumaTema.bosluk12,
                        runSpacing: OkumaTema.bosluk8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk4),
                            decoration: BoxDecoration(
                              color: OkumaTema.background,
                              borderRadius: BorderRadius.circular(OkumaTema.koseCip),
                              border: Border.all(color: OkumaTema.lineDark, width: OkumaTema.kenarVarsayilan),
                            ),
                            child: Text(ayrinti, style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu)),
                          ),
                          Container(
                            constraints: const BoxConstraints(minHeight: OkumaTema.dokunmaMin),
                            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16),
                            decoration: BoxDecoration(color: OkumaTema.primary, borderRadius: BorderRadius.circular(OkumaTema.koseButon)),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  OkumaMetin.hikayeBasla,
                                  style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.surface),
                                ),
                                const SizedBox(width: OkumaTema.bosluk4),
                                const Icon(Icons.arrow_forward_rounded, color: OkumaTema.surface, size: OkumaTema.ikonOrta),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
