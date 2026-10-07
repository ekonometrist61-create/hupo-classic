// W8: Arkadaşa Meydan Oku
// Çocuk güvenliği: sohbet yok, isim yok, kod ile katılım.
// Rakip adı "Rakibin" olarak gösterilir, asla gerçek isim değil.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_models.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';

const String _baslik = 'Arkadaşına Meydan Oku';

// =====================================================================
// ChallengeHubScreen: Oluştur veya Katıl
// =====================================================================
class ChallengeHubScreen extends ConsumerStatefulWidget {
  const ChallengeHubScreen({super.key});

  @override
  ConsumerState<ChallengeHubScreen> createState() => _ChallengeHubScreenState();
}

class _ChallengeHubScreenState extends ConsumerState<ChallengeHubScreen> {
  final _kodController = TextEditingController();
  bool _yukleniyor = false;

  @override
  void dispose() {
    _kodController.dispose();
    super.dispose();
  }

  Future<void> _olustur() async {
    setState(() => _yukleniyor = true);
    try {
      final session = await ref.read(quizRepositoryProvider).createChallenge();
      if (mounted) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChallengeWaitScreen(session: session),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meydan okuma oluşturulamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _katil() async {
    final kod = _kodController.text.trim();
    if (kod.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir kod gir.')),
      );
      return;
    }
    setState(() => _yukleniyor = true);
    try {
      final session = await ref.read(quizRepositoryProvider).joinChallenge(kod);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ChallengeSessionScreen(session: session),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Katılınamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Ust(),
            ResponsivePage(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nasıl çalışır?',
                    style: appText(weight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. "Meydan Oku" butonuna bas, bir kod al.\n'
                    '2. Kodu arkadaşına mesajla gönder.\n'
                    '3. Arkadaşın kodu girince sınav başlar.\n'
                    '4. 10 soru, 5 dakika — kim daha çok doğru yapar?',
                    style: appText(size: 14, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: _yukleniyor
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton.icon(
                            onPressed: _olustur,
                            icon: const Icon(Icons.bolt_rounded),
                            label: const Text('Yeni Meydan Okuma Oluştur'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  const _Ayrac(metin: 'veya arkadaşının kodunu gir'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _kodController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Kod (6 harf)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _katil(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _yukleniyor ? null : _katil,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'Katıl',
                        style: appText(weight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ChallengeWaitScreen: kod göster, rakip bekle + başla
// =====================================================================
class ChallengeWaitScreen extends ConsumerStatefulWidget {
  const ChallengeWaitScreen({super.key, required this.session});

  final ChallengeSession session;

  @override
  ConsumerState<ChallengeWaitScreen> createState() => _ChallengeWaitScreenState();
}

class _ChallengeWaitScreenState extends ConsumerState<ChallengeWaitScreen> {
  // Rakibin katılması için Realtime yerine basit polling (30 sn)
  Timer? _pollTimer;
  int _bekleme = 0;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _bekleme += 3;
      if (_bekleme > 300) {
        _pollTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zaman aşımı. Arkadaşın katılmadı.')),
          );
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _basla() {
    _pollTimer?.cancel();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ChallengeSessionScreen(session: widget.session),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsivePage(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
          child: Column(
            children: [
              Text('Kodunu Paylaş', style: appText(size: 22, weight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                'Arkadaşın bu kodu girince sınav başlayacak.',
                style: appText(size: 14, color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GameCard(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      widget.session.kod,
                      style: appText(
                        size: 48,
                        weight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.session.kod));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kod kopyalandı.')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Kopyala'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Arkadaşın katılması bekleniyor…',
                style: appText(size: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 32),
              Text(
                'Arkadaşın hazır olduğunda başla:',
                style: appText(size: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _basla,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Başla!',
                    style: appText(weight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ChallengeSessionScreen: soruları çöz
// =====================================================================
class ChallengeSessionScreen extends ConsumerStatefulWidget {
  const ChallengeSessionScreen({super.key, required this.session});

  final ChallengeSession session;

  @override
  ConsumerState<ChallengeSessionScreen> createState() => _ChallengeSessionScreenState();
}

class _ChallengeSessionScreenState extends ConsumerState<ChallengeSessionScreen> {
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
    if (!_cevaplar.containsKey(_soru.id)) _cevaplar[_soru.id] = null;
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

    for (final s in widget.session.sorular) {
      if (!_cevaplar.containsKey(s.id)) _cevaplar[s.id] = null;
    }

    final cevapList = [
      for (final e in _cevaplar.entries)
        {'question_id': e.key, 'secilen_sik': e.value},
    ];

    try {
      final benimSkor = await ref
          .read(quizRepositoryProvider)
          .submitChallenge(widget.session.id, cevapList);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ChallengeResultScreen(
            meydanId: widget.session.id,
            benimSkor: benimSkor,
            repo: ref.read(quizRepositoryProvider),
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _gonderiliyor = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderilemedi: $e')),
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
                Text('Soru bulunamadı.', style: appText(color: AppColors.muted)),
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
    final sureRenk = _kalanSaniye < 60 ? AppColors.coral : AppColors.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final cik = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Çık?'),
            content: const Text('Cevapların kaydedilmeyecek. Emin misin?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çık')),
            ],
          ),
        );
        if (cik == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.navyDeep,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Soru ${_index + 1} / ${sorular.length}',
                        style: appText(weight: FontWeight.w900, color: Colors.white),
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
                        '$dk:${sn.toString().padLeft(2, '0')}',
                        style: appText(size: 18, weight: FontWeight.w900, color: sureRenk),
                      ),
                    ),
                  ],
                ),
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
                      Text(soru.text, style: appText(weight: FontWeight.w700, height: 1.5)),
                      const SizedBox(height: 20),
                      for (final e in soru.options.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SikButon(
                            kod: e.key,
                            metin: e.value,
                            secili: secili == e.key,
                            onTap: () => _sec(e.key),
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
                                  _sonSoru ? 'Bitir' : 'Sonraki',
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

// =====================================================================
// ChallengeResultScreen: sonuç — rakip adı gösterilmez
// =====================================================================
class ChallengeResultScreen extends StatefulWidget {
  const ChallengeResultScreen({
    super.key,
    required this.meydanId,
    required this.benimSkor,
    required this.repo,
  });

  final String meydanId;
  final ChallengeScore benimSkor;
  final dynamic repo; // QuizRepository — circular import önlemek için dynamic

  @override
  State<ChallengeResultScreen> createState() => _ChallengeResultScreenState();
}

class _ChallengeResultScreenState extends State<ChallengeResultScreen> {
  ChallengeResult? _sonuc;
  Timer? _pollTimer;
  int _deneme = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
    // Rakip henüz bitmemişse 3 sn arayla poll et (max 10 kez)
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      _deneme++;
      if (_deneme > 10) {
        _pollTimer?.cancel();
        return;
      }
      await _yukle();
      if (_sonuc != null && _sonuc!.rakipBitti) _pollTimer?.cancel();
    });
  }

  Future<void> _yukle() async {
    try {
      final r = await widget.repo.getChallengeResult(widget.meydanId);
      if (mounted) setState(() => _sonuc = r);
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ben = widget.benimSkor;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          children: [
            Text(_baslik, style: appText(size: 22, weight: FontWeight.w900)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _SkorKarti(baslik: 'Sen', skor: ben, renk: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: _sonuc?.rakip != null
                      ? _SkorKarti(
                          baslik: 'Rakibin',
                          skor: _sonuc!.rakip!,
                          renk: AppColors.coral,
                        )
                      : GameCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text('Rakibin bekleniyor…', style: appText(size: 12, color: AppColors.muted), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            if (_sonuc != null && _sonuc!.rakip != null) ...[
              const SizedBox(height: 20),
              _SonucBanner(kazandim: _sonuc!.kazandim),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Ana Sayfaya Dön', style: appText(weight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkorKarti extends StatelessWidget {
  const _SkorKarti({required this.baslik, required this.skor, required this.renk});

  final String baslik;
  final ChallengeScore skor;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(baslik, style: appText(size: 13, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            skor.puan.toStringAsFixed(skor.puan % 1 == 0 ? 0 : 1),
            style: appText(size: 36, weight: FontWeight.w900, color: renk),
          ),
          Text('puan', style: appText(size: 12, color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(
            '${skor.dogru} doğru · ${skor.yanlis} yanlış',
            style: appText(size: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SonucBanner extends StatelessWidget {
  const _SonucBanner({required this.kazandim});

  final bool? kazandim;

  @override
  Widget build(BuildContext context) {
    final mesaj = kazandim == null
        ? '🤝 Beraberlik!'
        : kazandim!
            ? '🏆 Kazandın!'
            : '💪 Bir dahaki sefere!';
    final renk = kazandim == null
        ? AppColors.muted
        : kazandim!
            ? AppColors.mintDark
            : AppColors.coralDark;
    return Center(
      child: Text(mesaj, style: appText(size: 22, weight: FontWeight.w900, color: renk)),
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
            Expanded(child: Text(metin, style: appText(size: 15))),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// Yardımcılar
// =====================================================================
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
            Text(_baslik, style: appText(size: 20, weight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _Ayrac extends StatelessWidget {
  const _Ayrac({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(metin, style: appText(size: 12, color: AppColors.muted)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
