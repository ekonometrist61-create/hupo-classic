import 'package:flutter/services.dart';

/// Titreşim geri bildirimi; Ayarlar'dan kapatılabilir.
class AppHaptics {
  AppHaptics._();

  static bool enabled = true;

  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void success() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void error() {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void celebration() {
    if (enabled) HapticFeedback.heavyImpact();
  }
}
