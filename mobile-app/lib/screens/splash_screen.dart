// Uygulama açılış kapısı: asıl içerik (giriş ya da ana kabuk) altta arka planda
// hazırlanırken Hupo marka sahnesi üstte oynar, sonra perde gibi açılır.
//
// Tasarım kuralları (bkz. docs/splash/ACILIS_SENARYOSU_PLANI.md, BAKIM.md):
//  * İlk açılış            → tam "Kanat İmzası" sahnesi (1600 ms) + marka sesi.
//  * Sonraki açılışlar     → kısa sahne (900 ms), sessiz.
//  * Hareket azalt         → statik marka karesi.
//  * Arka plandan dönüş    → SplashGate yeniden kurulmaz; sahne tekrar oynamaz.
//  * Dokunma               → 600 ms sonra sahne atlanır.
//
// Sahne, içeriğin hazır olmasını BEKLEMEZ: kendi süresiyle biter ve altta
// hazır olan içerik ortaya çıkar. Böylece gereksiz bekleme yoktur.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_open_service.dart';
import '../services/audio/audio_event.dart';
import '../services/audio/audio_manager.dart';
import '../settings/app_settings.dart';
import '../widgets/splash/hupo_signature_entrance.dart';

/// Açılış kapısı. [child] asıl uygulamadır (giriş veya ana kabuk).
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate>
    with WidgetsBindingObserver {
  /// Karar bir kez verilir; yaşam döngüsü değişimleri sahneyi yeniden tetiklemez.
  late final AppOpenPlan _plan;

  /// Sahne kalıcı olarak kaldırıldı mı?
  bool _kaldirildi = false;

  /// Çıkış animasyonu (perde) başladı mı?
  bool _kapaniyor = false;

  /// Perde sonrası kaldırma zamanlayıcısı.
  Timer? _zamanlayici;

  /// Dokunarak atlama eşiği doldu mu? (Timer: test ortamında sahte zamanla uyumlu.)
  bool _atlanabilir = false;
  Timer? _atlamaZamanlayici;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final prefs = ref.read(sharedPreferencesProvider);
    final settings = ref.read(settingsProvider);

    final kind = resolveAppOpenKind(firstGreetingDone: firstGreetingDone(prefs));
    _plan = planAppOpen(kind: kind, reducedMotion: settings.reduceMotion);

    _atlamaZamanlayici = Timer(kHupoAtlamaEsigi, () => _atlanabilir = true);

    // Marka sesi YALNIZCA ilk açılışta, hareketli tam sahnede çalınır.
    if (_plan.playBrandSound) {
      AudioManager.instance.play(AudioEvent.brand);
    }
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _atlamaZamanlayici?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sahne oynarken arka plana gidip dönülürse hemen bitir.
    if (state == AppLifecycleState.resumed && !_kaldirildi) _kapat();
  }

  /// Sahneyi perde gibi açar (fade-out) ve ardından kaldırır.
  void _kapat() {
    if (!mounted || _kapaniyor || _kaldirildi) return;
    setState(() => _kapaniyor = true);
    final solmaMs = ref.read(settingsProvider).reduceMotion ? 0 : 350;
    _zamanlayici = Timer(Duration(milliseconds: solmaMs), () {
      if (!mounted) return;
      setState(() => _kaldirildi = true);
      // İlk karşılama gösterildiyse bir kez işaretle (kalıcı, oturumdan bağımsız).
      if (_plan.kind == AppOpenKind.firstLaunch) {
        markFirstGreetingDone(ref.read(sharedPreferencesProvider));
      }
    });
  }

  /// Dokunarak atla: eşikten önce sahne atlanamaz.
  void _dokunuldu() {
    if (_atlanabilir) _kapat();
  }

  @override
  Widget build(BuildContext context) {
    // Sahne bittiyse doğrudan içerik.
    if (_kaldirildi) return widget.child;

    final azalt = ref.read(settingsProvider).reduceMotion;

    return Stack(
      fit: StackFit.expand,
      children: [
        // İçerik altta zaten hazır: sahne bitince kesintisiz ortaya çıkar.
        widget.child,
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _kapaniyor ? 0 : 1,
            duration: Duration(milliseconds: azalt ? 0 : 350),
            curve: kHupoEase,
            child: IgnorePointer(
              ignoring: _kapaniyor,
              // Sahne dokunuşları altındaki içeriğe geçirmez; dokununca atlanır.
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dokunuldu,
                child: Semantics(
                  label: 'Hupolingo açılıyor',
                  image: true,
                  child: ExcludeSemantics(
                    // Sistem çubukları sahneyle aynı turkuaz: sistem splash'inden
                    // Flutter'a geçişte gezinme çubuğu rengi sıçramaz.
                    child: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light,
                        statusBarBrightness: Brightness.dark,
                        systemNavigationBarColor: AppColorsSplash.primary,
                        systemNavigationBarIconBrightness: Brightness.light,
                        // Android 15+ gezinme çubuğuna kendi açık "kontrast" bandını çizer.
                        systemNavigationBarContrastEnforced: false,
                        systemNavigationBarDividerColor: Colors.transparent,
                      ),
                      child: HupoSignatureEntrance(
                        onFinished: _kapat,
                        reducedMotion: _plan.scene == AppOpenScene.still,
                        kisa: _plan.scene == AppOpenScene.short,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sahnenin kendi renk sabitleri: splash yüklenirken tema hazır olmayabilir.
class AppColorsSplash {
  AppColorsSplash._();
  static const primary = Color(0xFF147D8A);
  static const primaryDark = Color(0xFF0D5762);
}
