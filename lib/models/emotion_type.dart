import 'dart:math';

import 'package:flutter/material.dart';

enum EmotionType { calm, anxious, achievement, focused, tired, joyful }

class EmotionMapping {
  const EmotionMapping._();

  static EmotionType resolve(String keyword) {
    switch (keyword) {
      case '불안':
        return EmotionType.anxious;
      case '성취감':
        return EmotionType.achievement;
      case '집중':
        return EmotionType.focused;
      case '피곤':
      case '무기력':
        return EmotionType.tired;
      case '기쁨':
      case '설렘':
        return EmotionType.joyful;
      case '평온':
      default:
        return EmotionType.calm;
    }
  }

  static Color color(List<String> emotions) {
    if (emotions.contains('불안')) {
      return const Color(0xFF9E86E5); // Bright amethyst violet glow
    }
    if (emotions.contains('피곤')) {
      return const Color(0xFF758591); // Sleek charcoal-steel grey
    }
    if (emotions.contains('성취감')) {
      return const Color(0xFFF9C851); // Radiant amber/yellow-gold
    }
    if (emotions.contains('기쁨') || emotions.contains('설렘')) {
      return const Color(0xFFFF8B9C); // Lighter hot rose-coral glow
    }
    if (emotions.contains('집중')) {
      return const Color(0xFF1BE0B5); // Electric aqua/emerald teal
    }
    return const Color(0xFF6EC99E); // Calm sage/mint green glow
  }
}

class WaveConfig {
  const WaveConfig({
    required this.type,
    required this.label,
    required this.amplitude,
    required this.frequency,
    required this.smoothness,
    required this.chaos,
    required this.speed,
    required this.colors,
    required this.blendMode,
    this.rise = 0,
  });

  final EmotionType type;
  final String label;
  final double amplitude;
  final double frequency;
  final double smoothness;
  final double chaos;
  final double speed;
  final List<Color> colors;
  final BlendMode blendMode;
  final double rise;

  WaveConfig scaledByEnergy(int energy, int index) {
    final energyFactor = (energy - 3) / 2;
    return WaveConfig(
      type: type,
      label: label,
      amplitude: amplitude + energyFactor * 8 + index * 4,
      frequency: frequency + index * 0.18,
      smoothness: smoothness,
      chaos: chaos + max(0, energyFactor) * 0.08,
      speed: speed + energy * 0.04 + index * 0.08,
      colors: colors,
      blendMode: blendMode,
      rise: rise,
    );
  }
}

class WaveBehavior {
  const WaveBehavior._();

  static WaveConfig configFor(String keyword) {
    switch (EmotionMapping.resolve(keyword)) {
      case EmotionType.anxious:
        return const WaveConfig(
          type: EmotionType.anxious,
          label: '불규칙',
          amplitude: 43,
          frequency: 2.8,
          smoothness: 0.18,
          chaos: 0.72,
          speed: 1.6,
          colors: [Color(0xFFB58CFF), Color(0xFFFF7AC8), Color(0xFF7A5CFF)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.achievement:
        return const WaveConfig(
          type: EmotionType.achievement,
          label: '상승',
          amplitude: 52,
          frequency: 1.28,
          smoothness: 0.95,
          chaos: 0.04,
          speed: 1.22,
          colors: [Color(0xFFFFD86B), Color(0xFFFFA94D), Color(0xFFFFFFFF)],
          blendMode: BlendMode.plus,
          rise: 52,
        );
      case EmotionType.focused:
        return const WaveConfig(
          type: EmotionType.focused,
          label: '집중',
          amplitude: 30,
          frequency: 2.05,
          smoothness: 0.88,
          chaos: 0.04,
          speed: 0.92,
          colors: [Color(0xFF1BE0B5), Color(0xFF83F7D5), Color(0xFF3AA8FF)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.tired:
        return const WaveConfig(
          type: EmotionType.tired,
          label: '저하',
          amplitude: 20,
          frequency: 0.95,
          smoothness: 0.82,
          chaos: 0.1,
          speed: 0.48,
          colors: [Color(0xFF758591), Color(0xFFAEB8BE), Color(0xFF55636A)],
          blendMode: BlendMode.srcOver,
          rise: -12,
        );
      case EmotionType.joyful:
        return const WaveConfig(
          type: EmotionType.joyful,
          label: '활기',
          amplitude: 38,
          frequency: 2.35,
          smoothness: 0.56,
          chaos: 0.2,
          speed: 1.35,
          colors: [Color(0xFFFF8B9C), Color(0xFFFFD166), Color(0xFFFF6F91)],
          blendMode: BlendMode.screen,
        );
      case EmotionType.calm:
        return const WaveConfig(
          type: EmotionType.calm,
          label: '평온',
          amplitude: 26,
          frequency: 1.1,
          smoothness: 0.96,
          chaos: 0.03,
          speed: 0.62,
          colors: [Color(0xFF6EC99E), Color(0xFFA6E7C6), Color(0xFFEAC98C)],
          blendMode: BlendMode.srcOver,
        );
    }
  }
}
