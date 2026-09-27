import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Derse göre ikon ve renk (bilinmeyen dersler için varsayılan).
({IconData icon, Color color}) subjectStyle(String ders) {
  final d = ders.toLowerCase();
  if (d.contains('mat')) return (icon: Icons.calculate_rounded, color: AppColors.sky);
  if (d.contains('türk') || d.contains('turk') || d.contains('edeb')) {
    return (icon: Icons.menu_book_rounded, color: AppColors.coral);
  }
  if (d.contains('fen') || d.contains('bilim')) {
    return (icon: Icons.science_rounded, color: AppColors.mint);
  }
  if (d.contains('sosyal') || d.contains('tarih') || d.contains('coğ')) {
    return (icon: Icons.public_rounded, color: AppColors.sunDark);
  }
  if (d.contains('ingiliz') || d.contains('yabancı')) {
    return (icon: Icons.translate_rounded, color: AppColors.primary);
  }
  return (icon: Icons.school_rounded, color: AppColors.primary);
}
