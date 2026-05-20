import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
                    'Política de privacidade',
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
                      title: 'DADOS QUE COLETAMOS',
                      body:
                          'Nome, CPF, foto de perfil, número de telefone, endereço, localização em tempo real (durante atendimentos), dados de pagamento e imagens capturadas pela câmera (comprovantes e registros de visita).',
                    ),
                    _Section(
                      number: '2.',
                      title: 'PARA QUE USAMOS',
                      body:
                          'Seus dados são usados para: autenticar o acesso, conectar cuidadores e titulares, processar pagamentos, garantir a segurança dos atendimentos e cumprir obrigações legais.',
                    ),

                    // Card destaque verde
                    _HighlightCard(
                      text:
                          'Nunca vendemos seus dados a terceiros. Compartilhamos apenas com parceiros essenciais ao funcionamento do serviço (pagamentos, mapas e notificações).',
                    ),

                    _Section(
                      number: '3.',
                      title: 'LOCALIZAÇÃO',
                      body:
                          'A localização é coletada somente durante atendimentos ativos, para confirmar presença e garantir a segurança do titular. Você pode revogar essa permissão nas configurações do celular.',
                    ),
                    _Section(
                      number: '4.',
                      title: 'CÂMERA E FOTOS',
                      body:
                          'A câmera é usada para foto de perfil, envio de documentos e registros de visita. As imagens ficam armazenadas em servidores seguros e criptografados.',
                    ),
                    _Section(
                      number: '5.',
                      title: 'PAGAMENTOS',
                      body:
                          'Dados financeiros são processados por gateways certificados. O CicloCare não armazena números de cartão em seus servidores.',
                    ),
                    _Section(
                      number: '6.',
                      title: 'SEUS DIREITOS (LGPD)',
                      body:
                          'Você pode a qualquer momento: acessar seus dados, corrigir informações, solicitar a exclusão da conta e revogar o consentimento. Basta acessar "Minha conta" no app.',
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