import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../mock/mock_auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Aceite os Termos e Condições para continuar.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final error = await MockAuthService.instance.register(
      _nameController.text,
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
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Botão voltar (esquerda)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  // Título centralizado
                  const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulário ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtítulo
                      const Text(
                        'Realize o cadastro com os seguintes dados',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nome completo
                      AuthTextField(
                        label: 'Nome Completo',
                        hint: 'Guilherme Rodrigues Esteves',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                          if (v.trim().length < 3) return 'Nome muito curto';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Telefone
                      AuthTextField(
                        label: 'Telefone',
                        hint: '(00) 00000-0000',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe seu telefone';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // CPF
                      AuthTextField(
                        label: 'CPF',
                        hint: '000.000.000-00',
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe seu CPF';
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length != 11) return 'CPF inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      AuthTextField(
                        label: 'Email',
                        hint: 'nome@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Senha
                      AuthTextField(
                        label: 'Senha',
                        hint: 'Digite a Senha',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe uma senha';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirmar senha
                      AuthTextField(
                        label: '',
                        hint: 'Digite a Senha',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleRegister,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme sua senha';
                          if (v != _passwordController.text) return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Termos e condições
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(text: 'Li e concordo com os e '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
                                      child: const Text(
                                        'Termos e Condições',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: ' e com a '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                                      child: const Text(
                                        'Política de Privacidade',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Erro geral
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
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
                                style: TextStyle(color: AppColors.error, fontSize: 13)),
                            ),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botão cadastrar (texto "Login" conforme Figma)
                      AuthButton(
                        text: 'Login',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 20),

                      // Link login
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Já tem conta? ',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Faça o login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
