import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
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
                  const Text(
                    'Termo e condições',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Conteúdo ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      number: '1.',
                      title: 'SOBRE O CICLOCARE',
                      body:
                          'O CicloCare é uma plataforma que conecta cuidadores profissionais a titulares (idosos ou responsáveis legais), facilitando o agendamento, acompanhamento e pagamento de serviços de cuidado.',
                    ),
                    _Section(
                      number: '2.',
                      title: 'CADASTRO E PERFIS',
                      body:
                          'O app possui dois tipos de perfil: Cuidador e Titular. O usuário é responsável pela veracidade das informações cadastradas. É proibido criar perfis falsos ou usar dados de terceiros sem autorização.',
                    ),
                    _Section(
                      number: '3.',
                      title: 'RESPONSABILIDADES DO CUIDADOR',
                      body:
                          'O app possui dois tipos de perfil: Cuidador e Titular. O usuário é responsável pela veracidade das informações cadastradas. É proibido criar perfis falsos ou usar dados de terceiros sem autorização.',
                    ),

                    // Card destaque verde
                    _HighlightCard(
                      text:
                          'O CicloCare não é uma empresa de emprego. Atuamos como plataforma intermediária. A relação entre cuidador e titular é autônoma.',
                    ),
                    const SizedBox(height: 4),

                    _Section(
                      number: '4.',
                      title: 'PAGAMENTOS',
                      body:
                          'Os pagamentos são processados de forma segura por meio de parceiros homologados. O CicloCare pode reter uma taxa de serviço sobre cada transação realizada na plataforma.',
                    ),
                    _Section(
                      number: '5.',
                      title: 'CANCELAMENTOS',
                      body:
                          'Cancelamentos com menos de 24h de antecedência podem gerar cobrança de taxa. As condições detalhadas estão disponíveis na central de ajuda do app.',
                    ),
                    _Section(
                      number: '6.',
                      title: 'CONDUTA E SUSPENSÃO',
                      body:
                          'Comportamentos inadequados, denúncias graves ou uso indevido da plataforma podem resultar em suspensão ou exclusão permanente da conta, a critério do CicloCare.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _Section({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número + título
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Parágrafo
          Text(
            body,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String text;
  const _HighlightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E7A52),
          fontWeight: FontWeight.w500,
          height: 1.55,
        ),
      ),
    );
  }
}