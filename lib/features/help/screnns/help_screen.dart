import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ════════════════════════════════════════════════════════════
//  HELP SCREEN — CicloCare
//  Arquivo: lib/features/help/screens/help_screen.dart
// ════════════════════════════════════════════════════════════

class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;
  bool isExpanded;

  _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
    this.isExpanded = false,
  });
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      icon: Icons.medication_rounded,
      question: 'Como cadastrar um medicamento?',
      answer:
          'Toque na aba "Remédios" na barra inferior. Em seguida, toque no botão verde "Adicionar" no canto inferior direito. Preencha o nome do medicamento, a dosagem, a frequência e os horários. Por fim, toque em "Adicionar medicamento" para salvar.',
    ),
    _FaqItem(
      icon: Icons.science_rounded,
      question: 'Como agendar um exame ou consulta?',
      answer:
          'Toque na aba "Exames" na barra inferior. Toque no botão "Agendar" no canto inferior direito. Escolha o tipo (Exame ou Consulta), preencha o nome, selecione a data e o horário. Adicione o local e o médico se quiser. Por fim, toque em "Agendar Exame" para salvar.',
    ),
    _FaqItem(
      icon: Icons.check_circle_outline_rounded,
      question: 'Como marcar uma atividade como concluída?',
      answer:
          'Na tela de Início, toque no card do medicamento, exame ou consulta que deseja concluir. Um menu aparecerá com as opções disponíveis. Para medicamentos, toque em "Tomado". Para exames, toque em "Realizado". Para consultas, toque em "Compareci". A atividade será registrada automaticamente no histórico.',
    ),
    _FaqItem(
      icon: Icons.person_outline_rounded,
      question: 'Como editar meus dados pessoais?',
      answer:
          'Toque na aba "Perfil" na barra inferior. Toque em "Editar" no canto superior direito ou no botão "Editar" na seção "Dados Pessoais". Atualize as informações desejadas e toque em "Salvar alterações".',
    ),
    _FaqItem(
      icon: Icons.lock_outline_rounded,
      question: 'Como alterar minha senha?',
      answer:
          'Toque na aba "Perfil" na barra inferior. Role a tela até a seção "Segurança". Toque em "Alterar senha". Digite sua senha atual e depois a nova senha duas vezes. Toque em "Alterar senha" para confirmar.',
    ),
    _FaqItem(
      icon: Icons.edit_outlined,
      question: 'Como editar ou remover um medicamento?',
      answer:
          'Toque na aba "Remédios". Encontre o medicamento desejado na lista. Toque em "Editar" para alterar as informações ou em "Excluir" para removê-lo. Confirme a ação quando solicitado.',
    ),
    _FaqItem(
      icon: Icons.history_rounded,
      question: 'Como ver meu histórico de atividades?',
      answer:
          'Toque na aba "Histórico" na barra inferior. Você verá todas as atividades registradas organizadas por data. Use os filtros na parte superior para ver apenas medicamentos ou exames, e para escolher o período desejado.',
    ),
    _FaqItem(
      icon: Icons.notifications_outlined,
      question: 'Como funcionam as notificações?',
      answer:
          'O CicloCare registra automaticamente todas as suas ações em notificações. Para visualizá-las, toque no ícone de sino na tela de Início. As notificações são organizadas por Hoje, Ontem e Anteriores. Toque em uma notificação para marcá-la como lida.',
    ),
    _FaqItem(
      icon: Icons.logout_rounded,
      question: 'Como sair da minha conta?',
      answer:
          'Toque na aba "Perfil" na barra inferior. Role até o final da página e toque em "Sair da conta". Confirme tocando em "Sair" na janela de confirmação.',
    ),
    _FaqItem(
      icon: Icons.delete_outline_rounded,
      question: 'Como excluir minha conta?',
      answer:
          'Toque na aba "Perfil" na barra inferior. Role até a seção "Conta". Toque em "Excluir conta". Leia o aviso com atenção — todos os seus dados serão apagados permanentemente. Confirme tocando em "Excluir Conta".',
    ),
  ];

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
        title: const Text('Central de Ajuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header ilustrativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.help_outline_rounded,
                  color: Colors.white, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como podemos ajudar?',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toque em uma pergunta para ver a resposta.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          Text('Perguntas Frequentes',
              style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),

          // FAQ items
          ...List.generate(_faqs.length, (i) => _buildFaqItem(i)),

          const SizedBox(height: 32),

          // Card de contato
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(children: [
              const Icon(Icons.support_agent_rounded,
                  color: AppColors.primary, size: 40),
              const SizedBox(height: 12),
              Text(
                'Não encontrou o que procura?',
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nossa equipe está disponível para ajudá-lo.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'suporte@ciclocare.com.br',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = _faqs[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: faq.isExpanded
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
          width: faq.isExpanded ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(children: [
          // Cabeçalho clicável
          InkWell(
            onTap: () => setState(() => faq.isExpanded = !faq.isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: faq.isExpanded
                        ? AppColors.primaryLight
                        : AppColors.inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    faq.icon,
                    color: faq.isExpanded
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    faq.question,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: faq.isExpanded
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: faq.isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: faq.isExpanded
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 26,
                  ),
                ),
              ]),
            ),
          ),

          // Resposta expandida
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(children: [
                const Divider(height: 1),
                const SizedBox(height: 14),
                Text(
                  faq.answer,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ]),
            ),
            crossFadeState: faq.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ]),
      ),
    );
  }
}
