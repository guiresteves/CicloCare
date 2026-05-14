import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  ONBOARDING SCREEN — CicloCare
//  Arquivo: lib/features/auth/onboarding_screen.dart
// ════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ── ESTADO LOCAL ─────────────────────────────────────────
  // Guarda qual botão está selecionado: 'cuidador', 'titular' ou null
  String? _selectedRole;

  // ── CORES DO APP (tema CicloCare) ────────────────────────
  static const Color _purple = Color(0xFF7C5CBF);
  static const Color _teal   = Color(0xFF3DB89E);
  static const Color _white  = Color(0xFFFFFFFF);
  static const Color _grey   = Color(0xFF6B7280);

  // ── BUILD: monta a tela ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor define a cor de fundo da tela inteira
      backgroundColor: _white,

      // SafeArea garante que o conteúdo não fique atrás da
      // barra de status ou do notch do celular
      body: SafeArea(
        child: Padding(
          // EdgeInsets.symmetric adiciona espaço horizontal (esquerda e direita)
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            // Column empilha os widgets um abaixo do outro
            // MainAxisAlignment.spaceBetween distribui o espaço entre eles
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── PARTE SUPERIOR: logo + texto ─────────────
              _buildTopSection(),

              // ── PARTE DO MEIO: botões de papel ───────────
              _buildRoleButtons(),

              // ── PARTE INFERIOR: botão "Não tenho conta" ──
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SEÇÃO 1 — Logo + título + subtítulo
  // ════════════════════════════════════════════════════════
  Widget _buildTopSection() {
    return Column(
      children: [
        // SizedBox é um espaço vazio (como margin/padding)
        const SizedBox(height: 48),

        // Logo: imagem do asset do projeto
        // Se ainda não tiver a imagem, use o widget de placeholder abaixo
        _buildLogo(),

        const SizedBox(height: 24),

        // RichText permite misturar estilos diferentes no mesmo texto
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ciclo',
                style: TextStyle(
                  fontFamily: 'Poppins',       // fonte personalizada
                  fontSize: 32,
                  fontWeight: FontWeight.w700,  // negrito
                  color: _teal,
                ),
              ),
              TextSpan(
                text: 'Care',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: _purple,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Text simples para o subtítulo
        Text(
          'Cuidado que conecta quem\nvocê ama à saúde que merece.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _grey,
            height: 1.5, // espaçamento entre linhas
          ),
        ),

        const SizedBox(height: 48),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  LOGO — usa imagem ou fallback com ícone
  // ════════════════════════════════════════════════════════
  Widget _buildLogo() {
    // Quando tiver o arquivo da logo, troque pelo Image.asset abaixo:
    // return Image.asset('assets/images/logo.png', height: 120);

    // Por enquanto, um placeholder com o símbolo de saúde
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        // gradient cria o degradê teal → purple
        gradient: const LinearGradient(
          colors: [_teal, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: _white,
        size: 56,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SEÇÃO 2 — Botões "Cuidador" e "Titular"
  // ════════════════════════════════════════════════════════
  Widget _buildRoleButtons() {
    return Column(
      children: [
        Text(
          'Como você vai usar o app?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          // Row coloca os widgets lado a lado (horizontal)
          children: [
            // Expanded faz o botão ocupar metade da linha
            Expanded(
              child: _buildRoleButton(
                label: 'Cuidador',
                role: 'cuidador',
                // Se 'cuidador' está selecionado, usa roxo preenchido
                isSelected: _selectedRole == 'cuidador',
                color: _purple,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _buildRoleButton(
                label: 'Titular',
                role: 'titular',
                isSelected: _selectedRole == 'titular',
                color: _teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Botão individual de papel (Cuidador / Titular) ───────
  Widget _buildRoleButton({
    required String label,
    required String role,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      // GestureDetector detecta toques
      // onTap é chamado quando o usuário aperta o botão
      onTap: () {
        // setState avisa o Flutter que algo mudou
        // e manda redesenhar a tela com o novo estado
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        // AnimatedContainer anima a transição entre selecionado/não selecionado
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          // Se selecionado: fundo colorido. Se não: transparente com borda
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            // Texto branco se selecionado, colorido se não
            color: isSelected ? _white : color,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SEÇÃO 3 — Botão "Não tenho uma conta"
  // ════════════════════════════════════════════════════════
  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: SizedBox(
        // SizedBox com width: double.infinity faz o botão ocupar toda a largura
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Degradê horizontal do roxo para o teal
            gradient: const LinearGradient(
              colors: [_purple, _teal],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            // Remove a cor padrão do ElevatedButton para mostrar o gradient
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              // Aqui você vai navegar para a tela de cadastro
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => const RegisterScreen(),
              // ));
            },
            child: const Text(
              'Não tenho uma conta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}