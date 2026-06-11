import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../mock/mock_auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/ciclocare_logo.dart';

// ════════════════════════════════════════════════════════════
//  REGISTER SCREEN — CicloCare
//  Arquivo: lib/features/auth/screens/register_screen.dart
//
//  Com:
//  • Máscara de CPF: 000.000.000-00
//  • Máscara de telefone: (00) 00000-0000
//  • Indicador de força da senha
//  • Validação completa
// ════════════════════════════════════════════════════════════

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _nameCtrl            = TextEditingController();
  final _phoneCtrl           = TextEditingController();
  final _cpfCtrl             = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading    = false;
  bool _acceptTerms  = false;
  String? _errorMsg;
  int _passwordStrength = 0; // 0-4

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Força da senha ───────────────────────────────────────
  void _updatePasswordStrength() {
    final p = _passwordCtrl.text;
    int strength = 0;
    if (p.length >= 8)                          strength++;
    if (p.contains(RegExp(r'[A-Z]')))           strength++;
    if (p.contains(RegExp(r'[0-9]')))           strength++;
    if (p.contains(RegExp(r'[!@#\$&*~%^()]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 0: case 1: return AppColors.error;
      case 2:         return AppColors.warning;
      case 3:         return Colors.yellow.shade700;
      case 4:         return AppColors.success;
      default:        return AppColors.error;
    }
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0: case 1: return 'Fraca';
      case 2:         return 'Razoável';
      case 3:         return 'Boa';
      case 4:         return 'Forte';
      default:        return '';
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _errorMsg = 'Aceite os Termos e a Política de Privacidade para continuar.');
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    final error = await MockAuthService.instance.register(
      _nameCtrl.text, _emailCtrl.text, _passwordCtrl.text,
      phone: _phoneCtrl.text, cpf: _cpfCtrl.text,
    );

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
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Icon(Icons.chevron_left_rounded,
                          color: AppColors.primary, size: 24),
                      ),
                    ),
                  ),
                  Text('Criar conta', style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preencha seus dados para começar',
                        style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 24),

                      // Nome
                      AuthTextField(
                        label: 'Nome completo',
                        hint: 'Seu nome completo',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe seu nome';
                          if (v.trim().split(' ').length < 2) return 'Informe nome e sobrenome';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Telefone com máscara
                      _MaskedTextField(
                        label: 'Telefone',
                        hint: '(00) 00000-0000',
                        controller: _phoneCtrl,
                        mask: '(##) #####-####',
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu telefone';
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 11) return 'Telefone inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // CPF com máscara
                      _MaskedTextField(
                        label: 'CPF',
                        hint: '000.000.000-00',
                        controller: _cpfCtrl,
                        mask: '###.###.###-##',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe seu CPF';
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length != 11) return 'CPF inválido';
                          if (!_isValidCpf(digits)) return 'CPF inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Email
                      AuthTextField(
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        controller: _emailCtrl,
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
                        hint: 'Mínimo 8 caracteres',
                        controller: _passwordCtrl,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe uma senha';
                          if (v.length < 8) return 'Mínimo 8 caracteres';
                          if (_passwordStrength < 2) return 'Senha muito fraca';
                          return null;
                        },
                      ),

                      // Indicador de força
                      if (_passwordCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _PasswordStrengthIndicator(
                          strength: _passwordStrength,
                          color: _strengthColor,
                          label: _strengthLabel,
                        ),
                      ],
                      const SizedBox(height: 18),

                      // Confirmar senha
                      AuthTextField(
                        label: 'Confirmar senha',
                        hint: 'Repita a senha',
                        controller: _confirmPasswordCtrl,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleRegister,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme sua senha';
                          if (v != _passwordCtrl.text) return 'As senhas não coincidem';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Termos
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                              side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                              onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall,
                                children: [
                                  const TextSpan(text: 'Li e concordo com os '),
                                  WidgetSpan(child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
                                    child: Text('Termos e Condições',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  )),
                                  const TextSpan(text: ' e a '),
                                  WidgetSpan(child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
                                    child: Text('Política de Privacidade',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  )),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Erro
                      if (_errorMsg != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMsg!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 28),

                      AuthButton(
                        text: 'Criar conta',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Já tem conta? ', style: AppTextStyles.bodyMedium),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text('Entrar',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary)),
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

  // Validação de CPF (algoritmo oficial)
  bool _isValidCpf(String cpf) {
    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;
    int sum = 0;
    for (int i = 0; i < 9; i++) sum += int.parse(cpf[i]) * (10 - i);
    int rem = (sum * 10) % 11;
    if (rem == 10 || rem == 11) rem = 0;
    if (rem != int.parse(cpf[9])) return false;
    sum = 0;
    for (int i = 0; i < 10; i++) sum += int.parse(cpf[i]) * (11 - i);
    rem = (sum * 10) % 11;
    if (rem == 10 || rem == 11) rem = 0;
    return rem == int.parse(cpf[10]);
  }
}

// ── Campo com máscara ─────────────────────────────────────────────────────────
class _MaskedTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String mask;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _MaskedTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.mask,
    required this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: [_MaskFormatter(mask)],
          style: AppTextStyles.inputText,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ── Formatter de máscara ──────────────────────────────────────────────────────
class _MaskFormatter extends TextInputFormatter {
  final String mask;
  _MaskFormatter(this.mask);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < mask.length && digitIndex < digits.length; i++) {
      if (mask[i] == '#') {
        buffer.write(digits[digitIndex++]);
      } else {
        buffer.write(mask[i]);
      }
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ── Indicador de força da senha ───────────────────────────────────────────────
class _PasswordStrengthIndicator extends StatelessWidget {
  final int strength;
  final Color color;
  final String label;

  const _PasswordStrengthIndicator({
    required this.strength,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < strength ? color : AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Senha: ', style: AppTextStyles.bodySmall),
            Text(label, style: AppTextStyles.bodySmall.copyWith(
              color: color, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text(
              strength < 4 ? '• Use maiúsculas, números e símbolos' : '✓ Ótima!',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }
}