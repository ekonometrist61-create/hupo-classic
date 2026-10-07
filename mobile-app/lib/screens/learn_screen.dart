// Öğren sekmesi: dersler ve çalışma araçları (tekrar, kaydedilenler, çarpım şifreleri).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import 'cipher/cipher_list_screen.dart';
import 'home_screen.dart';
import 'review_screen.dart';
import 'saved_questions_screen.dart';

const String _baslik = 'Öğren';
const String _altBaslik = 'Bir ders seç, kısa bir çalışma yap.';
const String _derslerBasligi = 'Dersler';
const String _araclarBasligi = 'Çalışma araçların';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quizRepositoryProvider);
    final bekleyen = ref.watch(dueCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsivePage(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_baslik, style: appText(size: 30, weight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(_altBaslik, style: appText(color: AppColors.muted)),
                const SizedBox(height: 24),
                Text(_derslerBasligi, style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 12),
                SubjectList(
                  onSelect: (ders) => HomeScreen.openQuiz(
                    context,
                    ref,
                    title: ders,
                    load: () => repo.fetchQuizQuestions(ders),
                    emptyMessage:
                        'Bu derse yakında yeni sorular gelecek. Şimdilik başka bir ders seçebilirsin!',
                  ),
                ),
                const SizedBox(height: 24),
                Text(_araclarBasligi, style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 12),
                _AracKarti(
                  simge: Icons.refresh_rounded,
                  renk: AppColors.coral,
                  baslik: 'Yanlışlarım ve tekrar',
                  aciklama: bekleyen > 0
                      ? '$bekleyen soru seni bekliyor.'
                      : 'Tekrar edilecek soru yok, harika!',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _AracKarti(
                  simge: Icons.bookmark_rounded,
                  renk: AppColors.sky,
                  baslik: 'Kaydettiğim sorular',
                  aciklama: 'Sonra bakmak için sakladıkların.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SavedQuestionsScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _AracKarti(
                  simge: Icons.vpn_key_rounded,
                  renk: AppColors.primary,
                  baslik: 'Çarpım tablosu şifreleri',
                  aciklama: 'Şifreleri çöz, çarpım tablosunu ustaca öğren.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CipherListScreen()),
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

class _AracKarti extends StatelessWidget {
  const _AracKarti({
    required this.simge,
    required this.renk,
    required this.baslik,
    required this.aciklama,
    required this.onTap,
  });

  final IconData simge;
  final Color renk;
  final String baslik;
  final String aciklama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
            child: Icon(simge, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: appText(weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(aciklama, style: appText(size: 13, color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
