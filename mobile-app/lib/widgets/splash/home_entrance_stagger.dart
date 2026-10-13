// Ana sayfaya giriş koordinasyonu (Sahne 4 — READY TO EXPLORE).
//
// Splash sahnesi biterken Hupo nihai konumuna yerleşir; ana sayfa içeriği çok
// hafif bir "stagger" (kademeli belirme) ile ortaya çıkar. Böylece karakterin
// splash'teki konumu ile ana sayfadaki son konumu arasında keskin sıçrama
// olmaz ve geçiş "tek marka deneyimi" gibi hissedilir.
//
// Bu widget HomeScreen'in kendisini DEĞİŞTİRMEZ; yalnızca içeriği sarmalar.
// Hareket azalt açıksa hiçbir animasyon uygulanmaz (içerik doğrudan görünür).

import 'package:flutter/material.dart';

import '../../services/app_open_service.dart';

/// İçeriği kısa bir kademeli belirmeyle gösterir.
///
/// [delay] bu grubun ne kadar gecikmeyle başlayacağını belirtir. Aynı ekranda
/// birden çok grup sırayla belirir (Hupo → hedef → içerik).
class HomeEntranceStagger extends StatefulWidget {
  const HomeEntranceStagger({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offset = 12,
  });

  final Widget child;

  /// Belirmenin başlama gecikmesi.
  final Duration delay;

  /// Belirme süresi.
  final Duration duration;

  /// Başlangıç dikey kayması (px). 0 ise yalnızca opaklık.
  final double offset;

  @override
  State<HomeEntranceStagger> createState() => _HomeEntranceStaggerState();
}

class _HomeEntranceStaggerState extends State<HomeEntranceStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _kayma;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final egri = CurvedAnimation(parent: _controller, curve: kHupoEase);
    _opacity = egri;
    _kayma = Tween<double>(begin: widget.offset, end: 0).animate(egri);
    // Gecikmeli başlat.
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hareket azalt: animasyon yok, içerik doğrudan görünür.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _kayma.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
