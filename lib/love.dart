import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:math' as math;

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

class LoveWidget extends StatefulWidget {
  const LoveWidget({Key? key}) : super(key: key);

  @override
  State<LoveWidget> createState() => _LoveWidgetState();
}

class _LoveWidgetState extends State<LoveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        value: 0,
        vsync: this,
        duration: const Duration(minutes: 30),
        upperBound: 30 * 60);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.black),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => CustomPaint(
          painter: LovePainter(_animationController.value),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class LovePainter extends CustomPainter {
  final framePointNumber = 100;
  final scale = 10;
  final scale2 = 9.5;

  final fillTimes = 5;

  double tick;
  LovePainter(this.tick);

  // x = 16sin^3(t)
  // y = 13cos(t) - 5cos(2t) - 2 cos(3t) - cos(4t)
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = Color.fromARGB(255, 254, 137, 176)
          .withOpacity(0.9 - (0.3) * math.sin(tick).abs())
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    drawHeart(pen, canvas, size, 0.001);
    for (var time = 0; time < fillTimes; time++) {
      drawHeart(pen, canvas, size, -0.2);
      drawHeart(pen, canvas, size, -0.05);
      drawHeart(pen, canvas, size, 0.05);
      drawHeart(pen, canvas, size, 0.1);
      drawHeart(pen, canvas, size, 0.3);
    }

    final text = TextPainter(
        text: TextSpan(
          text: "JT & HQ",
          style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 200, 105, 136)
                  .withOpacity(0.1 + (0.8) * math.sin(tick).abs())),
        ),
        textDirection: TextDirection.ltr,
        textScaleFactor: 1 + (0.5) * math.sin(tick).abs());
    text.layout();
    final xCenter = (size.width - text.width) / 2;
    final yCenter = (size.height - text.height) / 2;
    text.paint(canvas, Offset(xCenter, yCenter));
  }

  double getX(double w) {
    return math.pow(math.sin(w), 3) * 16;
  }

  double getY(double w) {
    return 13 * math.cos(w) -
        5 * math.cos(2 * w) -
        2 * math.cos(3 * w) -
        math.cos(4 * w);
  }

  void drawHeart(Paint pen, Canvas canvas, Size size, double shiftRate) {
    final center = Offset(size.width / 2, size.height / 2);
    final gap = 1.0 / framePointNumber;
    final points = List<Offset>.empty(growable: true);
    for (double i = 0.0; i < 2 * math.pi; i += gap) {
      var x = -getX(i) * scale;
      var y = -getY(i) * scale;
      x += (x - center.dx) * math.log(math.Random().nextDouble()) * shiftRate;
      if (x.abs() > 0.6) {
        y += (y - center.dy) * math.log(math.Random().nextDouble()) * shiftRate;
      }
      

      var offset = Offset(x, y);
      offset = transform(offset, canvas, size);
      // random
      points.add(offset);
    }
    canvas.drawPoints(PointMode.points, points, pen);
  }

  Offset transform(Offset offset, Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var x = offset.dx;
    var y = offset.dy;
    x -= center.dx;
    y -= center.dy;

    var distance = x * x + y * y;

    var offsetX = x * 0.7;
    var offsetY = y * 0.7;

    x *= 0.05 * math.log(distance) * math.sin(tick % math.pi);
    y *= 0.05 * math.log(distance) * math.sin(tick % math.pi);

    return Offset(center.dx + offsetX + x, center.dy + offsetY + y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return tick != (oldDelegate as LovePainter).tick;
  }
}
