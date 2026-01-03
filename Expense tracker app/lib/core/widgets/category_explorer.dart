import 'dart:math';
import 'package:flutter/material.dart';

class CategoryExplorer extends StatefulWidget {
  final Map<String, double> categorySpending;
  const CategoryExplorer({super.key, required this.categorySpending});

  @override
  State<CategoryExplorer> createState() => _CategoryExplorerState();
}

class _CategoryExplorerState extends State<CategoryExplorer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _generateBubbles();
  }

  void _generateBubbles() {
    final random = Random();
    widget.categorySpending.forEach((name, amount) {
      _bubbles.add(Bubble(
        name: name,
        radius: (amount / 500).clamp(30, 80),
        position: Offset(random.nextDouble() * 300, random.nextDouble() * 300),
        color: Colors.primaries[random.nextInt(Colors.primaries.length)].withOpacity(0.4),
      ));
    });
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
          size: const Size(400, 400),
          painter: BubblePainter(bubbles: _bubbles, animationValue: _controller.value),
        );
      },
    );
  }
}

class Bubble {
  final String name;
  final double radius;
  Offset position;
  final Color color;

  Bubble({required this.name, required this.radius, required this.position, required this.color});
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double animationValue;

  BubblePainter({required this.bubbles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      // Floating movement
      final dy = sin(animationValue * 2 * pi + bubble.radius) * 10;
      final dx = cos(animationValue * 2 * pi + bubble.radius) * 10;
      
      final currentPos = bubble.position + Offset(dx, dy);

      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(currentPos, bubble.radius, paint);
      
      // Draw label
      final tp = TextPainter(
        text: TextSpan(
          text: bubble.name,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      tp.paint(canvas, currentPos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) => true;
}
