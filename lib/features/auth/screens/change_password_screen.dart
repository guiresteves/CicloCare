import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/mock/mock_auth_service.dart';

// ════════════════════════════════════════════════════════════
//  CHANGE PASSWORD SCREEN — CicloCare
//  Arquivo: lib/features/profile/screens/change_password_screen.dart
//
//  Alteração 6:
//  • Senha atual, nova senha e confirmação
//  • Mostrar/ocultar senha em cada campo
//  • Indicador de força da nova senha
//  • Validação completa
//  • Feedback visual de sucesso
// ════════════════════════════════════════════════════════════

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _currentCtrl     = TextEditingController();
  final _newCtrl         = TextEditingController();
  final _confirmCtrl     = TextEditingController();

  bool _showCurrent  = false;
  bool _showNew      = false;
  bool _showConfirm  = false;
  bool _isSaving     = false;
  int  _strength     = 0;

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final p = _newCtrl.text;
    int s = 0;
    if (p.length >= 8)                              s++;
    if (p.contains(RegExp(r'[A-Z]')))              s++;
    if (p.contains(RegExp(r'[0-9]')))              s++;
    if (p.contains(RegExp(r'[!@#\$&*~%^()]')))    s++;
    setState(() => _strength = s);
  }

  Color get _strengthColor {
    switch (_strength) {
      case 0: case 1: return AppColors.error;
      case 2:         return AppColors.warning;
      case 3:         return Colors.yellow.shade700;
      default:        return AppColors.success;
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case 0: case 1: return 'Fraca';
      case 2:         return 'Razoável';
      case 3:         return 'Boa';
      default:        return 'Forte';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final error = await MockAuthService.instance.changePassword(
      _currentCtrl.text,
      _newCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(error, style: const TextStyle(fontSize: 15)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Sucesso
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 40)),
            const SizedBox(height: 20),
            Text('Senha alterada!',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Sua senha foi atualizada com sucesso.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  Navigator.pop(context); // fecha dialog
                  Navigator.pop(context); // volta ao perfil
                },
                child: const Text('OK', style: AppTextStyles.buttonMedium)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alterar Senha'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Ícone ilustrativo
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('Crie uma senha segura',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Use pelo menos 8 caracteres com letras maiúsculas,\nnúmeros e símbolos.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // ── Senha atual ──────────────────────────────────
            _buildCard(children: [
              _FieldLabel('Senha atual'),
              TextFormField(
                controller: _currentCtrl,
                obscureText: !_showCurrent,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Digite sua senha atual',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint, size: 20),
                    onPressed: () =>
                        setState(() => _showCurrent = !_showCurrent),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a senha atual';
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 16),

            // ── Nova senha ───────────────────────────────────
            _buildCard(children: [
              _FieldLabel('Nova senha'),
              TextFormField(
                controller: _newCtrl,
                obscureText: !_showNew,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  prefixIcon: const Icon(Icons.lock_reset_rounded,
                    color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint, size: 20),
                    onPressed: () =>
                        setState(() => _showNew = !_showNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a nova senha';
                  if (v.length < 8) return 'Mínimo 8 caracteres';
                  if (_strength < 2) return 'Senha muito fraca';
                  if (v == _currentCtrl.text) {
                    return 'A nova senha deve ser diferente da atual';
                  }
                  return null;
                },
              ),

              // Indicador de força
              if (_newCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: List.generate(4, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i < _strength
                          ? _strengthColor
                          : AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(2)),
                  ),
                ))),
                const SizedBox(height: 6),
                Row(children: [
                  Text('Força: ', style: AppTextStyles.bodySmall),
                  Text(_strengthLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _strengthColor, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  if (_strength < 4)
                    Expanded(
                      child: Text('• maiúsc., números e símbolos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint),
                        overflow: TextOverflow.ellipsis)),
                ]),
              ],

              const SizedBox(height: 16),
              _FieldLabel('Confirmar nova senha'),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: !_showConfirm,
                style: AppTextStyles.inputText,
                textInputAction: TextInputAction.done,
                onEditingComplete: _save,
                decoration: InputDecoration(
                  hintText: 'Repita a nova senha',
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint, size: 20),
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirme a nova senha';
                  if (v != _newCtrl.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 32),

            // ── Botão ────────────────────────────────────────
            SizedBox(
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                    : Text('Alterar senha', style: AppTextStyles.buttonLarge),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.inputLabel),
  );
}