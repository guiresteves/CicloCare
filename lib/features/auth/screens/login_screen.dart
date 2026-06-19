import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../mock/mock_auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/ciclocare_logo.dart';

// ════════════════════════════════════════════════════════════
//  LOGIN SCREEN — CicloCare
//  Arquivo: lib/features/auth/screens/login_screen.dart
// ════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading   = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMsg = null; });

    final error = await MockAuthService.instance.login(
      _emailController.text, _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // Logo
                const CicloCareLogo(size: 90),
                const SizedBox(height: 16),

                // Título
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(text: 'Ciclo', style: TextStyle(color: AppColors.primary)),
                      TextSpan(text: 'Care', style: TextStyle(color: Color(0xFF9B59B6))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Cuide da sua saúde com facilidade',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email
                AuthTextField(
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
                    if (!v.contains('@') || !v.contains('.')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Senha
                AuthTextField(
                  label: 'Senha',
                  hint: 'Sua senha',
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _handleLogin,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe sua senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                // Esqueci senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: Text('Esqueci minha senha',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ),

                // Erro
                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  _ErrorBox(message: _errorMsg!),
                ],

                const SizedBox(height: 24),

                // Botão entrar
                AuthButton(
                  text: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),

                // Link cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Não tem conta? ',
                      style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: Text('Cadastre-se',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Divider social
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ou entre com', style: AppTextStyles.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 20),

                // Botões sociais
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialBtn(icon: Icons.g_mobiledata_rounded, onTap: () {}),
                    const SizedBox(width: 16),
                    _SocialBtn(icon: Icons.facebook_rounded, onTap: () {}),
                    const SizedBox(width: 16),
                    _SocialBtn(icon: Icons.apple, onTap: () {}),
                  ],
                ),

                // Hint de teste
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🧪 Usuários de teste',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('maria@email.com / 123456\njoao@email.com / 123456',
                        style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: AppColors.white, size: 28),
      ),
    );
  }
}
