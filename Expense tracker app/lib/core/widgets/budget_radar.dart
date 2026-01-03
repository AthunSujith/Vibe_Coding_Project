import 'dart:math';
import 'package:flutter/material.dart';

class BudgetRadar extends StatefulWidget {
  final Map<String, double> categorySpending;
  const BudgetRadar({super.key, required this.categorySpending});

  @override
  State<BudgetRadar> createState() => _BudgetRadarState();
}

class _BudgetRadarState extends State<BudgetRadar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: RadarPainter(
            animationValue: _controller.value,
            data: widget.categorySpending,
          ),
        );
      },
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  final Map<String, double> data;

  RadarPainter({required this.animationValue, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw concentric rings
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // Draw sweep line
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.transparent, Colors.cyanAccent.withOpacity(0.5), Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Draw data points (polygonal radar)
    if (data.isNotEmpty) {
      final dataPaint = Paint()
        ..color = Colors.purpleAccent.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.purpleAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      final keys = data.keys.toList();
      final angleStep = (2 * pi) / keys.length;

      for (var i = 0; i < keys.length; i++) {
        final val = data[keys[i]]!;
        final normVal = (val / 10000).clamp(0.1, 1.0); // Simple normalization
        final angle = i * angleStep - pi / 2;
        final x = center.dx + radius * normVal * cos(angle);
        final y = center.dy + radius * normVal * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        
        // Draw labels
        _drawText(canvas, keys[i], Offset(x, y), center);
      }
      path.close();
      canvas.drawPath(path, dataPaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white70, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    
    // Offset slightly away from center
    final direction = (position - center);
    final offset = center + direction * 1.2;
    
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => true;
}
