import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/nyumbani_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final p = context.read<FamiliaProvider>();
    while (!p.imepakia) { await Future.delayed(const Duration(milliseconds: 50)); }
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => p.imeingia ? const NyumbaniScreen() : const AuthScreen(),
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.forest, AppColors.forestMid, Color(0xFF3a6b1a)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30)],
                  ),
                  child: const Center(child: Text('🌳', style: TextStyle(fontSize: 64))),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Familia Yangu',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 36,
                  fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Mti wa Ukoo wa Familia yako',
                style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.75), letterSpacing: 0.5)),
              const SizedBox(height: 56),
              SizedBox(width: 40, height: 40,
                child: CircularProgressIndicator(color: Colors.white.withOpacity(0.6), strokeWidth: 2.5)),
            ]),
          ),
        ),
      ),
    );
  }
}
