import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mtu.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';
import 'fomu_mtu_screen.dart';

class MaelezoMtuScreen extends StatelessWidget {
  final String mtuId;
  const MaelezoMtuScreen({super.key, required this.mtuId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FamiliaProvider>();
    final m = prov.watu[mtuId];
    if (m == null) {
      return Scaffold(appBar: AppBar(title: const Text('Mtu Hapatikani')),
        body: const Center(child: Text('Mtu huyu hapatikani')));
    }

    final isMale = m.jinsia == 'Kiume';
    final primary = isMale ? AppColors.male : AppColors.female;
    final light = isMale ? AppColors.maleLight : AppColors.femaleLight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: primary,
            actions: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FormuMtuScreen(mtu: m)))),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _confirmDelete(context, prov, m)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [light, primary]),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 48),
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16)],
                    ),
                    child: Center(child: Text(isMale ? '👨' : '👩', style: const TextStyle(fontSize: 44))),
                  ),
                  const SizedBox(height: 10),
                  Text(m.jilaKamili,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Georgia')),
                  if (m.amefariki)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('✝ Amefariki', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Basic info card
                _InfoCard(title: 'Taarifa za Msingi', icon: Icons.info_outline, color: primary,
                  rows: [
                    if (m.tarehe_kuzaliwa?.isNotEmpty == true)
                      _Row('Kuzaliwa', m.tarehe_kuzaliwa!),
                    if (m.mahali_kuzaliwa?.isNotEmpty == true)
                      _Row('Mahali', m.mahali_kuzaliwa!),
                    if (m.tarehe_kufa?.isNotEmpty == true)
                      _Row('Alifariki', m.tarehe_kufa!, color: Colors.grey),
                    _Row('Jinsia', m.jinsia, color: primary),
                    if (m.umri != null) _Row('Umri', '${m.umri} miaka'),
                  ],
                ),
                if (m.simu != null || m.barua_pepe != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(title: 'Mawasiliano', icon: Icons.contact_phone, color: primary,
                    rows: [
                      if (m.simu?.isNotEmpty == true) _Row('Simu', m.simu!),
                      if (m.barua_pepe?.isNotEmpty == true) _Row('Barua Pepe', m.barua_pepe!),
                    ],
                  ),
                ],
                if (m.maelezo?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _InfoCard(title: 'Maelezo', icon: Icons.notes, color: primary,
                    child: Text(m.maelezo!, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.6)),
                  ),
                ],
                const SizedBox(height: 12),

                // Relationships
                _RelSection(title: 'Wazazi', icon: Icons.escalator_warning, color: Colors.orange,
                  watu: prov.wazaziWa(mtuId), aina: 'mzazi', mtuId: mtuId, prov: prov),
                const SizedBox(height: 10),
                _RelSection(title: 'Wenzi wa Ndoa', icon: Icons.favorite, color: Colors.red,
                  watu: prov.wenziWa(mtuId), aina: 'mwenzi', mtuId: mtuId, prov: prov),
                const SizedBox(height: 10),
                _RelSection(title: 'Watoto', icon: Icons.child_care, color: Colors.green,
                  watu: prov.watotoWa(mtuId), aina: 'mtoto', mtuId: mtuId, prov: prov),
                const SizedBox(height: 10),
                _RelSection(title: 'Ndugu na Dada', icon: Icons.people, color: Colors.purple,
                  watu: prov.nduguWa(mtuId), aina: 'ndugu', mtuId: mtuId, prov: prov),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, FamiliaProvider prov, Mtu m) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: const Text('Futa Mtu'),
      content: Text('Una uhakika unataka kufuta ${m.jilaKamili}?\nViungo vyote vitaondolewa.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hapana')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () { Navigator.pop(ctx); Navigator.pop(ctx); prov.futaMtu(m.id); },
          child: const Text('Futa'),
        ),
      ],
    ));
  }
}

class _Row { final String k, v; final Color? color; const _Row(this.k, this.v, {this.color}); }

class _InfoCard extends StatelessWidget {
  final String title; final IconData icon; final Color color;
  final List<_Row>? rows; final Widget? child;
  const _InfoCard({required this.title, required this.icon, required this.color, this.rows, this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 12),
          if (rows != null) ...rows!.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 80, child: Text(r.k,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              const SizedBox(width: 8),
              Expanded(child: Text(r.v,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: r.color ?? AppColors.textDark))),
            ]),
          )),
          if (child != null) child!,
        ]),
      ),
    );
  }
}

class _RelSection extends StatelessWidget {
  final String title, aina, mtuId;
  final List<Mtu> watu;
  final IconData icon;
  final Color color;
  final FamiliaProvider prov;

  const _RelSection({required this.title, required this.icon, required this.color,
    required this.watu, required this.aina, required this.mtuId, required this.prov});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('${watu.length}',
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
              ),
            ]),
            if (aina != 'ndugu')
              TextButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: Icon(Icons.add, size: 15, color: color),
                label: Text('Ongeza', style: TextStyle(color: color, fontSize: 12)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
          ]),
          if (watu.isNotEmpty) ...[
            const Divider(height: 16),
            ...watu.map((m) => _RelRow(m: m, color: color, prov: prov, mtuId: mtuId, aina: aina)),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Hakuna $title bado',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
            ),
        ]),
      ),
    );
  }

  void _showAddDialog(BuildContext ctx) {
    final available = prov.watuwote.where((m) {
      if (m.id == mtuId) return false;
      if (aina == 'mzazi') return !prov.watu[mtuId]!.wazazi.contains(m.id);
      if (aina == 'mwenzi') return !prov.watu[mtuId]!.wenzi.contains(m.id);
      if (aina == 'mtoto') return !prov.watu[mtuId]!.watoto.contains(m.id);
      return false;
    }).toList();

    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Row(children: [Icon(icon, color: color), const SizedBox(width: 8), Text('Ongeza $title')]),
      content: SizedBox(
        width: double.maxFinite, height: 280,
        child: available.isEmpty
            ? const Center(child: Text('Hakuna watu wengine wa kuongeza'))
            : ListView(children: available.map((m) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: (m.jinsia == 'Kike' ? AppColors.female : AppColors.male).withOpacity(0.15),
                  child: Text(m.jinsia == 'Kike' ? '👩' : '👨')),
                title: Text(m.jilaKamili, style: const TextStyle(fontSize: 13)),
                subtitle: m.tarehe_kuzaliwa?.isNotEmpty == true ? Text(m.tarehe_kuzaliwa!, style: const TextStyle(fontSize: 11)) : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  if (aina == 'mzazi') await prov.ongezaMzazi(mtotoId: mtuId, mzaziId: m.id);
                  else if (aina == 'mwenzi') await prov.ongezaMwenzi(id1: mtuId, id2: m.id);
                  else if (aina == 'mtoto') await prov.ongezaMtoto(mzaziId: mtuId, mtotoId: m.id);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('${m.jilaKamili} ameongezwa kama $title'),
                      backgroundColor: color, behavior: SnackBarBehavior.floating));
                  }
                },
              )).toList()),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Funga'))],
    ));
  }
}

class _RelRow extends StatelessWidget {
  final Mtu m; final Color color; final FamiliaProvider prov; final String mtuId, aina;
  const _RelRow({required this.m, required this.color, required this.prov, required this.mtuId, required this.aina});

  @override
  Widget build(BuildContext context) {
    final rel = prov.uhusianoNi(mtuId, m.id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            m.jinsia == 'Kike' ? AppColors.femaleLight : AppColors.maleLight,
            m.jinsia == 'Kike' ? AppColors.female : AppColors.male,
          ]),
        ),
        child: Center(child: Text(m.jinsia == 'Kike' ? '👩' : '👨', style: const TextStyle(fontSize: 18))),
      ),
      title: Text(m.jilaKamili, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(rel, style: TextStyle(fontSize: 11, color: color)),
      trailing: aina != 'ndugu' ? IconButton(
        icon: Icon(Icons.link_off, size: 18, color: Colors.grey.shade400),
        tooltip: 'Ondoa uhusiano',
        onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('Ondoa Uhusiano'),
          content: Text('Ondoa uhusiano kati yako na ${m.jilaKamili}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hapana')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () { Navigator.pop(context); prov.ondoaUhusiano(id1: mtuId, id2: m.id, aina: aina); },
              child: const Text('Ondoa'),
            ),
          ],
        )),
      ) : null,
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => MaelezoMtuScreen(mtuId: m.id))),
    );
  }
}
