import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/familia_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import 'watu/orodha_watu_screen.dart';
import 'mti/mti_ukoo_screen.dart';
import 'mipangilio/mipangilio_screen.dart';
import 'auth/auth_screen.dart';

class NyumbaniScreen extends StatefulWidget {
  const NyumbaniScreen({super.key});

  @override
  State<NyumbaniScreen> createState() => _NyumbaniState();
}

class _NyumbaniState extends State<NyumbaniScreen> {
  int _tab = 0;

  static const _screens = [
    OrodhaWatuScreen(),
    MtiUkooScreen(),
    MipangilioScreen(),
  ];

  static const _icons = [
    [Icons.people_outline, Icons.people],
    [Icons.account_tree_outlined, Icons.account_tree],
    [Icons.settings_outlined, Icons.settings],
  ];

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<FamiliaProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌳 '),
            Text(prov.mtumiaji?.familia_jina ?? 'Familia Yangu'),
          ],
        ),
        backgroundColor: AppColors.forestMid,
        actions: [
          IconButton(
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            tooltip: 'Badilisha Theme',
            onPressed: () => theme.setDark(!theme.isDark),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Toka',
            onPressed: () => _confirmLogout(context, prov),
          ),
        ],
      ),
      body: _screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: List.generate(
          3,
          (i) => NavigationDestination(
            icon: Icon(_icons[i][0]),
            selectedIcon: Icon(_icons[i][1]),
            label: ['Watu', 'Mti Ukoo', 'Mipangilio'][i],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, FamiliaProvider prov) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Toka'),
        content: const Text('Una uhakika unataka kutoka?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hapana'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await prov.toka();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthScreen(),
                  ),
                );
              }
            },
            child: const Text('Ndiyo, Toka'),
          ),
        ],
      ),
    );
  }
}