import 'package:flutter/material.dart';

import '../models/app_styles.dart';
import '../models/emotion_type.dart';
import '../models/rhythm_entry.dart';

class WeeklyRhythmPainter extends CustomPainter {
  WeeklyRhythmPainter({required this.entries});

  final List<RhythmEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(24, size.height - 32),
      Offset(size.width - 24, size.height - 32),
      axisPaint,
    );

    if (entries.isEmpty) return;

    final recent = entries.take(7).toList().reversed.toList();
    final List<Offset> points = [];

    for (var i = 0; i < recent.length; i++) {
      final x = recent.length == 1
          ? size.width / 2
          : 24 + i * ((size.width - 48) / (recent.length - 1));
      final y =
          size.height - 32 - (recent[i].energy / 5.2) * (size.height - 64);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      final path = Path();
      final fillPath = Path();

      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, size.height - 32);
      fillPath.lineTo(points[0].dx, points[0].dy);

      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        fillPath.cubicTo(
          controlX1,
          controlY1,
          controlX2,
          controlY2,
          p1.dx,
          p1.dy,
        );
      }

      fillPath.lineTo(points.last.dx, size.height - 32);
      fillPath.close();

      // Curved gradient fill
      final fillGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withValues(alpha: 0.28),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

      final fillPaint = Paint()
        ..shader = fillGradient
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);

      // Main curved spline path
      final linePaint = Paint()
        ..color = AppColors.accentLight
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);

      // Render nodes with customized colors and shadow glow
      final dotPaint = Paint()..style = PaintingStyle.fill;
      final dotStroke = Paint()
        ..color = AppColors.surfaceAlt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        final eColor = EmotionMapping.color(recent[i].emotions);

        final glowPaint = Paint()
          ..color = eColor.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(p, 8.5, glowPaint);

        dotPaint.color = eColor;
        canvas.drawCircle(p, 5.5, dotPaint);
        canvas.drawCircle(p, 5.5, dotStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyRhythmPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
