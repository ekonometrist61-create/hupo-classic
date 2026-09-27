import 'package:flutter/material.dart';

/// Tasarım dili: canlı ama tutarlı bir palet. Her ana renk, "kabartma" (3D) etkisi
/// için bir de koyu kenar tonuyla birlikte tanımlıdır.
class AppColors {
  AppColors._();

  // Marka
  static const primary = Color(0xFF6C4DF6); // menekşe
  static const primaryDark = Color(0xFF4B32C3);
  static const primaryLight = Color(0xFF9B83FF);
  static const primarySoft = Color(0xFFEDE9FF);

  // XP, ödül, vurgu
  static const sun = Color(0xFFFFC533);
  static const sunDark = Color(0xFFE0A100);
  static const sunSoft = Color(0xFFFFF4D1);

  // Doğru / başarı
  static const mint = Color(0xFF22C58B);
  static const mintDark = Color(0xFF139A69);
  static const mintSoft = Color(0xFFE2FAF1);

  // Yanlış / uyarı
  static const coral = Color(0xFFFF5470);
  static const coralDark = Color(0xFFD93552);
  static const coralSoft = Color(0xFFFFE8EC);

  // Bilgi
  static const sky = Color(0xFF2FB8FF);
  static const skyDark = Color(0xFF1A8FD1);

  // Nötr
  static const background = Color(0xFFF6F4FF);
  static const surface = Colors.white;
  static const ink = Color(0xFF1F1B3A);
  static const muted = Color(0xFF6E6A8C);
  static const line = Color(0xFFE3DFF7);
  static const lineDark = Color(0xFFCFC9EE);
}

/// Uygulama genelinde tek yazı tipi (Nunito) ve hazır stiller.
TextStyle appText({
  double size = 16,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.ink,
  double? height,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

const appGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
  stops: [0.0, 0.55, 1.0],
);

ThemeData buildAppTheme({String fontFamily = 'Nunito'}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.sun,
    onSecondary: AppColors.ink,
    tertiary: AppColors.mint,
    error: AppColors.coral,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.line,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkRipple.splashFactory,
  );

  OutlineInputBorder border(Color color, [double width = 2]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: border(AppColors.line),
      enabledBorder: border(AppColors.line),
      focusedBorder: border(AppColors.primary, 2.5),
      errorBorder: border(AppColors.coral),
      focusedErrorBorder: border(AppColors.coral, 2.5),
      labelStyle: appText(color: AppColors.muted, weight: FontWeight.w600),
      floatingLabelStyle: appText(color: AppColors.primary, weight: FontWeight.w700),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: appText(color: Colors.white, size: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primarySoft,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: appText(size: 16, weight: FontWeight.w800, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: appText(size: 15, weight: FontWeight.w700, color: AppColors.primary),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.ink),
    ),
  );
}
