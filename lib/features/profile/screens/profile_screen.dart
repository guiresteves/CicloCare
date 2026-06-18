import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/mock/mock_auth_service.dart';
import '../../auth/screens/change_password_screen.dart';
import '../../help/screnns/help_screen.dart';

// ════════════════════════════════════════════════════════════
//  PROFILE SCREEN — CicloCare
//  Arquivo: lib/features/profile/screens/profile_screen.dart
// ════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifMed     = true;
  bool _notifExam    = true;
  bool _notifOverdue = false;

  Map<String, String> get _user =>
      MockAuthService.instance.loggedUser ?? {};

  String get _initials {
    final name = _user['name'] ?? '';
    final words = name.trim().split(' ');
    return words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        user: _user,
        onSaved: () => setState(() {}),
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text('Tem certeza que deseja sair?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              MockAuthService.instance.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.onboarding, (_) => false);
            },
            child: const Text('Sair',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ── Excluir conta ────────────────────────────────────────
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir conta',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir sua conta?',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todos os seus dados serão removidos permanentemente e não poderão ser recuperados.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              MockAuthService.instance.deleteAccount();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.onboarding, (_) => false);
            },
            child: const Text('Excluir Conta',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name  = _user['name']      ?? 'Usuário';
    final email = _user['email']     ?? '';
    final phone = _user['phone']     ?? 'Não informado';
    final birth = _user['birthDate'] ?? 'Não informado';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header com avatar ────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(alignment: Alignment.bottomRight, children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white, width: 3),
                          ),
                          child: Center(
                            child: Text(_initials,
                                style: AppTextStyles.displayMedium
                                    .copyWith(color: AppColors.white)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Foto mockada — funcionalidade em breve'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primaryLight,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: AppColors.primary, size: 16),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Text(name,
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(email,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  AppColors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.white, size: 18),
                label: const Text('Editar',
                    style:
                        TextStyle(color: AppColors.white, fontSize: 15)),
              ),
            ],
          ),

          // ── Conteúdo ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [

                // Dados pessoais
                _SectionCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Dados Pessoais',
                  trailing: GestureDetector(
                    onTap: _openEditProfile,
                    child: Text('Editar',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                  children: [
                    _InfoRow(label: 'Nome', value: name),
                    _InfoRow(label: 'E-mail', value: email),
                    _InfoRow(label: 'Telefone', value: phone),
                    _InfoRow(
                        label: 'Nascimento',
                        value: birth,
                        isLast: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Notificações
                _SectionCard(
                  icon: Icons.notifications_outlined,
                  title: 'Notificações',
                  children: [
                    _SwitchRow(
                        label: 'Lembrete de remédio',
                        subtitle: 'Aviso no horário de cada dose',
                        value: _notifMed,
                        onChanged: (v) =>
                            setState(() => _notifMed = v)),
                    _SwitchRow(
                        label: 'Lembrete de exame',
                        subtitle: '1 dia antes do exame',
                        value: _notifExam,
                        onChanged: (v) =>
                            setState(() => _notifExam = v)),
                    _SwitchRow(
                        label: 'Dose atrasada',
                        subtitle: 'Aviso quando esquecer uma dose',
                        value: _notifOverdue,
                        onChanged: (v) =>
                            setState(() => _notifOverdue = v),
                        isLast: true),
                  ],
                ),
                const SizedBox(height: 16),

                // Segurança
                _SectionCard(
                  icon: Icons.shield_outlined,
                  title: 'Segurança',
                  children: [
                    _ActionRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Alterar senha',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const ChangePasswordScreen()),
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Biometria',
                      trailing: _badge('Ativo', AppColors.success,
                          AppColors.successLight),
                      onTap: () {},
                    ),
                    _ActionRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Política de privacidade',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.privacy),
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Suporte
                _SectionCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Suporte',
                  children: [
                    _ActionRow(
                      icon: Icons.help_outline_rounded,
                      label: 'Central de ajuda',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HelpScreen()),
                      ),
                    ),
                    _ActionRow(
                      icon: Icons.star_outline_rounded,
                      label: 'Avaliar o CicloCare',
                      onTap: () {},
                    ),
                    _ActionRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Sobre o app',
                      trailing: Text('v1.0.0',
                          style: AppTextStyles.bodySmall),
                      onTap: () {},
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Conta
                _SectionCard(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Conta',
                  children: [
                    _ActionRow(
                      icon: Icons.delete_forever_outlined,
                      label: 'Excluir conta',
                      labelColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: _confirmDeleteAccount,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity, height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                          color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: Text('Sair da conta',
                        style: AppTextStyles.buttonMedium
                            .copyWith(color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}

// ════════════════════════════════════════════════════════════
//  EDIT PROFILE SHEET
// ════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatefulWidget {
  final Map<String, String> user;
  final VoidCallback onSaved;
  const _EditProfileSheet(
      {required this.user, required this.onSaved});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.user['name']      ?? '');
    _emailCtrl = TextEditingController(text: widget.user['email']     ?? '');
    _phoneCtrl = TextEditingController(text: widget.user['phone']     ?? '');
    _birthCtrl = TextEditingController(text: widget.user['birthDate'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    MockAuthService.instance.updateProfile(
      name:      _nameCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      birthDate: _birthCtrl.text.trim(),
    );

    widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
        SizedBox(width: 10),
        Text('Perfil atualizado!',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44, height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16)),
              ),
              Text('Editar Perfil', style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: Text('Salvar',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primary)),
              ),
            ]),
            const SizedBox(height: 24),
            _field('Nome completo', _nameCtrl,
                icon: Icons.person_outline_rounded, hint: 'Seu nome'),
            const SizedBox(height: 16),
            _field('E-mail', _emailCtrl,
                icon: Icons.email_outlined,
                hint: 'seu@email.com',
                type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _field('Telefone', _phoneCtrl,
                icon: Icons.phone_outlined,
                hint: '(00) 00000-0000',
                type: TextInputType.phone),
            const SizedBox(height: 16),
            _field('Data de nascimento', _birthCtrl,
                icon: Icons.cake_outlined,
                hint: 'DD/MM/AAAA',
                type: TextInputType.datetime),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppColors.primaryMedium,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Salvar alterações',
                        style: AppTextStyles.buttonLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    required IconData icon,
    required String hint,
    TextInputType type = TextInputType.text,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
          ),
        ),
      ]);
}

// ════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.sectionTitle),
            const Spacer(),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isLast;
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              Flexible(
                child: Text(value,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 18, endIndent: 18),
      ]);
}

class _SwitchRow extends StatelessWidget {
  final String label, subtitle;
  final bool value, isLast;
  final Function(bool) onChanged;
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Switch(
                value: value,
                activeColor: AppColors.primary,
                onChanged: onChanged),
          ]),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 18, endIndent: 18),
      ]);
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18),
          leading: Icon(icon,
              color: iconColor ?? AppColors.primary, size: 22),
          title: Text(label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: labelColor ?? AppColors.textPrimary)),
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint, size: 22),
          minLeadingWidth: 0,
        ),
        if (!isLast)
          const Divider(height: 1, indent: 18, endIndent: 18),
      ]);
}
