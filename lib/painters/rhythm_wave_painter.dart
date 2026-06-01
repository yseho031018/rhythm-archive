import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_styles.dart';
import '../models/emotion_type.dart';
import '../models/rhythm_entry.dart';

class RhythmWavePainter extends CustomPainter {
  RhythmWavePainter({
    required this.progress,
    required this.entry,
    required this.previewEnergy,
    required this.previewEmotions,
    required this.touchPoint,
    required this.touchStart,
  });

  final double progress;
  final RhythmEntry? entry;
  final int previewEnergy;
  final Set<String> previewEmotions;
  final Offset? touchPoint;
  final double touchStart;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final emotions = entry?.emotions ?? previewEmotions.toList();
    final baseColor = EmotionMapping.color(emotions);
    final energy = entry?.energy ?? previewEnergy;
    final config = _fusedWaveConfigFor(emotions, energy);

    _paintBackground(canvas, rect, baseColor);
    _paintGrid(canvas, size);

    _paintWave(
      canvas: canvas,
      size: size,
      config: config,
      baseline: size.height * 0.52,
      phase: progress * pi * 2 * (config.speed / 7.0),
      glow: true,
    );

    _paintTouchPulse(canvas, baseColor);
    _paintHeader(canvas, size, energy, emotions);
  }

  void _paintBackground(Canvas canvas, Rect rect, Color baseColor) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF030607),
          Color.lerp(baseColor, const Color(0xFF071314), 0.86)!,
          const Color(0xFF080B0C),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.15),
        radius: 0.95,
        colors: [
          baseColor.withValues(alpha: 0.22),
          AppColors.accent.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, glow);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    final strongPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.11)
      ..strokeWidth = 1.2;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(22, y), Offset(size.width - 18, y), gridPaint);
    }
    for (var i = 1; i < 7; i++) {
      final x = size.width * i / 7;
      canvas.drawLine(Offset(x, 56), Offset(x, size.height - 28), gridPaint);
    }

    final mid = size.height * 0.52;
    canvas.drawLine(Offset(20, mid), Offset(size.width - 18, mid), strongPaint);
  }

  void _paintWave({
    required Canvas canvas,
    required Size size,
    required WaveConfig config,
    required double baseline,
    required double phase,
    required bool glow,
  }) {
    final path = Path();
    final fillPath = Path()..moveTo(0, size.height);
    final color = config.colors.first;
    final amplitude = config.amplitude.clamp(14.0, 76.0);

    const step = 5.0;
    for (double x = 0; x <= size.width + step; x += step) {
      final normalized = x / size.width;
      final y = _sampleEmotionWave(
        normalized: normalized,
        baseline: baseline,
        amplitude: amplitude,
        phase: phase,
        config: config,
      );
      if (x == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    if (glow) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.20), Colors.transparent],
        ).createShader(Offset.zero & size);
      canvas.drawPath(fillPath, fillPaint);
    }

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(path, glowPaint);
    }

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: config.colors.map((c) => c.withValues(alpha: 0.94)).toList(),
      ).createShader(Offset.zero & size)
      ..blendMode = config.blendMode
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  double _sampleEmotionWave({
    required double normalized,
    required double baseline,
    required double amplitude,
    required double phase,
    required WaveConfig config,
  }) {
    final sine = sin(normalized * pi * 2 * config.frequency + phase);
    final overtone = sin(
      normalized * pi * 2 * (config.frequency * 0.5) - phase * 0.7,
    );
    final noise = _valueNoise(normalized * 10 + phase * 0.23);
    final jag =
        (sin(normalized * pi * 2 * config.frequency * 3 + phase) >= 0
            ? 1.0
            : -1.0) *
        (0.35 + noise.abs() * 0.65);

    var shape = sine * config.smoothness + jag * (1 - config.smoothness);
    shape += overtone * 0.22;
    shape += noise * config.chaos;

    switch (config.type) {
      case EmotionType.anxious:
        shape += _sharpSpike(normalized, phase) * config.chaos;
      case EmotionType.achievement:
        shape += normalized * 0.7 - 0.35;
      case EmotionType.focused:
        shape =
            sin(normalized * pi * 2 * config.frequency + phase) * 0.78 +
            sin(normalized * pi * 4 * config.frequency + phase * 0.5) * 0.12;
      case EmotionType.calm:
        shape = sine * 0.86 + overtone * 0.12;
      case EmotionType.tired:
        shape = sine * 0.52 + overtone * 0.08 - normalized * 0.18;
      case EmotionType.joyful:
        shape += sin(normalized * pi * 10 + phase * 1.8) * 0.13;
    }

    return baseline - config.rise * normalized + shape * amplitude;
  }

  double _sharpSpike(double normalized, double phase) {
    final moving = (normalized * 5.0 + phase / (pi * 2)) % 1.0;
    final spike = 1 - (moving - 0.5).abs() * 2;
    return pow(max(0, spike), 6).toDouble() * 1.7;
  }

  double _valueNoise(double value) {
    final left = value.floorToDouble();
    final right = left + 1;
    final t = value - left;
    final smoothT = t * t * (3 - 2 * t);
    return _hashNoise(left) * (1 - smoothT) + _hashNoise(right) * smoothT;
  }

  double _hashNoise(double value) {
    final hash = sin(value * 127.1 + 311.7) * 43758.5453;
    return (hash - hash.floorToDouble()) * 2 - 1;
  }

  void _paintTouchPulse(Canvas canvas, Color baseColor) {
    final point = touchPoint;
    if (point == null) return;
    final age = progress - touchStart;
    if (age > 0.45) return;

    final t = (age / 0.45).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = baseColor.withValues(alpha: (1 - t) * 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1 - t)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(point, 28 + 130 * t, paint);
  }

  void _paintHeader(
    Canvas canvas,
    Size size,
    int energy,
    List<String> emotions,
  ) {
    final title = TextPainter(
      text: TextSpan(
        text: 'Energy $energy  ·  ${emotions.join('  /  ')}',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    title.paint(canvas, const Offset(22, 22));

    final caption = TextPainter(
      text: TextSpan(
        text: '감정 파동 그래프',
        style: TextStyle(
          color: AppColors.textGold.withValues(alpha: 0.82),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 48);
    caption.paint(canvas, const Offset(22, 45));
  }

  WaveConfig _fusedWaveConfigFor(List<String> emotions, int energy) {
    final source = emotions.isEmpty ? ['평온'] : emotions;
    final configs = source
        .take(4)
        .map(
          (emotion) =>
              WaveBehavior.configFor(emotion).scaledByEnergy(energy, 0),
        )
        .toList();
    final count = configs.length;

    double average(double Function(WaveConfig config) pick) {
      return configs.map(pick).reduce((a, b) => a + b) / count;
    }

    final dominantType =
        configs.any((config) => config.type == EmotionType.anxious)
        ? EmotionType.anxious
        : configs.any((config) => config.type == EmotionType.achievement)
        ? EmotionType.achievement
        : configs.any((config) => config.type == EmotionType.focused)
        ? EmotionType.focused
        : configs.first.type;

    return WaveConfig(
      type: dominantType,
      label: configs.map((config) => config.label).join('+'),
      amplitude: average((config) => config.amplitude),
      frequency: average((config) => config.frequency),
      smoothness: average((config) => config.smoothness),
      chaos: average((config) => config.chaos),
      speed: average((config) => config.speed),
      colors: configs.expand((config) => config.colors).take(5).toList(),
      blendMode: configs.any((config) => config.blendMode != BlendMode.srcOver)
          ? BlendMode.screen
          : BlendMode.srcOver,
      rise: average((config) => config.rise),
    );
  }

  @override
  bool shouldRepaint(covariant RhythmWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.previewEnergy != previewEnergy ||
        oldDelegate.touchPoint != touchPoint ||
        oldDelegate.touchStart != touchStart ||
        !setEquals(oldDelegate.previewEmotions, previewEmotions) ||
        oldDelegate.entry?.id != entry?.id ||
        oldDelegate.entry?.energy != entry?.energy ||
        !listEquals(oldDelegate.entry?.emotions, entry?.emotions);
  }
}
