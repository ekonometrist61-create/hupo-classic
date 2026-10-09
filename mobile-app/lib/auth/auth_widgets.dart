import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';

/// Giriş ve kayıt ekranlarının ortak iskeleti: üstte maskotlu başlık, altta form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroHeader(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  const Hupo(mood: HupoMood.welcome, size: 128, animated: true),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: appText(size: 32, weight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: appText(
                      weight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration authFieldDecoration(String label, IconData icon) {
  return InputDecoration(labelText: label, prefixIcon: Icon(icon));
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChunkyButton(label: label, loading: loading, onPressed: onPressed);
  }
}

/// Supabase hata mesajlarını kullanıcıya anlaşılır Türkçe metne çevirir.
String authErrorMessage(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'E-posta veya şifre yanlış görünüyor, bir daha dener misin?';
    }
    if (message.contains('email not confirmed')) {
      return 'E-posta adresin henüz doğrulanmamış. Gelen kutunu kontrol et.';
    }
    if (message.contains('already registered')) {
      return 'Bu e-posta ile zaten bir hesap var.';
    }
    if (message.contains('password')) {
      return 'Şifre en az 8 karakter olmalı.';
    }
    return error.message;
  }
  return 'Bağlantı kurulamadı. İnternetini kontrol edip tekrar deneyelim.';
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.coralDark),
  );
}
