import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/familia_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FamiliaProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FamiliaYanguApp(),
    ),
  );
}

class FamiliaYanguApp extends StatelessWidget {
  const FamiliaYanguApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Familia Yangu',
      debugShowCheckedModeBanner: false,
      theme: tp.light,
      darkTheme: tp.dark,
      themeMode: tp.mode,
      home: const SplashScreen(),
    );
  }
}
