// Çoklu ekran boyutları ve tablet desteği için duyarlı sayfa sarmalayıcısı.

import 'package:flutter/material.dart';

import '../../utils/breakpoints.dart';

export '../../utils/breakpoints.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;

  /// Verilmezse genişliğe göre seçilir: telefonda 600 (mevcut davranış),
  /// tablet ve masaüstünde 720.
  final double? maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final limit = maxWidth ??
        (isWide(context) ? kTabletContentMaxWidth : 600.0);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: limit),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Liste içeriğini tablette 720, masaüstünde 1100 ile sınırlayıp ortalar.
/// Telefonda çocuğu olduğu gibi döner (düzen değişmez). Başlık/hero arka planı
/// tam genişlikte kalsın diye yalnızca içerik bölümünü sarmak için kullanılır.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth});

  final Widget child;

  /// Verilmezse [contentMaxWidth] (tablet 720, masaüstü 1100).
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!isWide(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? contentMaxWidth(context)),
        child: child,
      ),
    );
  }
}
