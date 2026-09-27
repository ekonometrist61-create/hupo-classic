import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui/game_card.dart';
import 'push_providers.dart';
import 'push_service.dart';

/// Ayarlar ekranındaki "Bildirimler" kartı.
///
/// Kurallar: bildirimler varsayılan KAPALIDIR; izin yalnızca bu anahtar açılınca istenir;
/// çocuk hesabında velinin onayı yoksa anahtar kilitlidir. Metinler cesaretlendiricidir,
/// suçlayıcı/baskıcı ifade kullanılmaz.
class PushSettingsCard extends ConsumerStatefulWidget {
  const PushSettingsCard({super.key});

  @override
  ConsumerState<PushSettingsCard> createState() => _PushSettingsCardState();
}

class _PushSettingsCardState extends ConsumerState<PushSettingsCard> {
  bool _busy = false;

  static const _explainTitle = 'Bildirimleri açalım mı?';
  static const _explainBody =
      'Yeni rozet, seviye ve günlük hedef gibi güzel haberleri telefonundan haber verelim. '
      'İstediğin zaman buradan kapatabilirsin. '
      'Akşam 20:00 ile sabah 08:00 arasında bildirim göndermeyiz.';

  Future<bool> _confirm() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_explainTitle, style: appText(size: 20, weight: FontWeight.w900)),
        content: Text(
          _explainBody,
          style: appText(
              size: 14, weight: FontWeight.w700, color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Şimdi değil'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Evet, aç'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _toggle(bool on) async {
    if (_busy) return;
    if (on && !await _confirm()) return;
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(pushServiceProvider);
      if (on) {
        switch (await service.enable()) {
          case PushEnableResult.enabled:
            _say('Bildirimler açıldı. İstediğin zaman kapatabilirsin.');
          case PushEnableResult.needsParentConsent:
            _say('Bildirimleri açmak için velinin onayı gerekiyor.');
          case PushEnableResult.permissionDenied:
            _say('Bildirim izni verilmedi, sorun değil. '
                'İstersen telefonunun ayarlarından açabilirsin.');
          case PushEnableResult.unavailable:
            _say('Bildirimler bu cihazda henüz kullanılamıyor.');
          case PushEnableResult.failed:
            _say('Bildirimler açılamadı, biraz sonra tekrar deneyelim.');
        }
      } else {
        if (await service.disable()) {
          _say('Bildirimler kapatıldı.');
        } else {
          _say('Bildirimler kapatılamadı, biraz sonra tekrar deneyelim.');
        }
      }
    } catch (_) {
      _say('Bir şeyler ters gitti, biraz sonra tekrar deneyelim.');
    } finally {
      ref.invalidate(pushPreferenceProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bilerek yalnızca arka ucu izleriz: Supabase hazır değilken de çizilebilsin.
    final supported = ref.watch(pushBackendProvider).supported;
    final pref = ref.watch(pushPreferenceProvider);

    String subtitle;
    bool value = false;
    bool enabledSwitch = false;

    if (!supported) {
      subtitle = 'Bildirimler bu cihazda henüz kullanılamıyor.';
      value = false;
    } else {
      final p = pref.valueOrNull;
      if (pref.hasError) {
        subtitle = 'Ayarlar şu an yüklenemedi. Biraz sonra tekrar deneyelim.';
        value = false;
      } else if (p == null) {
        subtitle = 'Ayarların yükleniyor…';
        value = false;
      } else if (p.needsParentConsent) {
        subtitle = 'Velinin onayı gerekiyor. Velin onay verince buradan açabilirsin.';
        value = false;
      } else {
        subtitle = 'Yeni rozetler ve güzel haberler için sana haber verelim mi?';
        value = p.enabled;
        enabledSwitch = !_busy;
      }
    }

    final p = pref.valueOrNull;
    final quiet = 'Sessiz saatler: ${p?.quietStart ?? '20:00'} - ${p?.quietEnd ?? '08:00'} '
        'arasında bildirim göndermeyiz.';

    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bildirimler',
                            style: appText(size: 16, weight: FontWeight.w900)),
                        Text(
                          subtitle,
                          style: appText(
                              size: 12, weight: FontWeight.w700, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    key: const Key('push-switch'),
                    value: value,
                    onChanged: enabledSwitch ? _toggle : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              quiet,
              style: appText(size: 12, weight: FontWeight.w700, color: AppColors.muted),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
