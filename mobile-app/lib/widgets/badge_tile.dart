import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'badge_icons.dart';
import 'ui/chunky_button.dart';

/// Rozet görseli: kazanıldıysa renkli, kilitliyse gri ve üzerinde kilit simgesi.
class BadgeMedal extends StatelessWidget {
  const BadgeMedal({super.key, required this.badge, this.size = 64});

  final BadgeInfo badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    final lockSize = size * 0.34;

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: earned
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD75E), Color(0xFFFF9F1C)],
                    )
                  : null,
              color: earned ? null : AppColors.line,
              boxShadow: [
                BoxShadow(
                  color: earned ? const Color(0xFFE08600) : AppColors.lineDark,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              badgeIcon(badge.icon),
              size: size * 0.5,
              color: earned ? Colors.white : AppColors.lineDark,
            ),
          ),
          if (!earned)
            Positioned(
              right: 0,
              bottom: 2,
              child: Container(
                width: lockSize + 10,
                height: lockSize + 10,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Icon(Icons.lock_rounded, size: lockSize, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, required this.onTap});

  final BadgeInfo badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: badge.earned
          ? '${badge.name}, kazanıldı'
          : '${badge.name}, kilitli. Şartı görmek için dokun.',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeMedal(badge: badge),
              const SizedBox(height: 8),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appText(
                  size: 12,
                  weight: FontWeight.w800,
                  color: badge.earned ? AppColors.ink : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rozete dokunulunca açılan popup: kilitliyse kazanma şartı ve ilerleme,
/// kazanıldıysa kazanma tarihi gösterilir.
Future<void> showBadgeDialog(BuildContext context, BadgeInfo badge) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BadgeMedal(badge: badge, size: 96),
              const SizedBox(height: 16),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: appText(size: 24, weight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              _StatusChip(badge: badge),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kazanma şartı',
                  style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  badge.description,
                  style: appText(size: 17, weight: FontWeight.w700, height: 1.35),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                badge.encouragement,
                textAlign: TextAlign.center,
                style: appText(size: 15, weight: FontWeight.w800, color: AppColors.primary),
              ),
              if (!badge.earned) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: badge.progressFraction,
                    minHeight: 12,
                    backgroundColor: AppColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    badge.progressLabel,
                    style: appText(size: 12, weight: FontWeight.w700, color: AppColors.muted),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ChunkyButton(label: 'Tamam', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.badge});

  final BadgeInfo badge;

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    final date = badge.earnedAt;
    final label = earned
        ? (date == null ? 'Kazanıldı' : 'Kazanıldı • ${formatDate(date)}')
        : 'Kilitli';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: earned ? AppColors.mintSoft : AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 17,
            color: earned ? AppColors.mintDark : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: appText(
              size: 13,
              weight: FontWeight.w800,
              color: earned ? AppColors.mintDark : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
