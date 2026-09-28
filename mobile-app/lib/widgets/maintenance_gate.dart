// Bakım modu ve zorunlu sürüm güncellemesi denetim kapısı.
//
// Sunucudan gelen get_app_config() yanıtını kontrol eder. Bakım modundaysa veya
// sürüm eskiyse uygulamanın açılışını durdurur ve bilgilendirici ekran sunar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'ui/chunky_button.dart';
import 'ui/responsive_page.dart';

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
        return widget.child;
      },
      loading: () => widget.child,
      error: (_, __) => widget.child, // Ağ hatasında çocuğu kilitleme, varsayılan akış devam eder
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
                  color: isUpdateRequired ? AppColors.sunSoft : AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUpdateRequired ? Icons.system_update_rounded : Icons.handyman_rounded,
                  size: 50,
                  color: isUpdateRequired ? AppColors.sunDark : AppColors.primary,
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
                  onPressed: () {
                    // Mağaza linki
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
