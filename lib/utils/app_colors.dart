import 'package:flutter/material.dart';

// ── Forest Heritage Palette (matches the HTML UI exactly) ──
class AppColors {
  // Forest greens
  static const forest = Color(0xFF1e3d0f);
  static const forestMid = Color(0xFF2d5016);
  static const forestLight = Color(0xFF4a7a1e);

  // Parchment
  static const parchment = Color(0xFFf5f0e8);
  static const parchmentDark = Color(0xFFede5d0);
  static const parchmentDeep = Color(0xFFd4c9a8);

  // Bark / wood
  static const bark = Color(0xFF8b5e3c);
  static const barkLight = Color(0xFFb8845a);

  // Gender colours
  static const male = Color(0xFF2e5f8a);
  static const maleLight = Color(0xFF4a85b5);
  static const female = Color(0xFF8b3070);
  static const femaleLight = Color(0xFFb8478a);

  // Gold accent
  static const gold = Color(0xFFc9a227);
  static const goldGlow = Color(0xFFffd700);

  // Text
  static const textDark = Color(0xFF1a2e0a);
  static const textMid = Color(0xFF3d5c1e);
  static const textLight = Color(0xFF6b8f4e);
}

enum AppThemeMode { light, dark }
enum ThemeAccent { forest, ocean, ember, plum, rose }

extension ThemeAccentX on ThemeAccent {
  String get label {
    switch (this) {
      case ThemeAccent.forest: return 'Msitu (Kijani)';
      case ThemeAccent.ocean:  return 'Bahari (Bluu)';
      case ThemeAccent.ember:  return 'Makaa (Chungwa)';
      case ThemeAccent.plum:   return 'Plamu (Zambarau)';
      case ThemeAccent.rose:   return 'Waridi (Pinki)';
    }
  }

  Color get primary {
    switch (this) {
      case ThemeAccent.forest: return AppColors.forestMid;
      case ThemeAccent.ocean:  return const Color(0xFF1a4f6e);
      case ThemeAccent.ember:  return const Color(0xFFb84a00);
      case ThemeAccent.plum:   return const Color(0xFF5b2d8e);
      case ThemeAccent.rose:   return const Color(0xFFa03060);
    }
  }

  Color get secondary {
    switch (this) {
      case ThemeAccent.forest: return AppColors.forestLight;
      case ThemeAccent.ocean:  return const Color(0xFF2e7da6);
      case ThemeAccent.ember:  return const Color(0xFFe07020);
      case ThemeAccent.plum:   return const Color(0xFF8a4abe);
      case ThemeAccent.rose:   return const Color(0xFFd05080);
    }
  }

  Color get dot { return secondary; }
}
