import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login.dart';
import 'config/env.dart';
import 'screens/root_shell.dart';
import 'screens/splash_screen.dart';
import 'services/audio/audio_manager.dart';
import 'services/error_reporting.dart';
import 'services/kullanim_suresi.dart';
import 'services/push/push_host.dart';
import 'services/secure_storage.dart';
import 'settings/app_settings.dart';
import 'theme/app_theme.dart';
import 'widgets/maintenance_gate.dart';
import 'widgets/splash/hupo_signature_entrance.dart' show kHupoEntranceAsset;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hata raporlama (Sentry) uygulama başlamadan önce kurulur; DSN boşsa yalnızca yerel kanca.
  await baslatHataRaporlama(_uygulamayiBaslat, dsn: Env.sentryDsn);
}

Future<void> _uygulamayiBaslat() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
    authOptions: FlutterAuthClientOptions(localStorage: supabaseLocalStorage()),
  );
  final prefs = await SharedPreferences.getInstance();

  // Açılış sahnesinin Hupo görselini ilk kareden önce çöz: ilk karede Hupo hazır olsun.
  await _acilisGorseliniOnYukle();

  // Sık kullanılan sesleri önceden yükle (hata olursa sessizce devam eder).
  AudioManager.instance.preload();

  // Anonim ekran-süresi ölçümü (hesaba bağlı değil; hatalar sessiz).
  KullanimSuresi.baslat(rolBulucu: _kabaRol);

  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const App(),
  ));
}

/// Açılış sahnesinin Hupo görselini görüntü önbelleğine yükler (en çok 2 sn bekler).
///
/// Sahnenin ilk karesi sistem splash'iyle birebir aynı olmalı; görsel ilk karede
/// çözülmemişse Hupo bir an eksik kalır. Hata olursa sahne yine de açılır.
Future<void> _acilisGorseliniOnYukle() async {
  final bitti = Completer<void>();
  final akim = const AssetImage(kHupoEntranceAsset).resolve(ImageConfiguration.empty);
  late final ImageStreamListener dinleyici;
  void tamam() {
    akim.removeListener(dinleyici);
    if (!bitti.isCompleted) bitti.complete();
  }

  dinleyici = ImageStreamListener((_, __) => tamam(), onError: (_, __) => tamam());
  akim.addListener(dinleyici);
  await bitti.future.timeout(const Duration(seconds: 2), onTimeout: () {});
}

/// Kaba rol: yalnız ogrenci|veli|ogretmen|admin|ziyaretci (kimlik değil).
String _kabaRol() {
  final u = Supabase.instance.client.auth.currentUser;
  if (u == null) return 'ziyaretci';
  final r = u.userMetadata?['role'];
  return r is String && const {'ogrenci', 'veli', 'ogretmen', 'admin'}.contains(r) ? r : 'ogrenci';
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: pushNavigatorKey,
      scaffoldMessengerKey: pushMessengerKey,
      navigatorObservers: [KullanimNavigatorObserver(() => KullanimSuresi.instance!)],
      title: 'Hupolingo',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(fontFamily: settings.font.family),
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Erişilebilirlik ayarları tüm ekranlara buradan yansır:
      //  * Hareketi azalt → MediaQuery.disableAnimations (işletim sistemi ayarıyla birleşir)
      //  * Yazı boyutu    → işletim sistemi yazı boyutuyla çarpılır
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final systemScale = mq.textScaler.scale(1);
        return MediaQuery(
          data: mq.copyWith(
            disableAnimations: mq.disableAnimations || settings.reduceMotion,
            textScaler: TextScaler.linear(
              (systemScale * settings.textSize.scale).clamp(0.8, 2.0).toDouble(),
            ),
          ),
          // Push (yalnızca mobil + yapılandırılmışsa etkin; aksi halde hiçbir şey yapmaz)
          child: PushHost(child: MaintenanceGate(child: child ?? const SizedBox.shrink())),
        );
      },
      home: const SplashGate(child: AuthGate()),
    );
  }
}

/// Oturum varsa ana kabuğu (alt gezinme), yoksa giriş ekranını gösterir.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const LoginScreen() : const RootShell();
      },
    );
  }
}
