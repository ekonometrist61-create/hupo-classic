import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui/game_card.dart';
import 'push_backend.dart';
import 'push_pre_permission.dart';
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

  Future<bool> _confirm() => showPushPrePermission(context);

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Ön izin, velinin onayı yokken gösterilmez: çocuk önce izin verip sonra "onay gerekli" görmesin.
  Future<bool> _onIzinGosterilebilir() async {
    try {
      final pref = await ref.read(pushPreferenceProvider.future);
      if (pref.needsParentConsent) {
        _say('Bildirimleri açmak için velinin onayı gerekiyor.');
        return false;
      }
      return true;
    } catch (_) {
      _say('Bir şeyler ters gitti, biraz sonra tekrar deneyelim.');
      return false;
    }
  }

  /// Ön izin sorusu. Sıklık sınırı dolduysa Hupo ekranı atlanır: kullanıcı anahtarı kendisi açtığı
  /// için doğrudan sistem izni istenir. Sınır içindeyse cevap ölçülür.
  Future<bool> _onIzinSorusu() async {
    final api = ref.read(pushApiProvider);
    if (!await api.onIzinBaslat()) return true;
    final evet = await _confirm();
    await api.onIzinBildir(evet ? 'evet' : 'ertele');
    return evet;
  }

  Future<void> _toggle(bool on) async {
    if (_busy) return;
    if (on) {
      if (!await _onIzinGosterilebilir()) return;
      try {
        if (!await _onIzinSorusu()) return;
      } catch (_) {
        _say('Bir şeyler ters gitti, biraz sonra tekrar deneyelim.');
        return;
      }
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(pushServiceProvider);
      if (on) {
        // Sistem penceresi bu çağrıda açılacak mı? (yalnızca "notDetermined" ise ölçülür)
        final izinOncesi = await ref.read(pushBackendProvider).permissionStatus();
        final sonuc = await service.enable();
        if (izinOncesi == PushPermission.notDetermined) {
          if (sonuc == PushEnableResult.enabled) {
            await ref.read(pushApiProvider).onIzinBildir('sistem_verildi');
          } else if (sonuc == PushEnableResult.permissionDenied) {
            await ref.read(pushApiProvider).onIzinBildir('sistem_reddedildi');
          }
        }
        switch (sonuc) {
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
                            style: appText(weight: FontWeight.w900)),
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
