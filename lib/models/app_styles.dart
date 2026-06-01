// ============================================================
// Premium Obsidian Dark Luxury Design System for Rhythm
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Deep obsidian luxury dark backgrounds
  static const background = Color(0xFF050808);
  static const surface = Color(0xFF0B1213);
  static const surfaceAlt = Color(0xFF121C1D);

  // Elegant metallic borders (satin slate / platinum and soft gold)
  static const border = Color(0xFF1D2B2D);
  static const borderStrong = Color(0xFF30484B);
  static const borderGold = Color(0x33D6B66D);

  // Sophisticated deep forest brand teal-green
  static const primary = Color(0xFF123635);
  static const primaryDark = Color(0xFF081819);
  static const primaryLight = Color(0xFF1F5A57);

  // Radiant premium gold and warm champagne accents
  static const accent = Color(0xFFD6B66D); // Softer refined gold
  static const accentLight = Color(0xFFF1D7A1); // Champagne highlight
  static const accentBronze = Color(0xFFC7AB7E); // Satin warm bronze

  // Elegant silk off-white & silver text hierarchy
  static const textPrimary = Color(0xFFE9EFF0);
  static const textSecondary = Color(0xFFA8B5B7);
  static const textMuted = Color(0xFF718082);
  static const textGold = Color(0xFFC5A880);

  // Translucent overlays
  static const overlay = Color(0x13FFFFFF);
  static const glassBackground = Color(0x1F0B1112);
}

class AppRadii {
  static const card = 18.0;
  static const chip = 14.0;
  static const button = 14.0;
  static const energyDot = 32.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 28,
      offset: Offset(0, 14),
      spreadRadius: -8,
    ),
  ];

  static const subtle = [
    BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}

String? topKey(Map<String, int> counts) {
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
