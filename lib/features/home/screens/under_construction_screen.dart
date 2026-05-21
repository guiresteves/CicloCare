import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  UNDER CONSTRUCTION SCREEN — CicloCare
//  Arquivo: lib/features/placeholder/screens/under_construction_screen.dart
//
//  Tela genérica de "em desenvolvimento" reutilizável.
//  Basta passar o nome e ícone da seção.
// ════════════════════════════════════════════════════════════

class UnderConstructionScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const UnderConstructionScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  static const Color _green     = Color(0xFF2DA87A);
  static const Color _greenLight= Color(0xFFE8F8F2);
  static const Color _textDark  = Color(0xFF111827);
  static const Color _textGrey  = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone da seção dentro de círculo verde claro
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: _greenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 52, color: _green),
              ),

              const SizedBox(height: 32),

              // Ícone de ferramentas
              const Text('🚧', style: TextStyle(fontSize: 36)),

              const SizedBox(height: 16),

              // Título
              const Text(
                'Em desenvolvimento',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),

              const SizedBox(height: 12),

              // Descrição
              Text(
                'A seção "$title" ainda está sendo construída.\nEm breve estará disponível para você!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: _textGrey,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // Badge de versão
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _green.withOpacity(0.3)),
                ),
                child: const Text(
                  'Versão 1.0 — Em breve',
                  style: TextStyle(
                    color: _green,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}