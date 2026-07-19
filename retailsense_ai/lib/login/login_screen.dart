import 'package:flutter/material.dart';

import '../app/localization/app_i18n.dart';
import '../routes/route_names.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showHint = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppI18n.t(context, 'login_empty_error'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final success = AuthService().login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, RouteNames.dashboard, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identifiants incorrects. V�rifiez votre email et mot de passe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppI18n.t(context, 'login_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, RouteNames.landing, (_) => false),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'RetailSense AI',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour acceder a la plateforme',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  label: AppI18n.t(context, 'field_email'),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _passwordController,
                  label: AppI18n.t(context, 'field_password'),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _showHint = !_showHint),
                  child: Text(
                    _showHint ? 'Masquer les identifiants de d�mo' : 'Voir les identifiants de d�mo',
                    style: const TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ),
                if (_showHint) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Compte de d�monstration', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Text('Email : ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            SelectableText(AuthService.demoEmail, style: const TextStyle(color: AppColors.text, fontSize: 12)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Mot de passe : ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            SelectableText(AuthService.demoPassword, style: const TextStyle(color: AppColors.text, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                CustomButton(
                  label: AppI18n.t(context, 'login_button'),
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
