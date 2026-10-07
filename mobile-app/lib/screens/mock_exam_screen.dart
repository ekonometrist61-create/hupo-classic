// Deneme sınavı listesi ve akışı.
// Öğrenci sınava başlar, soruları sırayla cevaplar, süre bitince otomatik gönderir.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mock_exam_models.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import 'home_screen.dart' show InlineRetry;

const String _baslik = 'Deneme Sınavları';
const String _yuklenemedi = 'Sınavlar yüklenemedi, tekrar deneyelim.';
const String _bosListesi = 'Şu an için sınav tanımlanmamış.';

class MockExamsListScreen extends ConsumerWidget {
  const MockExamsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sinavlar = ref.watch(myExamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myExamsProvider),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _Ust(),
              ResponsivePage(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: sinavlar.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => InlineRetry(
                    text: _yuklenemedi,
                    onRetry: () => ref.invalidate(myExamsProvider),
                  ),
                  data: (list) => list.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text(_bosListesi)),
                        )
                      : Column(
                          children: [
                            for (final s in list)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _SinavKarti(
                                  sinav: s,
                                  onBasla: () => _basla(context, ref, s),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _basla(BuildContext context, WidgetRef ref, MockExamSummary sinav) async {
    if (sinav.bitti) return;
    if (sinav.sureDoldu) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sınavın süresi dolmuş.')),
        );
      }
      return;
    }
    try {
      final session = await ref.read(quizRepositoryProvider).startMockExam(sinav.id);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MockExamSessionScreen(session: session),
          ),
        ).then((_) => ref.invalidate(myExamsProvider));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sınav başlatılamadı: $e')),
        );
      }
    }
  }
}

class _Ust extends StatelessWidget {
  const _Ust();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navySoft, AppColors.navyDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
            ),
            Text(_baslik, style: appText(size: 22, weight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _SinavKarti extends StatelessWidget {
  const _SinavKarti({required this.sinav, required this.onBasla});

  final MockExamSummary sinav;
  final VoidCallback onBasla;

  @override
  Widget build(BuildContext context) {
    final bitti = sinav.bitti;
    final sureDoldu = sinav.sureDoldu;

    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(sinav.ad, style: appText(weight: FontWeight.w900)),
              ),
              if (bitti)
                const _Rozet(label: 'Tamamlandı', renk: AppColors.mint)
              else if (sureDoldu)
                const _Rozet(label: 'Süresi Doldu', renk: AppColors.muted)
              else if (sinav.basladi)
                const _Rozet(label: 'Devam', renk: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Başlangıç: ${formatDate(sinav.baslangicZamani)} · ${sinav.sureDakika} dk',
            style: appText(size: 12, color: AppColors.muted),
          ),
          if (bitti) ...[
            const SizedBox(height: 10),
            _SonucSatiri(
              dogru: sinav.dogruSayisi,
              yanlis: sinav.yanlisSayisi,
              bos: sinav.bosSayisi,
              puan: sinav.puan,
            ),
          ] else if (!sureDoldu) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onBasla,
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(
                  sinav.basladi ? 'Devam et' : 'Sınava Gir',
                  style: appText(weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SonucSatiri extends StatelessWidget {
  const _SonucSatiri({required this.dogru, required this.yanlis, required this.bos, required this.puan});

  final int dogru;
  final int yanlis;
  final int bos;
  final double puan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Sayac(deger: dogru.toString(), etiket: 'Doğru', renk: AppColors.mint),
        const SizedBox(width: 8),
        _Sayac(deger: yanlis.toString(), etiket: 'Yanlış', renk: AppColors.coral),
        const SizedBox(width: 8),
        _Sayac(deger: bos.toString(), etiket: 'Boş', renk: AppColors.muted),
        const Spacer(),
        Text(
          '${puan.toStringAsFixed(puan % 1 == 0 ? 0 : 1)} pt',
          style: appText(size: 18, weight: FontWeight.w900, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _Sayac extends StatelessWidget {
  const _Sayac({required this.deger, required this.etiket, required this.renk});

  final String deger;
  final String etiket;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$deger $etiket',
        style: appText(size: 13, weight: FontWeight.w800, color: renk),
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  const _Rozet({required this.label, required this.renk});

  final String label;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: appText(size: 11, weight: FontWeight.w800, color: renk)),
    );
  }
}

// =====================================================================
// MockExamSessionScreen: aktif sınav akışı
// =====================================================================
class MockExamSessionScreen extends ConsumerStatefulWidget {
  const MockExamSessionScreen({super.key, required this.session});

  final MockExamSession session;

  @override
  ConsumerState<MockExamSessionScreen> createState() => _MockExamSessionScreenState();
}

class _MockExamSessionScreenState extends ConsumerState<MockExamSessionScreen> {
  int _index = 0;
  final Map<String, String?> _cevaplar = {};
  bool _gonderiliyor = false;
  Timer? _timer;
  late int _kalanSaniye;

  @override
  void initState() {
    super.initState();
    _kalanSaniye = widget.session.kalanSaniye;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_kalanSaniye <= 0) {
        _timer?.cancel();
        _gonder();
      } else {
        if (mounted) setState(() => _kalanSaniye--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Question get _soru => widget.session.sorular[_index];
  bool get _sonSoru => _index >= widget.session.sorular.length - 1;

  void _sec(String sik) => setState(() => _cevaplar[_soru.id] = sik);

  void _ileri() {
    if (!_cevaplar.containsKey(_soru.id)) {
      _cevaplar[_soru.id] = null; // boş işaret
    }
    if (_sonSoru) {
      _gonder();
    } else {
      setState(() => _index++);
    }
  }

  Future<void> _gonder() async {
    if (_gonderiliyor) return;
    _timer?.cancel();
    setState(() => _gonderiliyor = true);

    // Tüm cevapsız soruları boş işaretle
    for (final s in widget.session.sorular) {
      if (!_cevaplar.containsKey(s.id)) _cevaplar[s.id] = null;
    }

    final cevapList = [
      for (final e in _cevaplar.entries)
        {'question_id': e.key, 'secilen_sik': e.value},
    ];

    try {
      final sonuc = await ref
          .read(quizRepositoryProvider)
          .submitMockExam(widget.session.denemelId, cevapList);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MockExamResultScreen(
              sinav: widget.session.ad,
              sonuc: sonuc,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _gonderiliyor = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sınav gönderilemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorular = widget.session.sorular;
    if (sorular.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Bu sınav için soru eklenmemiş.', style: appText(color: AppColors.muted)),
                const SizedBox(height: 16),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Geri')),
              ],
            ),
          ),
        ),
      );
    }

    final soru = sorular[_index];
    final secili = _cevaplar[soru.id];
    final dk = _kalanSaniye ~/ 60;
    final sn = _kalanSaniye % 60;
    final sureRenk = _kalanSaniye < 120 ? AppColors.coral : AppColors.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ciksin = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Sınavdan çık?'),
            content: const Text('Cevapların kaydedilmeyecek. Emin misin?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çık')),
            ],
          ),
        );
        if (ciksin == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: SafeArea(
          child: Column(
            children: [
              _SinavUstBar(
                ad: widget.session.ad,
                index: _index,
                toplam: sorular.length,
                dakika: dk,
                saniye: sn,
                sureRenk: sureRenk,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    children: [
                      Text(
                        soru.text,
                        style: appText(weight: FontWeight.w700, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      for (final entry in soru.options.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SikButon(
                            kod: entry.key,
                            metin: entry.value,
                            secili: secili == entry.key,
                            onTap: () => _sec(entry.key),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _gonderiliyor
                            ? const Center(child: CircularProgressIndicator())
                            : FilledButton(
                                onPressed: _ileri,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  _sonSoru ? 'Bitir ve Gönder' : 'Sonraki Soru',
                                  style: appText(weight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SinavUstBar extends StatelessWidget {
  const _SinavUstBar({
    required this.ad,
    required this.index,
    required this.toplam,
    required this.dakika,
    required this.saniye,
    required this.sureRenk,
  });

  final String ad;
  final int index;
  final int toplam;
  final int dakika;
  final int saniye;
  final Color sureRenk;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad, style: appText(size: 13, color: Colors.white70)),
                Text(
                  'Soru ${index + 1} / $toplam',
                  style: appText(weight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sureRenk.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sureRenk.withValues(alpha: 0.6)),
            ),
            child: Text(
              '$dakika:${saniye.toString().padLeft(2, '0')}',
              style: appText(
                size: 18,
                weight: FontWeight.w900,
                color: sureRenk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SikButon extends StatelessWidget {
  const _SikButon({required this.kod, required this.metin, required this.secili, required this.onTap});

  final String kod;
  final String metin;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: secili ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: secili ? AppColors.primary : AppColors.line,
            width: secili ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: secili ? AppColors.primary : AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  kod,
                  style: appText(
                    size: 14,
                    weight: FontWeight.w900,
                    color: secili ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(metin, style: appText(size: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// MockExamResultScreen: sınav sonucu
// =====================================================================
class MockExamResultScreen extends StatelessWidget {
  const MockExamResultScreen({super.key, required this.sinav, required this.sonuc});

  final String sinav;
  final MockExamResult sonuc;

  @override
  Widget build(BuildContext context) {
    final oran = sonuc.basariOrani;
    final mesaj = oran >= 0.8
        ? 'Muhteşem bir sonuç!'
        : oran >= 0.5
            ? 'İyi gidiyorsun!'
            : 'Her sınav bir adımdır, devam et!';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          children: [
            Text(sinav, style: appText(size: 22, weight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(mesaj, style: appText(weight: FontWeight.w700, color: AppColors.mintDark)),
            const SizedBox(height: 28),
            GameCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    sonuc.puan.toStringAsFixed(sonuc.puan % 1 == 0 ? 0 : 1),
                    style: appText(size: 56, weight: FontWeight.w900, color: AppColors.primary),
                  ),
                  Text('puan', style: appText(color: AppColors.muted)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SonucHucre(deger: sonuc.dogruSayisi.toString(), etiket: 'Doğru', renk: AppColors.mint),
                      _SonucHucre(deger: sonuc.yanlisSayisi.toString(), etiket: 'Yanlış', renk: AppColors.coral),
                      _SonucHucre(deger: sonuc.bosSayisi.toString(), etiket: 'Boş', renk: AppColors.muted),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Ana Sayfaya Dön',
                  style: appText(weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SonucHucre extends StatelessWidget {
  const _SonucHucre({required this.deger, required this.etiket, required this.renk});

  final String deger;
  final String etiket;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(deger, style: appText(size: 28, weight: FontWeight.w900, color: renk)),
        Text(etiket, style: appText(size: 13, color: AppColors.muted)),
      ],
    );
  }
}
