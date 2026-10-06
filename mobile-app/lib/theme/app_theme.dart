import 'package:flutter/material.dart';

/// Tasarım dili: Hupolingo kurumsal kimliği (web ile aynı palet). Her ana renk,
/// "kabartma" (3D) etkisi için bir de koyu kenar tonuyla birlikte tanımlıdır.
/// Altın sarısı yalnızca Hupo, XP ve ödül içindir; ana eylem rengi Learning Teal'dir.
class AppColors {
  AppColors._();

  // Marka: Learning Teal
  static const primary = Color(0xFF147D8A);
  static const primaryDark = Color(0xFF0D5762);
  static const primaryLight = Color(0xFF4FB3BF);
  static const primarySoft = Color(0xFFE8F5F7);

  // XP, ödül, vurgu: Hupo Gold
  static const sun = Color(0xFFF5C842);
  static const sunDark = Color(0xFFD9A91E);
  static const sunSoft = Color(0xFFFEF3CC);

  // Doğru / başarı
  static const mint = Color(0xFF2E9E62);
  static const mintDark = Color(0xFF237A4B);
  static const mintSoft = Color(0xFFE4F5EA);

  // Yanlış / tekrar / uyarı: yargılamayan sıcak amber (kırmızı X yok)
  static const coral = Color(0xFFD96A28);
  static const coralDark = Color(0xFFA64B24);
  static const coralSoft = Color(0xFFFFF0E0);

  // Bilgi: Hupo'nun göz mavisi
  static const sky = Color(0xFF4EA9D9);
  static const skyDark = Color(0xFF2B86B5);

  // Nötr: sıcak krem zemin, lacivert metin
  static const background = Color(0xFFFFF9ED);
  static const surface = Colors.white;
  static const ink = Color(0xFF17324D);
  static const muted = Color(0xFF4A6A85);
  static const line = Color(0xFFF0E6CF);
  static const lineDark = Color(0xFFE0D2B0);
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
      labelStyle: appText(color: AppColors.muted),
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
        textStyle: appText(weight: FontWeight.w800, color: Colors.white),
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
