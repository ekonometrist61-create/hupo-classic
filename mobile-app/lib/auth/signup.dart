import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';
import 'auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // handle_new_user tetikleyicisi bu bilgilerle profili oluşturur.
        data: {'full_name': _nameController.text.trim(), 'role': 'ogrenci'},
      );
      if (!mounted) return;

      if (response.session != null) {
        // Oturum açıldı; AuthGate ana ekrana geçirir. Kayıt ekranını kapat.
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // E-posta doğrulaması açıksa oturum hemen başlamaz.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kayıt tamam! E-postana gelen bağlantıyla hesabını doğrula, sonra giriş yap.'),
          duration: Duration(seconds: 6),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) showError(context, authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Kayıt Ol',
      subtitle: 'Yolculuğa başlamak için hesabını oluştur!',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: authFieldDecoration('Ad Soyad', Icons.person_outline),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Adını gir' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: authFieldDecoration('E-posta', Icons.email_outlined),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Geçerli bir e-posta gir'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration:
                    authFieldDecoration('Şifre', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Şifre en az 6 karakter olmalı'
                    : null,
                onFieldSubmitted: (_) => _signup(),
              ),
              const SizedBox(height: 24),
              AuthSubmitButton(
                label: 'Kayıt ol',
                loading: _loading,
                onPressed: _signup,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Zaten hesabın var mı? Giriş yap',
            style: appText(size: 16, weight: FontWeight.w800, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
