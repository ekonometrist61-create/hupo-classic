// Uygulama açılış kapısı: asıl içerik (giriş ya da ana kabuk) altta arka planda
// hazırlanırken Hupo marka sahnesi üstte oynar, sonra yumuşakça kaybolur.
//
// Tasarım kuralları (bkz. docs/splash/BAKIM.md):
//  * İlk açılış / soğuk açılış → tam "Kanat İmzası" sahnesi (0–1600 ms).
//  * Sıcak açılış              → 600 ms mikro karşılama.
//  * Arka plandan dönüş        → animasyon YENİDEN OYNATILMAZ.
//  * Deep link / auth redirect → sahne atlanır, zorla ana sayfaya yönlendirilmez.
//  * Hareket azalt             → statik marka karesi.
//
// Sahne, içeriğin hazır olmasını BEKLEMEZ: kendi süresiyle biter ve altta
// hazır olan içerik ortaya çıkar. Böylece gereksiz bekleme yoktur.

import 'dart:async';

import 'package:flutter/material.dart';
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

  /// Çıkış animasyonu başladı mı?
  bool _kapaniyor = false;

  /// Mikro karşılama zamanlayıcısı (tam sahne olmayan durumlar için).
  Timer? _zamanlayici;

  /// Arka plandan dönüş algılandı mı? (resume → sahne tekrar oynamaz)
  bool _arkaPlandanDondu = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final prefs = ref.read(sharedPreferencesProvider);
    final settings = ref.read(settingsProvider);

    final kind = resolveAppOpenKind(
      firstGreetingDone: firstGreetingDone(prefs),
      resumedFromBackground: false,
      isDeepLink: false,
    );
    _plan = planAppOpen(kind: kind, reducedMotion: settings.reduceMotion);

    // Marka sesi YALNIZCA tam sahnede çalınır. Kısa/atlanan açılışlarda
    // uygulama açılışında ses çalınmaz (teknik gereksinim).
    if (_plan.playFullBrandScene) {
      AudioManager.instance.play(AudioEvent.brand);
    }

    // Tam sahne yoksa (mikro karşılama ya da atla) süre dolunca kapat.
    if (!_plan.playFullBrandScene) {
      if (_plan.skip) {
        _kaldirildi = true;
      } else {
        _zamanlayici = Timer(_plan.duration, _kapat);
      }
    }
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Arka plana gidip dönerse sahne yeniden oynatılmaz.
    if (state == AppLifecycleState.resumed && !_kaldirildi) {
      _arkaPlandanDondu = true;
      // Tam sahne oynarken geri dönüldüyse sahneyi hemen bitir.
      if (_plan.playFullBrandScene) _kapat();
    }
  }

  /// Sahneyi yumuşakça kapatır (fade-out) ve ardından kaldırır.
  void _kapat() {
    if (!mounted || _kapaniyor || _kaldirildi) return;
    setState(() => _kapaniyor = true);
    final solmaMs = ref.read(settingsProvider).reduceMotion ? 0 : 350;
    _zamanlayici = Timer(Duration(milliseconds: solmaMs), () {
      if (!mounted) return;
      setState(() => _kaldirildi = true);
      // Tam sahne gösterildiyse bir kez işaretle (kalıcı, oturumdan bağımsız).
      if (_plan.playFullBrandScene) {
        markFirstGreetingDone(ref.read(sharedPreferencesProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sahne hiç gösterilmeyecekse doğrudan içerik.
    if (_kaldirildi) return widget.child;

    final azalt = ref.read(settingsProvider).reduceMotion;

    return Stack(
      fit: StackFit.expand,
      children: [
        // İçerik altta zaten hazır: sahne bitince kesintisiz ortaya çıkar.
        widget.child,
        // Arka plandan dönüldüyse sahne gösterme.
        if (!_arkaPlandanDondu)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _kapaniyor ? 0 : 1,
              duration: Duration(milliseconds: azalt ? 0 : 350),
              curve: kHupoEase,
              child: IgnorePointer(
                ignoring: _kapaniyor,
                child: _plan.playFullBrandScene
                    ? HupoSignatureEntrance(
                        onFinished: _kapat,
                        reducedMotion: azalt,
                      )
                    : const _MikroKarsilama(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Sıcak açılış mikro karşılaması: çok kısa, sessiz, tam boy karakter yok.
class _MikroKarsilama extends StatelessWidget {
  const _MikroKarsilama();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Hupolingo açılıyor',
      image: true,
      child: const ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColorsSplash.primaryDark, AppColorsSplash.primary],
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 132,
              height: 132,
              child: Image(
                image: AssetImage(kHupoEntranceAsset),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sahnenin kendi renk sabitleri: splash yüklenirken tema hazır olmayabilir.
class AppColorsSplash {
  AppColorsSplash._();
  static const primary = Color(0xFF147D8A);
  static const primaryDark = Color(0xFF0D5762);
}
