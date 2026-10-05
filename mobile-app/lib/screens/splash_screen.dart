// Uygulama açılırken kısa süre görünen tam boy Hupo karşılaması.
//
// Asıl uygulama (giriş ya da ana ekran) altta arka planda hazırlanırken
// karşılama üstte durur, sonra yumuşakça kaybolur. Kullanıcıya fazladan
// bekleme eklemez: asıl ekran zaten yüklenmektedir.

import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/motion.dart';

const String _karsilamaYolu = 'assets/hupo/uygulama/hero_splash.webp';
const String _karsilamaEtiketi = 'Hupo seni karşılıyor';
const Duration _gorunmeSuresi = Duration(milliseconds: 1500);
const int _solmaMs = 450;

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  Timer? _zamanlayici;
  bool _kapaniyor = false;
  bool _kaldirildi = false;

  @override
  void initState() {
    super.initState();
    _zamanlayici = Timer(_gorunmeSuresi, () {
      if (!mounted) return;
      setState(() => _kapaniyor = true);
      _zamanlayici = Timer(motionMs(context, _solmaMs), () {
        if (mounted) setState(() => _kaldirildi = true);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_karsilamaYolu), context);
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_kaldirildi)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _kapaniyor ? 0 : 1,
              duration: motionMs(context, _solmaMs),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: _kapaniyor,
                child: const _KarsilamaEkrani(),
              ),
            ),
          ),
      ],
    );
  }
}

class _KarsilamaEkrani extends StatelessWidget {
  const _KarsilamaEkrani();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _karsilamaEtiketi,
      image: true,
      child: ExcludeSemantics(
        child: ColoredBox(
          color: AppColors.primary,
          child: SizedBox.expand(
            child: Image.asset(
              _karsilamaYolu,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
