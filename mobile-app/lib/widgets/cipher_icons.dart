// Çarpım tablosu şifre ikonları eşleme yardımcısı.

import 'package:flutter/material.dart';

IconData cipherIcon(String? iconName) {
  return switch (iconName?.toLowerCase()) {
    'key' || 'sifre' => Icons.vpn_key_rounded,
    'star' || 'yildiz' => Icons.star_rounded,
    'bolt' || 'simsek' => Icons.bolt_rounded,
    'shield' || 'kalkan' => Icons.shield_rounded,
    'school' || 'okul' => Icons.school_rounded,
    'lightbulb' || 'ampul' => Icons.lightbulb_rounded,
    'rocket' || 'roket' => Icons.rocket_launch_rounded,
    'auto_stories' || 'kitap' => Icons.auto_stories_rounded,
    'psychology' || 'beyin' => Icons.psychology_rounded,
    'calculate' || 'hesap' => Icons.calculate_rounded,
    _ => Icons.lock_open_rounded,
  };
}
