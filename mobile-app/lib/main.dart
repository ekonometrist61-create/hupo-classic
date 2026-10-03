import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/login.dart';
import 'config/env.dart';
import 'screens/home_screen.dart';
import 'services/push/push_host.dart';
import 'services/secure_storage.dart';
import 'settings/app_settings.dart';
import 'theme/app_theme.dart';
import 'widgets/maintenance_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
    authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
  );
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const App(),
  ));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: pushNavigatorKey,
      scaffoldMessengerKey: pushMessengerKey,
      title: 'Öğrenci Hazırlık Uygulaması',
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
      home: const AuthGate(),
    );
  }
}

/// Oturum varsa ana ekranı, yoksa giriş ekranını gösterir.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
