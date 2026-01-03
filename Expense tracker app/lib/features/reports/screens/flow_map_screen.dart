import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lumina_finance/core/widgets/mesh_background.dart';

class FlowMapScreen extends StatefulWidget {
  const FlowMapScreen({super.key});

  @override
  State<FlowMapScreen> createState() => _FlowMapScreenState();
}

class _FlowMapScreenState extends State<FlowMapScreen> with SingleTickerProviderStateMixin {
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
    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Money Flow Map'),
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: FlowPainter(animationValue: _controller.value),
            );
          },
        ),
      ),
    );
  }
}

class FlowPainter extends CustomPainter {
  final double animationValue;
  FlowPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.1;
    final right = size.width * 0.9;
    final top = size.height * 0.2;
    final bottom = size.height * 0.8;

    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Source (Income)
    final source = Offset(left, size.height / 2);
    // Accounts
    final accounts = [
      Offset(size.width / 2, top),
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, bottom),
    ];
    // Sinks (Categories)
    final sinks = List.generate(5, (i) => Offset(right, top + (bottom - top) * (i / 4)));

    // Draw Paths and Particles
    for (var acc in accounts) {
      _drawAnimatedPath(canvas, source, acc, Colors.greenAccent);
      for (var sink in sinks) {
        _drawAnimatedPath(canvas, acc, sink, Colors.purpleAccent);
      }
    }

    // Draw Nodes
    _drawNode(canvas, source, 'Income', Colors.green);
    for (var acc in accounts) {
      _drawNode(canvas, acc, 'Account', Colors.blue);
    }
    for (var sink in sinks) {
      _drawNode(canvas, sink, 'Category', Colors.white30);
    }
  }

  void _drawAnimatedPath(Canvas canvas, Offset start, Offset end, Color color) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        (start.dx + end.dx) / 2, start.dy,
        (start.dx + end.dx) / 2, end.dy,
        end.dx, end.dy,
      );
    
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.1)..strokeWidth = 10..style = PaintingStyle.stroke);

    // Particles
    const particleCount = 5;
    for (var i = 0; i < particleCount; i++) {
      final t = (animationValue + (i / particleCount)) % 1.0;
      final pos = _getPathPoint(start, end, t);
      canvas.drawCircle(pos, 3, Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }
  }

  Offset _getPathPoint(Offset start, Offset end, double t) {
    final cx1 = (start.dx + end.dx) / 2;
    final cy1 = start.dy;
    final cx2 = (start.dx + end.dx) / 2;
    final cy2 = end.dy;

    final x = pow(1 - t, 3) * start.dx +
        3 * t * pow(1 - t, 2) * cx1 +
        3 * pow(t, 2) * (1 - t) * cx2 +
        pow(t, 3) * end.dx;
    final y = pow(1 - t, 3) * start.dy +
        3 * t * pow(1 - t, 2) * cy1 +
        3 * pow(t, 2) * (1 - t) * cy2 +
        pow(t, 3) * end.dy;
    return Offset(x, y);
  }

  void _drawNode(Canvas canvas, Offset pos, String label, Color color) {
    canvas.drawCircle(pos, 8, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos + const Offset(12, -5));
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => true;
}
