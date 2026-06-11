import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_routes.dart';
import '../../auth/mock/mock_auth_service.dart';

// ════════════════════════════════════════════════════════════
//  PROFILE SCREEN
//  Arquivo: lib/features/profile/screens/profile_screen.dart
// ════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = MockAuthService.instance.loggedUser;

  bool _notifMedication = true;
  bool _notifExam       = true;
  bool _notifReminder   = false;

  @override
  Widget build(BuildContext context) {
    final name  = user?['name']  ?? 'Usuário';
    final email = user?['email'] ?? '';
    final initials = name.trim().split(' ')
        .take(2).map((w) => w[0].toUpperCase()).join();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header com avatar ────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
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
                      const SizedBox(height: 20),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white, width: 3)),
                            child: Center(
                              child: Text(initials,
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: AppColors.white))),
                          ),
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryLight, width: 2)),
                            child: const Icon(Icons.camera_alt_rounded,
                              color: AppColors.primary, size: 16)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(name,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Conteúdo ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Dados pessoais ─────────────────────────
                  _SectionCard(
                    title: 'Dados Pessoais',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _InfoTile(label: 'Nome',     value: name),
                      _InfoTile(label: 'E-mail',   value: email),
                      _InfoTile(label: 'Telefone', value: user?['phone'] ?? 'Não informado'),
                      _InfoTile(label: 'CPF',      value: user?['cpf']   ?? 'Não informado', isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Notificações ───────────────────────────
                  _SectionCard(
                    title: 'Notificações',
                    icon: Icons.notifications_outlined,
                    children: [
                      _SwitchTile(
                        label: 'Lembrete de medicamento',
                        subtitle: 'Aviso no horário de cada dose',
                        value: _notifMedication,
                        onChanged: (v) => setState(() => _notifMedication = v)),
                      _SwitchTile(
                        label: 'Lembrete de exame',
                        subtitle: 'Aviso 1 dia antes do exame',
                        value: _notifExam,
                        onChanged: (v) => setState(() => _notifExam = v)),
                      _SwitchTile(
                        label: 'Dose atrasada',
                        subtitle: 'Aviso quando esquecer uma dose',
                        value: _notifReminder,
                        onChanged: (v) => setState(() => _notifReminder = v),
                        isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Segurança ──────────────────────────────
                  _SectionCard(
                    title: 'Segurança',
                    icon: Icons.shield_outlined,
                    children: [
                      _ActionTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Alterar senha',
                        onTap: () {}),
                      _ActionTile(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometria',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8)),
                          child: Text('Ativo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success))),
                        onTap: () {}),
                      _ActionTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Política de privacidade',
                        onTap: () => Navigator.pushNamed(
                          context, AppRoutes.privacy),
                        isLast: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Suporte ────────────────────────────────
                  _SectionCard(
                    title: 'Suporte',
                    icon: Icons.help_outline_rounded,
                    children: [
                      _ActionTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Central de ajuda',
                        onTap: () {}),
                      _ActionTile(
                        icon: Icons.star_outline_rounded,
                        label: 'Avaliar o app',
                        onTap: () {}),
                      _ActionTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Sobre o CicloCare',
                        trailing: Text('v1.0.0',
                          style: AppTextStyles.bodySmall),
                        onTap: () {},
                        isLast: true),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Logout ─────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 54,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: Text('Sair da conta',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.error)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              MockAuthService.instance.logout();
              Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.onboarding, (_) => false);
            },
            child: const Text('Sair',
              style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
      ]),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider)),
        child: Column(children: children),
      ),
    ],
  );
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final bool isLast;
  const _InfoTile({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Flexible(child: Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary),
              textAlign: TextAlign.right)),
          ],
        ),
      ),
      if (!isLast) const Divider(height: 1, indent: 18, endIndent: 18),
    ],
  );
}

class _SwitchTile extends StatelessWidget {
  final String label, subtitle;
  final bool value, isLast;
  final Function(bool) onChanged;

  const _SwitchTile({
    required this.label, required this.subtitle,
    required this.value, required this.onChanged, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppTextStyles.labelLarge),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ])),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged),
        ]),
      ),
      if (!isLast) const Divider(height: 1, indent: 18, endIndent: 18),
    ],
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionTile({
    required this.icon, required this.label,
    required this.onTap, this.trailing, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(label, style: AppTextStyles.labelLarge),
        trailing: trailing ?? const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textHint, size: 22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        minLeadingWidth: 0,
      ),
      if (!isLast) const Divider(height: 1, indent: 18, endIndent: 18),
    ],
  );
}
