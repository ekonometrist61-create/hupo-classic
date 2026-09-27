import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_theme.dart';

/// Ana ekran başlığındaki zil: okunmamış bildirim sayısını gösterir, bildirim ekranını açar.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return IconButton(
      tooltip: unread > 0 ? '$unread yeni bildirim' : 'Bildirimler',
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        ref.invalidate(unreadCountProvider);
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_rounded, color: Colors.white, size: 30),
          if (unread > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  shape: unread > 9 ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: unread > 9 ? BorderRadius.circular(10) : null,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: appText(size: 11, weight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
