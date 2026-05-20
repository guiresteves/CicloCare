import 'package:flutter/material.dart';

/// Logo da CicloCare — cruz com gradiente verde→roxo e folhas brancas,
/// fiel ao design do Figma.
class CicloCareLogo extends StatelessWidget {
  final double size;
  const CicloCareLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: CustomPaint(painter: _LogoPainter()));
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Cruz (gradiente verde → roxo diagonal) ──────────────────────────
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF3DBE8B), Color(0xFF9B59B6)],
    );

    final crossPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final armW = w * 0.30;
    final cx = w / 2;
    final cy = h / 2;
    final r = w * 0.13;

    final crossPath = Path();
    // Vertical
    _rRect(crossPath, Rect.fromLTWH(cx - armW / 2, 0, armW, h), r);
    // Horizontal
    _rRect(crossPath, Rect.fromLTWH(0, cy - armW / 2, w, armW), r);

    canvas.drawPath(crossPath, crossPaint);

    // ── Folhas brancas ───────────────────────────────────────────────────
    final leafPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Folha esquerda-baixo
    final l1 = Path();
    l1.moveTo(cx - w * 0.02, cy + h * 0.08);
    l1.cubicTo(
      cx - w * 0.22, cy + h * 0.02,
      cx - w * 0.22, cy - h * 0.14,
      cx - w * 0.06, cy - h * 0.16,
    );
    l1.cubicTo(
      cx + w * 0.04, cy - h * 0.08,
      cx + w * 0.04, cy + h * 0.04,
      cx - w * 0.02, cy + h * 0.08,
    );
    canvas.drawPath(l1, leafPaint);

    // Folha direita-cima
    final l2 = Path();
    l2.moveTo(cx + w * 0.04, cy - h * 0.00);
    l2.cubicTo(
      cx + w * 0.20, cy - h * 0.10,
      cx + w * 0.18, cy - h * 0.26,
      cx + w * 0.04, cy - h * 0.22,
    );
    l2.cubicTo(
      cx - w * 0.06, cy - h * 0.14,
      cx - w * 0.02, cy - h * 0.04,
      cx + w * 0.04, cy - h * 0.00,
    );
    canvas.drawPath(l2, leafPaint);
  }

  void _rRect(Path p, Rect r, double radius) =>
      p.addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)));

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
