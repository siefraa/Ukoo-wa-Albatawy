import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/familia_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';

class MipangilioScreen extends StatelessWidget {
  const MipangilioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<FamiliaProvider>();
    final theme = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Profile card ──
        _ProfileCard(prov: prov),
        const SizedBox(height: 20),

        // ── Appearance ──
        _SectionHeader('Mwonekano', Icons.palette, AppColors.forestMid),
        const SizedBox(height: 10),
        Card(
          child: Column(children: [
            SwitchListTile(
              secondary: Icon(theme.isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                color: AppColors.forestMid),
              title: const Text('Hali ya Usiku', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(theme.isDark ? 'Imewashwa' : 'Imezimwa'),
              value: theme.isDark,
              onChanged: theme.setDark,
              activeColor: AppColors.forestMid,
            ),
            const Divider(height: 0),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.color_lens_outlined, color: AppColors.forestMid, size: 18),
                  const SizedBox(width: 8),
                  const Text('Rangi ya Programu', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(theme.accent.label,
                    style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                ]),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14, runSpacing: 10,
                  children: ThemeAccent.values.map((a) => _AccentDot(
                    accent: a,
                    selected: theme.accent == a,
                    onTap: () => theme.setAccent(a),
                  )).toList(),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Data management ──
        _SectionHeader('Usimamizi wa Data', Icons.storage, AppColors.forestMid),
        const SizedBox(height: 10),
        Card(
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.bar_chart, color: AppColors.forestMid),
              title: const Text('Takwimu za Familia'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showStats(context, prov),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.upload_rounded, color: Colors.green.shade700),
              title: const Text('Hamisha Data (Export)'),
              subtitle: const Text('Hifadhi familia kama JSON'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _export(context, prov),
            ),
            const Divider(height: 0),
            ListTile(
              leading: Icon(Icons.download_rounded, color: Colors.blue.shade700),
              title: const Text('Ingiza Data (Import)'),
              subtitle: const Text('Pakia familia kutoka JSON'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _import(context, prov),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Danger zone ──
        _SectionHeader('Hatua za Tahadhari', Icons.warning_amber, Colors.red),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: const Text('Futa Data Yote', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            subtitle: const Text('Futa watu wote wa familia'),
            onTap: () => _confirmDelete(context, prov),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Stats ──
  void _showStats(BuildContext ctx, FamiliaProvider prov) {
    final watu = prov.watuwote;
    final wanaume = watu.where((m) => m.jinsia == 'Kiume').length;
    final wanawake = watu.where((m) => m.jinsia == 'Kike').length;
    final waliofariki = watu.where((m) => m.amefariki).length;
    final wazazi = watu.where((m) => m.watoto.isNotEmpty).length;

    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.bar_chart, color: AppColors.forestMid),
        SizedBox(width: 8), Text('Takwimu za Familia'),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _StatRow('Jumla ya Watu', watu.length, Icons.people),
        _StatRow('Wanaume', wanaume, Icons.male),
        _StatRow('Wanawake', wanawake, Icons.female),
        _StatRow('Wazazi', wazazi, Icons.family_restroom),
        _StatRow('Waliokufa', waliofariki, Icons.star_border),
        _StatRow('Mizizi ya Ukoo', prov.mizizi.length, Icons.account_tree),
      ]),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Sawa'))],
    ));
  }

  // ── Export ──
  void _export(BuildContext ctx, FamiliaProvider prov) {
    final data = prov.exportJson();
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.upload_rounded, color: Colors.green),
        SizedBox(width: 8), Text('Hamisha Data'),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Data ya familia ipo tayari. Nakili JSON hii:'),
        const SizedBox(height: 12),
        Container(
          height: 200, padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            child: SelectableText(data,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                content: Text('Data imenakiliwa kwenye clipboard!'),
                backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Nakili kwa Clipboard'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Funga'))],
    ));
  }

  // ── Import ──
  void _import(BuildContext ctx, FamiliaProvider prov) {
    final ctrl = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.download_rounded, color: Colors.blue),
        SizedBox(width: 8), Text('Ingiza Data'),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Bandika JSON ya familia hapa:'),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl, maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'Bandika JSON hapa...', border: OutlineInputBorder()),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(ctx); ctrl.dispose(); }, child: const Text('Ghairi')),
        ElevatedButton(
          onPressed: () async {
            final err = await prov.importJson(ctrl.text.trim());
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            ctrl.dispose();
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(err ?? '✅ Data imeingizwa kikamilifu!'),
              backgroundColor: err != null ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating));
          },
          child: const Text('Ingiza'),
        ),
      ],
    ));
  }

  // ── Delete all ──
  void _confirmDelete(BuildContext ctx, FamiliaProvider prov) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.delete_forever, color: Colors.red),
        SizedBox(width: 8), Text('Futa Data Yote', style: TextStyle(color: Colors.red)),
      ]),
      content: const Text('Una uhakika? Hatua hii haiwezi kubatilishwa.\nWatu WOTE wa familia watafutwa milele!'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await prov.futaDataYote();
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
              content: Text('Data yote imefutwa'), backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating));
          },
          child: const Text('Ndiyo, Futa Yote'),
        ),
      ],
    ));
  }
}

class _ProfileCard extends StatelessWidget {
  final FamiliaProvider prov;
  const _ProfileCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    final m = prov.mtumiaji;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.forestLight, AppColors.forestMid]),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [BoxShadow(color: AppColors.forestMid.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Center(child: Text(
              m?.jina[0].toUpperCase() ?? '?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m?.jina ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Georgia')),
            Text(m?.familia_jina ?? 'Familia Yangu',
              style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
            Text('${prov.watuwote.length} watu katika familia',
              style: const TextStyle(color: AppColors.forestMid, fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final IconData icon; final Color color;
  const _SectionHeader(this.title, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: color.withOpacity(0.3))),
    ]);
  }
}

class _AccentDot extends StatelessWidget {
  final ThemeAccent accent; final bool selected; final VoidCallback onTap;
  const _AccentDot({required this.accent, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: accent.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38, height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.primary,
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent, width: 3),
            boxShadow: [
              BoxShadow(color: accent.primary.withOpacity(selected ? 0.6 : 0.2),
                blurRadius: selected ? 12 : 4, spreadRadius: selected ? 2 : 0),
            ],
          ),
          child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label; final int value; final IconData icon;
  const _StatRow(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.forestMid),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.forestMid.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$value',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.forestMid, fontSize: 15)),
        ),
      ]),
    );
  }
}
