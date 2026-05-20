import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../mock/mock_auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/ciclocare_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await MockAuthService.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // ── Logo ─────────────────────────────────────────────
                const CicloCareLogo(size: 90),
                const SizedBox(height: 16),

                // ── Título ───────────────────────────────────────────
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(text: 'Ciclo', style: TextStyle(color: Color(0xFF3DBE8B))),
                      TextSpan(text: 'Care', style: TextStyle(color: Color(0xFF9B59B6))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── Subtítulo ────────────────────────────────────────
                const Text(
                  'Cuide da sua saúde de forma simples\ne inteligente, onde estiver.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Email ────────────────────────────────────────────
                AuthTextField(
                  label: 'Email',
                  hint: 'name@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Senha ────────────────────────────────────────────
                AuthTextField(
                  label: 'Senha',
                  hint: '••••••••••',
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

                // ── Esqueci senha ────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Esqueci minha senha?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Erro geral ───────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 16)),
                      ),
                    ]),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Botão Login ──────────────────────────────────────
                AuthButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // ── Não tem conta ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text('Se inscreva',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Faça login com ───────────────────────────────────
                const Text('Faça login com',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 22),
                    _SocialButton(
                      icon: Icons.facebook_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 22),
                    _SocialButton(
                      icon: Icons.apple,
                      onTap: () {},
                    ),
                  ],
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

// ── Botão social ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}
