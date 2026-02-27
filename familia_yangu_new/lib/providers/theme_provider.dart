import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeAccent _accent = ThemeAccent.forest;

  ThemeMode get mode => _mode;
  ThemeAccent get accent => _accent;
  bool get isDark => _mode == ThemeMode.dark;

  Color get primary => _accent.primary;
  Color get secondary => _accent.secondary;

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _mode = (p.getBool('dark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _accent = ThemeAccent.values[p.getInt('accent') ?? 0];
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    _mode = v ? ThemeMode.dark : ThemeMode.light;
    (await SharedPreferences.getInstance()).setBool('dark', v);
    notifyListeners();
  }

  Future<void> setAccent(ThemeAccent a) async {
    _accent = a;
    (await SharedPreferences.getInstance()).setInt('accent', a.index);
    notifyListeners();
  }

  ThemeData get light => _buildTheme(Brightness.light);
  ThemeData get dark  => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final seed = _accent.primary;
    final cs = ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
      primary: seed,
      secondary: _accent.secondary,
      surface: isLight ? AppColors.parchment : const Color(0xFF1a2910),
      onSurface: isLight ? AppColors.textDark : const Color(0xFFe8dfc4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isLight ? AppColors.parchment : const Color(0xFF141f0a),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.forest,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? Colors.white.withOpacity(0.92) : const Color(0xFF253518),
        elevation: 3,
        shadowColor: AppColors.forest.withOpacity(0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.parchment : const Color(0xFF1e2e12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.forestLight.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.forestLight.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 2),
        ),
        labelStyle: TextStyle(color: seed),
        prefixIconColor: seed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? AppColors.forest : const Color(0xFF0f1a07),
        indicatorColor: _accent.secondary.withOpacity(0.3),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Colors.white70)),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      dividerTheme: DividerThemeData(color: AppColors.forestLight.withOpacity(0.2)),
    );
  }
}
