import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_providers.dart';
import '../../screens/notifications_screen.dart';
import 'push_backend.dart';
import 'push_providers.dart';

/// MaterialApp'e verilir: uygulama içi afiş ve bildirime dokununca yönlendirme için.
final pushNavigatorKey = GlobalKey<NavigatorState>();
final pushMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Uygulamanın en üstünde durur ve push olaylarını yönetir:
///  * oturum açılınca jetonu eşitler (izin İSTEMEZ),
///  * çıkıştan önce jetonu siler,
///  * uygulama açıkken gelen bildirimi nazik bir afişle gösterir,
///  * bildirime dokunulunca bildirim ekranını açar.
/// Push yapılandırılmamışsa (veya web'de) hiçbir şey yapmaz; asla hata fırlatmaz.
class PushHost extends ConsumerStatefulWidget {
  const PushHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushHost> createState() => _PushHostState();
}

class _PushHostState extends ConsumerState<PushHost> {
  final _subs = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    try {
      final service = ref.read(pushServiceProvider);
      if (!service.supported) return;

      ref.read(quizRepositoryProvider).onBeforeSignOut = service.unregisterCurrentDevice;

      if (!await service.init() || !mounted) return;

      _subs.add(service.foregroundMessages.listen(_showBanner));
      _subs.add(service.openedMessages.listen(_openFrom));
      final initial = await service.initialMessage();
      if (initial != null) _openFrom(initial);

      final auth = ref.read(supabaseProvider).auth;
      _subs.add(auth.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.signedOut) {
          service.onSignedOut();
        } else if (state.session != null &&
            (state.event == AuthChangeEvent.signedIn ||
                state.event == AuthChangeEvent.initialSession)) {
          service.syncAfterLogin();
        }
      }));
      if (auth.currentSession != null) service.syncAfterLogin();
    } catch (e) {
      debugPrint('Push: başlatılamadı ($e)');
    }
  }

  void _showBanner(PushMessage m) {
    ref.invalidate(unreadCountProvider);
    ref.invalidate(notificationsProvider);
    final messenger = pushMessengerKey.currentState;
    if (messenger == null) return;
    final title = m.title?.trim() ?? '';
    final body = m.body?.trim() ?? '';
    if (title.isEmpty && body.isEmpty) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(
        [title, body].where((s) => s.isNotEmpty).join('\n'),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      action: SnackBarAction(label: 'Gör', onPressed: () => _openFrom(m)),
    ));
  }

  void _openFrom(PushMessage m) {
    if (m.route != null && m.route != 'notifications') return;
    if (ref.read(supabaseProvider).auth.currentUser == null) return; // giriş yoksa yönlendirme yok
    ref.invalidate(unreadCountProvider);
    pushNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
