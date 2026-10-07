// Bir dersin konu kırılımı: her konu için ilerleme ve o konudan çalışma başlatma.
// Yeterli veri yoksa (6'dan az soru) oran gösterilmez; veli panelindeki kuralla aynı.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import '../widgets/ui/subject_style.dart';
import 'home_screen.dart';

const String _karisikCalis = 'Karışık çalış (tüm konular)';
const String _konularBasligi = 'Konular';
const String _yetersizVeri = 'Yetersiz veri';
const String _konuYuklenemedi = 'Konular yüklenemedi, tekrar deneyelim.';
const String _bosKonuMesaji = 'Bu konuda yeni sorular geliyor.';

class SubjectTopicsScreen extends ConsumerWidget {
  const SubjectTopicsScreen({super.key, required this.ders});

  final String ders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(quizRepositoryProvider);
    final topics = ref.watch(topicProgressProvider(ders));
    final style = subjectStyle(ders);

    Future<void> baslat({String? konu, required String baslik}) =>
        HomeScreen.openQuiz(
          context,
          ref,
          title: baslik,
          load: () => repo.fetchQuizQuestions(ders, konu: konu),
          emptyMessage: _bosKonuMesaji,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(ders, style: appText(size: 20, weight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameCard(
                  color: style.color.withValues(alpha: 0.12),
                  borderColor: style.color,
                  onTap: () => baslat(baslik: ders),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
                        child: Icon(style.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(_karisikCalis, style: appText(weight: FontWeight.w800)),
                      ),
                      const Icon(Icons.play_arrow_rounded, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(_konularBasligi, style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 12),
                topics.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Hupo(mood: HupoMood.retry, size: 72),
                        const SizedBox(height: 8),
                        Text(_konuYuklenemedi, style: appText(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const Hupo(mood: HupoMood.empty, size: 90),
                            const SizedBox(height: 8),
                            Text(
                              'Bu derste henüz konu özeti yok; "$_karisikCalis" ile başlayabilirsin.',
                              textAlign: TextAlign.center,
                              style: appText(color: AppColors.muted),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final t in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TopicRow(
                              topic: t,
                              color: style.color,
                              onTap: () => baslat(konu: t.konu, baslik: '$ders • ${t.konu}'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.color, required this.onTap});

  final TopicProgress topic;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.konu, style: appText(weight: FontWeight.w800)),
                const SizedBox(height: 4),
                if (topic.yeterliVeri)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (topic.oran ?? 0) / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                else
                  Text(
                    '$_yetersizVeri (en az ${TopicProgress.yeterliEsik} soru)',
                    style: appText(size: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (topic.yeterliVeri)
            Text(
              '%${topic.oran}',
              style: appText(weight: FontWeight.w900, color: color),
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
