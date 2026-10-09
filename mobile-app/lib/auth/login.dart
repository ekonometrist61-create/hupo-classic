import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/web_links.dart';
import '../theme/app_theme.dart';
import 'auth_widgets.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Yönlendirmeyi AuthGate oturum değişimini dinleyerek yapar.
    } catch (e) {
      if (mounted) showError(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Parola sıfırlama web'de başlatılır (bağlantı web'e döner); bkz. web-panel /sifre-unuttum.
  Future<void> _openPasswordReset() async {
    final opened = await openWebPage('/sifre-unuttum');
    if (!opened && mounted) {
      showError(context, 'Sayfa açılamadı, birazdan tekrar deneyelim.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Giriş Yap',
      subtitle: 'Hedeflerine bir adım daha yaklaş!',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: authFieldDecoration('E-posta', Icons.email_outlined),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Geçerli bir e-posta gir'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                decoration:
                    authFieldDecoration('Şifre', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Şifreni gir' : null,
                onFieldSubmitted: (_) => _login(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _openPasswordReset,
                  child: Text(
                    'Parolanı mı unuttun?',
                    style: appText(weight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthSubmitButton(
                label: 'Giriş yap',
                loading: _loading,
                onPressed: _login,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          ),
          child: Text(
            'Hesabın yok mu? Kayıt ol',
            style: appText(weight: FontWeight.w800, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
