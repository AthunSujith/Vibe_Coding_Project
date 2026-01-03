import 'dart:math';
import 'package:flutter/material.dart';

class MeshBackground extends StatefulWidget {
  final Widget child;
  const MeshBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: MeshPainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

class MeshPainter extends CustomPainter {
  final double animationValue;
  MeshPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Draw base background
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0F0C29));

    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Dynamic blobs
    _drawBlob(canvas, size, const Color(0xFF9D50BB), 0.2, 0.3, 0.4);
    _drawBlob(canvas, size, const Color(0xFF6E48AA), 0.8, 0.7, 0.5);
    _drawBlob(canvas, size, const Color(0xFF2193B0), 0.5, 0.2, 0.3);
    _drawBlob(canvas, size, const Color(0xFF6dd5ed), 0.3, 0.8, 0.4);
  }

  void _drawBlob(Canvas canvas, Size size, Color color, double xFactor, double yFactor, double sizeFactor) {
    final dx = size.width * (xFactor + 0.1 * sin(animationValue * 2 * pi + xFactor * 10));
    final dy = size.height * (yFactor + 0.1 * cos(animationValue * 2 * pi + yFactor * 10));
    final radius = size.width * (sizeFactor + 0.05 * sin(animationValue * 2 * pi));

    canvas.drawCircle(
      Offset(dx, dy),
      radius,
      Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );
  }

  @override
  bool shouldRepaint(covariant MeshPainter oldDelegate) => true;
}
