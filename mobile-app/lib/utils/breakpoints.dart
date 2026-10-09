// Ekran genişliği kırılımları (Flutter Web / tablet / masaüstü).
// Ölçüt: MediaQuery.sizeOf(context).width. Sabitler yalnızca burada tanımlanır.

import 'package:flutter/widgets.dart';

/// Tablet alt sınırı (dahil). Bunun altı telefondur.
const double kTabletMinWidth = 600;

/// Masaüstü alt sınırı (dahil). Bu genişlikte sol NavigationRail görünür.
const double kDesktopMinWidth = 1024;

/// Tablette ortalı içerik üst genişliği.
const double kTabletContentMaxWidth = 720;

/// Masaüstünde ortalı içerik üst genişliği.
const double kDesktopContentMaxWidth = 1100;

/// Quiz ekranı kolonunun üst genişliği (tek sütun).
const double kQuizMaxWidth = 760;

/// Telefon (<600): mevcut düzen, hiçbir şey değişmez.
bool isPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kTabletMinWidth;

/// Tablet: 600–1023.
bool isTablet(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w >= kTabletMinWidth && w < kDesktopMinWidth;
}

/// Masaüstü: >= 1024.
bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kDesktopMinWidth;

/// Tablet veya masaüstü (>= 600).
bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kTabletMinWidth;

/// Genişliğe göre ortalı içerik üst sınırı: tablet 720, masaüstü 1100.
/// Telefonda sınır yoktur ([double.infinity]).
double contentMaxWidth(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= kDesktopMinWidth) return kDesktopContentMaxWidth;
  if (w >= kTabletMinWidth) return kTabletContentMaxWidth;
  return double.infinity;
}
