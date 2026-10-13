// Kelime Evreni oyun ekranı: tek bir oyun türü için soru oturumu.
// Hedef: öğrenci bir kelimenin eş anlamlısını / karşıtını / eş sesli anlamını doğru bulur;
// yanlışta açıklamayı görür ve aynı kelimeyi farklı bir soruyla yeniden dener.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/kelime_models.dart';
import '../../providers/kelime_providers.dart';
import '../../services/audio/audio_event.dart';
import '../../services/audio/audio_manager.dart';
import '../../services/kelime_oyun_akisi.dart';
import '../../services/kelime_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';
import '../../utils/motion.dart';
import '../../widgets/answer_option.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/ui/chunky_button.dart';
import '../../widgets/ui/game_card.dart';
import '../../widgets/ui/responsive_page.dart';
import '../grade_picker_screen.dart';
import 'kelime_tema.dart';

const List<String> _harfler = ['A', 'B', 'C', 'D'];

class KelimeOyunScreen extends ConsumerStatefulWidget {
  const KelimeOyunScreen({super.key, required this.iliski});

  final KelimeIliskiTuru iliski;

  @override
  ConsumerState<KelimeOyunScreen> createState() => _KelimeOyunScreenState();
}

class _KelimeOyunScreenState extends ConsumerState<KelimeOyunScreen> {
  late final KelimeOyunAkisi _akis;

  @override
  void initState() {
    super.initState();
    _akis = KelimeOyunAkisi(
      repository: ref.read(kelimeRepositoryProvider),
      iliski: widget.iliski,
    )..addListener(_yenile);
    WidgetsBinding.instance.addPostFrameCallback((_) => _akis.baslat());
  }

  @override
  void dispose() {
    _akis
      ..removeListener(_yenile)
      ..dispose();
    super.dispose();
  }

  void _yenile() {
    if (mounted) setState(() {});
  }

  Future<void> _sec(int secim) async {
    await _akis.cevapla(secim);
    if (!mounted) return;
    final sonuc = _akis.sonuc;
    if (sonuc == null) return;
    if (sonuc.dogru) {
      AppHaptics.success();
      AudioManager.instance.play(AudioEvent.correct);
    } else {
      AppHaptics.error();
      AudioManager.instance.play(AudioEvent.retry);
    }
  }

  void _sonrakiSoru() {
    _akis.sonraki();
    if (_akis.tamamlandi) AppHaptics.celebration();
  }

  Future<void> _kelimeyiKaydet(String anlamId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(kelimeRepositoryProvider).kaydet(anlamId: anlamId, kaydet: true);
      ref.invalidate(kelimeKaydedilenlerProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Kelime kaydettiklerine eklendi.')));
    } on KelimeException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mesaj)));
    }
  }

  Future<void> _sinifSec() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GradePickerScreen()));
    if (mounted) _akis.baslat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsivePage(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              _UstCubuk(iliski: widget.iliski, akis: _akis),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: motionMs(context, 260),
                    child: KeyedSubtree(
                      key: ValueKey(_icerikAnahtari()),
                      child: _icerik(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _icerikAnahtari() {
    if (_akis.yukleniyor) return 'yukleniyor';
    if (_akis.tamamlandi) return 'ozet';
    final soru = _akis.soru;
    if (soru != null) return 'soru-${soru.id}-${_akis.cevaplandi}';
    return 'durum-${_akis.hataTuru?.name ?? (_akis.bos ? 'bos' : 'diger')}';
  }

  Widget _icerik() {
    if (_akis.yukleniyor) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_akis.toplamSoru == 0 && _akis.hataTuru != null) {
      return _HataDurumu(
        mesaj: _akis.hataMesaji ?? '',
        sinifGerekli: _akis.hataTuru == KelimeHatasi.sinifGerekli,
        onTekrar: _akis.baslat,
        onSinifSec: _sinifSec,
      );
    }
    if (_akis.bos) {
      return _BosDurum(iliski: widget.iliski);
    }
    if (_akis.tamamlandi) {
      return _OzetDurumu(
        iliski: widget.iliski,
        dogru: _akis.dogruSayisi,
        toplam: _akis.toplamSoru,
        xp: _akis.kazanilanXp,
        onYeniden: _akis.baslat,
      );
    }
    return _SoruDurumu(
      iliski: widget.iliski,
      akis: _akis,
      onSec: _sec,
      onSonraki: _sonrakiSoru,
      onKaydet: _kelimeyiKaydet,
      onTekrarDene: _akis.tekrarDene,
      onAtla: _akis.atla,
    );
  }
}

class _UstCubuk extends StatelessWidget {
  const _UstCubuk({required this.iliski, required this.akis});

  final KelimeIliskiTuru iliski;
  final KelimeOyunAkisi akis;

  @override
  Widget build(BuildContext context) {
    final toplam = akis.toplamSoru;
    final double oran = toplam == 0 ? 0.0 : (akis.tamamlananSoru / toplam).clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        IconButton(
          tooltip: 'Kapat',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
        Expanded(
          child: Semantics(
            label: toplam == 0 ? iliski.baslik : 'Soru ${akis.sorudaKacinci} / $toplam',
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: oran),
              duration: motionMs(context, 320),
              curve: Curves.easeOutCubic,
              builder: (context, deger, _) => ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: deger,
                  minHeight: 12,
                  backgroundColor: AppColors.line,
                  color: iliski.renk,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.sunSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${akis.kazanilanXp} XP',
            style: appText(size: 14, weight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _SoruDurumu extends StatelessWidget {
  const _SoruDurumu({
    required this.iliski,
    required this.akis,
    required this.onSec,
    required this.onSonraki,
    required this.onKaydet,
    required this.onTekrarDene,
    required this.onAtla,
  });

  final KelimeIliskiTuru iliski;
  final KelimeOyunAkisi akis;
  final ValueChanged<int> onSec;
  final VoidCallback onSonraki;
  final ValueChanged<String> onKaydet;
  final Future<void> Function() onTekrarDene;
  final VoidCallback onAtla;

  OptionState _durum(int i) {
    final sonuc = akis.sonuc;
    if (sonuc != null) {
      if (i == sonuc.dogruIndeks) return OptionState.correct;
      if (i == akis.secilen) return OptionState.wrong;
      return OptionState.dimmed;
    }
    if (akis.gonderiliyor && akis.secilen == i) return OptionState.pending;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final soru = akis.soru!;
    final sonuc = akis.sonuc;
    final tiklanabilir = !akis.cevaplandi && !akis.gonderiliyor;
    final poz = sonuc == null
        ? (akis.ipucuAcik ? HupoPose.ipucuBuldu : HupoPose.dusunuyor)
        : (sonuc.dogru ? HupoPose.dogru : HupoPose.zorSoruydu);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Hupo(pose: poz, size: 96),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: iliski.renkYumusak,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(iliski.simge, color: iliski.renkMetin, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${iliski.baslik}: ${iliski.hedef}',
                  style: appText(size: 14, weight: FontWeight.w800, color: iliski.renkMetin),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GameCard(
          padding: const EdgeInsets.all(20),
          child: Text(
            soru.soruMetni,
            style: appText(size: 20, weight: FontWeight.w900),
          ),
        ),
        if (akis.ipucuKullanilabilir) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: akis.ipucuGoster,
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: Text('İpucu göster', style: appText(weight: FontWeight.w800, color: AppColors.primary)),
            ),
          ),
        ],
        if (akis.ipucuAcik && soru.ipucu != null) ...[
          const SizedBox(height: 4),
          _Kutu(
            renk: AppColors.sunSoft,
            kenar: AppColors.sun,
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppColors.sunDark),
                const SizedBox(width: 10),
                Expanded(child: Text(soru.ipucu!, style: appText(size: 15, weight: FontWeight.w700))),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < soru.secenekler.length; i++)
          AnswerOption(
            label: _harfler[i],
            text: soru.secenekler[i],
            state: _durum(i),
            onTap: tiklanabilir ? () => onSec(i) : null,
          ),
        if (akis.hataMesaji != null && sonuc == null) ...[
          const SizedBox(height: 12),
          _Kutu(
            renk: AppColors.coralSoft,
            kenar: AppColors.coral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(akis.hataMesaji!, style: appText(size: 15, weight: FontWeight.w700)),
                if (akis.tekrarDenenebilir) ...[
                  const SizedBox(height: 10),
                  ChunkyButton(
                    label: 'Tekrar dene',
                    height: 48,
                    onPressed: () => onTekrarDene(),
                  ),
                ],
                if (akis.hataTuru == KelimeHatasi.soruBulunamadi) ...[
                  const SizedBox(height: 10),
                  ChunkyButton(
                    label: 'Sıradaki soruya geç',
                    height: 48,
                    onPressed: onAtla,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (sonuc != null) ...[
          const SizedBox(height: 14),
          _GeriBildirim(
            sonuc: sonuc,
            alternatifEklendi: akis.alternatifEklendi,
            bilgi: akis.bilgiMesaji,
            onKaydet: () => onKaydet(soru.anlamId),
            sonSoru: akis.sorudaKacinci >= akis.toplamSoru,
            onSonraki: onSonraki,
          ),
        ],
      ],
    );
  }
}

class _GeriBildirim extends StatelessWidget {
  const _GeriBildirim({
    required this.sonuc,
    required this.alternatifEklendi,
    required this.bilgi,
    required this.onKaydet,
    required this.sonSoru,
    required this.onSonraki,
  });

  final KelimeCevapSonucu sonuc;
  final bool alternatifEklendi;
  final String? bilgi;
  final VoidCallback onKaydet;
  final bool sonSoru;
  final VoidCallback onSonraki;

  @override
  Widget build(BuildContext context) {
    final dogru = sonuc.dogru;
    final renk = dogru ? AppColors.mintSoft : AppColors.coralSoft;
    final kenar = dogru ? AppColors.mint : AppColors.coral;
    final koyu = dogru ? AppColors.mintDark : AppColors.coralDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Kutu(
          renk: renk,
          kenar: kenar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  dogru ? 'Harika, doğru bildin!' : 'Bu kez olmadı. Açıklamaya bakalım.',
                  style: appText(size: 18, weight: FontWeight.w900, color: koyu),
                ),
              ),
              const SizedBox(height: 6),
              Text(sonuc.aciklama, style: appText(size: 15)),
              if (sonuc.kazanilanXp > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '+${sonuc.kazanilanXp} XP kazandın',
                  style: appText(size: 14, weight: FontWeight.w900),
                ),
              ],
              if (!dogru && alternatifEklendi) ...[
                const SizedBox(height: 8),
                Text(
                  'Bu kelimeyi başka bir soruyla tekrar deneyeceğiz.',
                  style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
                ),
              ],
              if (bilgi != null) ...[
                const SizedBox(height: 8),
                Text(bilgi!, style: appText(size: 13, color: AppColors.muted)),
              ],
              if (!dogru) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: onKaydet,
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: Text('Bu kelimeyi kaydet', style: appText(weight: FontWeight.w800, color: AppColors.primary)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        ChunkyButton(
          label: sonSoru ? 'Sonucu gör' : 'Devam',
          color: dogru ? AppColors.mint : AppColors.primary,
          shadowColor: dogru ? AppColors.mintDark : AppColors.primaryDark,
          onPressed: onSonraki,
        ),
      ],
    );
  }
}

class _OzetDurumu extends StatelessWidget {
  const _OzetDurumu({
    required this.iliski,
    required this.dogru,
    required this.toplam,
    required this.xp,
    required this.onYeniden,
  });

  final KelimeIliskiTuru iliski;
  final int dogru;
  final int toplam;
  final int xp;
  final VoidCallback onYeniden;

  @override
  Widget build(BuildContext context) {
    // Skora göre poz: yarıdan fazla doğruda kutlama, değilse "konu tamamlandı" pozu
    final kutlama = toplam > 0 && dogru * 2 >= toplam;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Hupo(pose: kutlama ? HupoPose.harika : HupoPose.konuTamamlandi, size: 110),
        ),
        const SizedBox(height: 8),
        Text(
          'Oyun bitti!',
          textAlign: TextAlign.center,
          style: appText(size: 26, weight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          '${iliski.baslik} oturumu tamam.',
          textAlign: TextAlign.center,
          style: appText(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _OzetKarti(baslik: 'Doğru', deger: '$dogru / $toplam', renk: iliski.renkKoyu)),
            const SizedBox(width: 10),
            Expanded(child: _OzetKarti(baslik: 'Kazanılan XP', deger: '+$xp', renk: AppColors.navy)),
          ],
        ),
        const SizedBox(height: 20),
        ChunkyButton(label: 'Yeniden oyna', onPressed: onYeniden),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text('Kelime Evreni\'ne dön', style: appText(weight: FontWeight.w800, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _OzetKarti extends StatelessWidget {
  const _OzetKarti({required this.baslik, required this.deger, required this.renk});

  final String baslik;
  final String deger;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(deger, style: appText(size: 24, weight: FontWeight.w900, color: renk)),
          const SizedBox(height: 2),
          Text(baslik, style: appText(size: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _HataDurumu extends StatelessWidget {
  const _HataDurumu({
    required this.mesaj,
    required this.sinifGerekli,
    required this.onTekrar,
    required this.onSinifSec,
  });

  final String mesaj;
  final bool sinifGerekli;
  final VoidCallback onTekrar;
  final VoidCallback onSinifSec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Hupo(pose: HupoPose.birDahaDene, size: 110),
        const SizedBox(height: 12),
        Text(mesaj, textAlign: TextAlign.center, style: appText(size: 17, weight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (sinifGerekli)
          ChunkyButton(label: 'Sınıfımı seç', onPressed: onSinifSec)
        else
          ChunkyButton(label: 'Tekrar dene', onPressed: onTekrar),
      ],
    );
  }
}

class _BosDurum extends StatelessWidget {
  const _BosDurum({required this.iliski});

  final KelimeIliskiTuru iliski;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Hupo(pose: HupoPose.hazirMisin, size: 110),
        const SizedBox(height: 12),
        Text(
          '${iliski.kisaAciklama} için henüz soru yok.',
          textAlign: TextAlign.center,
          style: appText(size: 17, weight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Yeni sorular hazırlanınca burada olacak. Şimdilik başka bir oyuna geçebilirsin.',
          textAlign: TextAlign.center,
          style: appText(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        ChunkyButton(
          label: 'Geri dön',
          color: iliski.renk,
          shadowColor: iliski.renkKoyu,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _Kutu extends StatelessWidget {
  const _Kutu({required this.renk, required this.kenar, required this.child});

  final Color renk;
  final Color kenar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kenar, width: 1.5),
      ),
      child: child,
    );
  }
}
