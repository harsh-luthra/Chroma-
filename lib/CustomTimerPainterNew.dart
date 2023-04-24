import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomTimerPainterNew extends CustomPainter {
  CustomTimerPainterNew(
      {this.animation,
        this.neumorphicEffect = true,
        this.backgroundColor,
        this.innerFillColor,
        this.innerFillGradient,
        this.neonColor,
        this.neonGradient,
        this.innerStrokeWidth,
        this.outerStrokeWidth,
        this.strokeCap,
        required this.neon,
        this.outerStrokeColor,
        this.outerStrokeGradient})
      : super(repaint: animation);

  final double? neon;
  final Animation<double>? animation;
  final bool neumorphicEffect;
  final Color? innerFillColor, neonColor, outerStrokeColor, backgroundColor;
  final double? innerStrokeWidth;
  final double? outerStrokeWidth;
  final StrokeCap? strokeCap;
  final Gradient? innerFillGradient, neonGradient, outerStrokeGradient;

  @override
  void paint(Canvas canvas, Size size) {
    Paint blurPaint = Paint()
      ..color = neonColor!
      ..strokeWidth = innerStrokeWidth!
      ..strokeCap = strokeCap!
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, neon!)
      ..style = PaintingStyle.stroke;
    Paint strokePaint = Paint()
      ..color = neonColor!.withOpacity(0.8)
      ..strokeWidth = innerStrokeWidth!
      ..strokeCap = strokeCap!
      ..style = PaintingStyle.stroke;

    Paint neumorphicPaint = Paint();
    Paint innerPaint = Paint();
    Paint backgroundPaint = Paint();
    if (neumorphicEffect) {
      neumorphicPaint
        ..color = outerStrokeColor!
        ..strokeWidth = outerStrokeWidth!
        ..strokeCap = strokeCap!
        ..style = PaintingStyle.stroke;
      innerPaint
        ..color = innerFillColor!
        ..strokeWidth = innerStrokeWidth!
        ..strokeCap = strokeCap!
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.inner, 4);
      backgroundPaint
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
    }

    if (neonGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      blurPaint..shader = neonGradient!.createShader(rect);
    } else {
      blurPaint..shader = null;
    }

    double progress = (animation!.value) * 2 * math.pi;

    if (innerFillGradient != null) {
      final rect = Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2);
      strokePaint..shader = innerFillGradient!.createShader(rect);
    } else {
      strokePaint..shader = null;
      strokePaint.color = innerFillColor!;
    }
    Path path = Path();

    path.addArc(Offset.zero & size, math.pi * 2.5, progress);

    Path path_1 = Path()..addArc(Offset.zero & size, 0, math.pi * 2);
    if (neumorphicEffect) {
      canvas.drawShadow(path_1, Colors.black54, 2, true);
      canvas.drawPath(path_1, neumorphicPaint);
      canvas.drawPath(path_1, innerPaint);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          size.width / 2 - innerStrokeWidth! + 2, backgroundPaint);
    }

    canvas.drawPath(path, strokePaint);
    canvas.drawPath(path, blurPaint);
  }

  @override
  bool shouldRepaint(CustomTimerPainterNew old) {
    return animation!.value != old.animation!.value ||
        neonColor != old.neonColor ||
        innerFillColor != old.innerFillColor;
  }
}