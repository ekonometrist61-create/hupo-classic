// Bakım modu ve zorunlu sürüm güncellemesi denetim kapısı.
//
// Sunucudan gelen get_app_config() yanıtını kontrol eder. Bakım modundaysa veya
// sürüm eskiyse uygulamanın açılışını durdurur ve bilgilendirici ekran sunar.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'ui/chunky_button.dart';
import 'ui/responsive_page.dart';

// TODO(yayin): App Store'a yüklendikten sonra gerçek iOS uygulama ID'sini gir.
const _kAndroidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.ogrencihazirlik.ogrenci_hazirlik';
const _kIosStoreUrl = 'https://apps.apple.com/app/id000000000';

/// "1.2.3" formatındaki iki sürümü karşılaştırır.
/// a < b → negatif, a == b → 0, a > b → pozitif döner.
int _karsilastir(String a, String b) {
  final aParts = a.split('.').map(int.tryParse).toList();
  final bParts = b.split('.').map(int.tryParse).toList();
  for (var i = 0; i < 3; i++) {
    final av = (i < aParts.length ? aParts[i] : null) ?? 0;
    final bv = (i < bParts.length ? bParts[i] : null) ?? 0;
    if (av != bv) return av - bv;
  }
  return 0;
}

bool _guncellemGerekiyor(String mevcutSurum, MinSurum minSurum) {
  final platform = kIsWeb
      ? 'web'
      : Platform.isIOS
          ? 'ios'
          : 'android';
  return _karsilastir(mevcutSurum, minSurum.forPlatform(platform)) < 0;
}

class MaintenanceGate extends ConsumerStatefulWidget {
  const MaintenanceGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<MaintenanceGate> createState() => _MaintenanceGateState();
}

class _MaintenanceGateState extends ConsumerState<MaintenanceGate> {
  String? _mevcutSurum;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _mevcutSurum = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(appConfigFetcherProvider);

    return configAsync.when(
      data: (config) {
        if (config.bakimda) {
          return MaintenanceScreen(
            title: 'Hupo, bakım yapıyor',
            message: config.bakimModu.mesaj ??
                'Hupo uygulamayı senin için daha da güzel yapıyor. Birazdan buradayız, sonra tekrar dene!',
            isUpdateRequired: false,
          );
        }
        // Sürüm henüz alınmadıysa veya güncelleme gerekmiyorsa çocuğa geç.
        if (_mevcutSurum != null &&
            _guncellemGerekiyor(_mevcutSurum!, config.minSurum)) {
          return MaintenanceScreen(
            title: 'Yeni sürüm hazır!',
            message: config.minSurum.mesaj ??
                'Hupo\'nun yeni bir sürümü var. Devam etmek için uygulamayı güncelle!',
            isUpdateRequired: true,
          );
        }
        return widget.child;
      },
      loading: () => widget.child,
      error: (_, __) => widget
          .child, // Ağ hatasında çocuğu kilitleme, varsayılan akış devam eder
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({
    super.key,
    required this.title,
    required this.message,
    this.isUpdateRequired = false,
  });

  final String title;
  final String message;
  final bool isUpdateRequired;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsivePage(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isUpdateRequired
                      ? AppColors.sunSoft
                      : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUpdateRequired
                      ? Icons.system_update_rounded
                      : Icons.handyman_rounded,
                  size: 50,
                  color:
                      isUpdateRequired ? AppColors.sunDark : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: appText(
                  size: 22,
                  weight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: appText(
                  size: 15,
                  weight: FontWeight.w500,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              if (isUpdateRequired)
                ChunkyButton(
                  label: 'Mağazaya Git',
                  icon: Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  onPressed: () async {
                    final url = Uri.parse(
                      (!kIsWeb && Platform.isIOS)
                          ? _kIosStoreUrl
                          : _kAndroidStoreUrl,
                    );
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
