import 'package:flutter/material.dart';

/// Veritabanındaki rozet ikon anahtarını Material ikonuna çevirir.
/// Bilinmeyen anahtar için yıldız gösterilir.
IconData badgeIcon(String key) => switch (key) {
      'flag' => Icons.flag,
      'menu_book' => Icons.menu_book,
      'track_changes' => Icons.track_changes,
      'local_fire_department' => Icons.local_fire_department,
      'whatshot' => Icons.whatshot,
      'bolt' => Icons.bolt,
      'star' => Icons.star,
      'military_tech' => Icons.military_tech,
      'calculate' => Icons.calculate,
      'translate' => Icons.translate,
      'science' => Icons.science,
      'emoji_events' => Icons.emoji_events,
      'shield' => Icons.shield_rounded,
      'diamond' => Icons.diamond_rounded,
      'notifications' => Icons.notifications_rounded,
      _ => Icons.star,
    };
