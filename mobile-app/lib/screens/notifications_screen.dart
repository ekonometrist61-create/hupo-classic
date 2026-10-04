import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/league_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/badge_icons.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/hupo/hupo_loading.dart';
import '../widgets/shield_earned_banner.dart';

/// Uygulama içi bildirim merkezi. Açılınca bildirimler okundu işaretlenir;
/// bu oturumda yeni olanlar vurgulu kalır.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  Future<void> _markRead() async {
    try {
      final list = await ref.read(notificationsProvider.future);
      if (list.any((n) => !n.read)) {
        await ref.read(quizRepositoryProvider).markAllNotificationsRead();
        ref.invalidate(unreadCountProvider);
      }
    } catch (_) {
      // Okundu işaretlenemezse bildirimler yine görüntülenir.
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      body: Column(
        children: [
          HeroHeader(
            padding: const EdgeInsets.fromLTRB(12, 4, 20, 22),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                ),
                Text(
                  'Bildirimler',
                  style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.when(
              loading: () => const HupoLoading(message: 'Hupo haberleri getiriyor…'),
              error: (_, __) => _Empty(
                mood: HupoMood.error,
                text: 'Bildirimlerin yüklenemedi, tekrar deneyelim.',
                action: ChunkyButton(
                  label: 'Tekrar dene',
                  expanded: false,
                  height: 48,
                  onPressed: () => ref.invalidate(notificationsProvider),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const _Empty(
                    mood: HupoMood.empty,
                    text: 'Şimdilik yeni bir şey yok. Soru çözdükçe burada güzel haberler olacak!',
                  );
                }
                final now = DateTime.now();
                // Yeni bir 'seri kalkanı kazandın' bildirimi varsa Hupo ile kutlanır.
                final shieldNew = list.any((n) => n.icon == 'shield' && !n.read && n.title.contains('kazandın'));
                final offset = shieldNew ? 1 : 0;
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length + offset,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => i < offset
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: ShieldEarnedBanner(compact: true),
                        )
                      : _Tile(notification: list[i - offset], now: now),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

({Color color, Color soft}) _typeColors(String type) => switch (type) {
      'rozet' => (color: AppColors.sun, soft: AppColors.sunSoft),
      'seviye' => (color: AppColors.primary, soft: AppColors.primarySoft),
      'lig' => (color: AppColors.mint, soft: AppColors.mintSoft),
      _ => (color: AppColors.sky, soft: AppColors.background),
    };

class _Tile extends StatelessWidget {
  const _Tile({required this.notification, required this.now});

  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final colors = _typeColors(n.type);
    final unread = !n.read;

    return Semantics(
      label: '${unread ? 'Yeni. ' : ''}${n.title}. ${n.message}',
      child: GameCard(
        color: unread ? colors.soft : AppColors.surface,
        borderColor: unread ? colors.color : AppColors.line,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: colors.color, shape: BoxShape.circle),
              child: Icon(badgeIcon(n.icon), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title, style: appText(weight: FontWeight.w900)),
                      ),
                      if (unread)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.message,
                    style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    relativeTime(n.createdAt, now),
                    style: appText(size: 12, weight: FontWeight.w800, color: AppColors.muted),
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

class _Empty extends StatelessWidget {
  const _Empty({required this.mood, required this.text, this.action});

  final HupoMood mood;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hupo(mood: mood, size: 130),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: appText(size: 17, weight: FontWeight.w700, height: 1.35),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
