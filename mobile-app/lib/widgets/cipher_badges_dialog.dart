// Çarpım tablosu şifre rozetleri ve unvan iletişim kutusu.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ui/chunky_button.dart';

class CipherBadgesView extends StatelessWidget {
  const CipherBadgesView({
    super.key,
    required this.unvan,
    this.aciklama,
    this.kazanildi = true,
  });

  final String unvan;
  final String? aciklama;
  final bool kazanildi;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: kazanildi ? AppColors.sunSoft : AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(
              color: kazanildi ? AppColors.sun : AppColors.primary,
              width: 3,
            ),
          ),
          child: Icon(
            kazanildi
                ? Icons.military_tech_rounded
                : Icons.lock_outline_rounded,
            size: 44,
            color: kazanildi ? AppColors.sunDark : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          unvan,
          textAlign: TextAlign.center,
          style: appText(
            size: 20,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          aciklama ??
              (kazanildi
                  ? 'Tebrikler! Bu şifreyi tamamladın ve unvanı kazandın.'
                  : 'Şifrenin kapalı testini çözünce bu unvan senin olacak!'),
          textAlign: TextAlign.center,
          style: appText(
            size: 14,
            weight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 24),
        ChunkyButton(
          label: 'Harika!',
          icon: Icons.check_circle_rounded,
          color: AppColors.mint,
          shadowColor: AppColors.mintDark,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

Future<void> showCipherBadgesDialog(
  BuildContext context, {
  required String unvan,
  String? aciklama,
  bool kazanildi = true,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CipherBadgesView(
          unvan: unvan,
          aciklama: aciklama,
          kazanildi: kazanildi,
        ),
      ),
    ),
  );
}
