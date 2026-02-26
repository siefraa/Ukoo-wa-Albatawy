import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mtu.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';
import 'fomu_mtu_screen.dart';
import 'maelezo_mtu_screen.dart';

class OrodhaWatuScreen extends StatefulWidget {
  const OrodhaWatuScreen({super.key});
  @override State<OrodhaWatuScreen> createState() => _OrodhaWatuScreenState();
}

class _OrodhaWatuScreenState extends State<OrodhaWatuScreen> {
  final _searchCtrl = TextEditingController();

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FamiliaProvider>();
    final watu = prov.matokeoUtafutaji;

    return Scaffold(
      body: Column(
        children: [
          // Search + stats header
          Container(
            color: AppColors.parchmentDark,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: AppColors.forest.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: prov.badilishaUtafutaji,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tafuta mtu wa familia...',
                      hintStyle: TextStyle(color: AppColors.textLight),
                      prefixIcon: const Icon(Icons.search, color: AppColors.forestMid, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () { _searchCtrl.clear(); prov.badilishaUtafutaji(''); },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      filled: false,
                    ),
                  ),
                ),
                // Stats chips
                if (prov.watuwote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Chip(icon: Icons.people, label: '${prov.watuwote.length}', color: AppColors.forestMid),
                      const SizedBox(width: 8),
                      _Chip(icon: Icons.male, label: '${prov.watuwote.where((m) => m.jinsia == "Kiume").length}', color: AppColors.male),
                      const SizedBox(width: 8),
                      _Chip(icon: Icons.female, label: '${prov.watuwote.where((m) => m.jinsia == "Kike").length}', color: AppColors.female),
                      const Spacer(),
                      if (prov.watuwote.where((m) => m.amefariki).isNotEmpty)
                        _Chip(icon: Icons.star_border, label: '${prov.watuwote.where((m) => m.amefariki).length} wamefariki', color: Colors.grey),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // List
          Expanded(
            child: watu.isEmpty
                ? _EmptyState(searching: _searchCtrl.text.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: watu.length,
                    itemBuilder: (_, i) => _MtuKadi(mtu: watu[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FormuMtuScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('Ongeza Mtu'),
        backgroundColor: AppColors.forestMid,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searching;
  const _EmptyState({required this.searching});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🌳', style: TextStyle(fontSize: 72, color: AppColors.forestLight.withOpacity(0.3))),
        const SizedBox(height: 16),
        Text(
          searching ? 'Hakuna matokeo ya utafutaji' : 'Bonyeza + kuongeza mtu wa kwanza',
          style: const TextStyle(color: AppColors.textLight, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _Chip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── Person card ──
class _MtuKadi extends StatelessWidget {
  final Mtu mtu;
  const _MtuKadi({required this.mtu});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<FamiliaProvider>();
    final isMale = mtu.jinsia == 'Kiume';
    final primary = isMale ? AppColors.male : AppColors.female;
    final primaryLight = isMale ? AppColors.maleLight : AppColors.femaleLight;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shadowColor: primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => MaelezoMtuScreen(mtuId: mtu.id))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Circle avatar matching the tree node style
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [primaryLight, primary],
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8)],
                ),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(isMale ? '👨' : '👩', style: const TextStyle(fontSize: 22)),
                    if (mtu.amefariki)
                      Text('✝', style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8))),
                  ]),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Text(mtu.jilaKamili,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Georgia')),
                    ),
                    if (mtu.amefariki)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Amefariki', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                  ]),
                  if (mtu.tarehe_kuzaliwa?.isNotEmpty == true)
                    Row(children: [
                      const Icon(Icons.cake_outlined, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(mtu.tarehe_kuzaliwa!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                      if (mtu.umri != null) ...[
                        const SizedBox(width: 6),
                        Text('(${mtu.umri} miaka)',
                          style: TextStyle(fontSize: 10, color: AppColors.textLight.withOpacity(0.7))),
                      ],
                    ]),
                  if (mtu.mahali_kuzaliwa?.isNotEmpty == true)
                    Row(children: [
                      const Icon(Icons.place_outlined, size: 12, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(mtu.mahali_kuzaliwa!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                    ]),
                  const SizedBox(height: 4),
                  Wrap(spacing: 6, children: [
                    if (mtu.watoto.isNotEmpty) _RelBadge('${mtu.watoto.length} Watoto', Colors.green),
                    if (mtu.wenzi.isNotEmpty) _RelBadge('${mtu.wenzi.length} Wenzi', Colors.orange),
                    if (mtu.wazazi.isNotEmpty) _RelBadge('${mtu.wazazi.length} Wazazi', Colors.purple),
                  ]),
                ]),
              ),

              PopupMenuButton<String>(
                onSelected: (v) => _onAction(context, v, prov),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'maelezo',
                    child: Row(children: [Icon(Icons.info_outline, size: 18), SizedBox(width: 10), Text('Maelezo')])),
                  const PopupMenuItem(value: 'hariri',
                    child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 10), Text('Hariri')])),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: 'futa',
                    child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 10), Text('Futa', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAction(BuildContext ctx, String v, FamiliaProvider prov) {
    if (v == 'maelezo') {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => MaelezoMtuScreen(mtuId: mtu.id)));
    } else if (v == 'hariri') {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => FormuMtuScreen(mtu: mtu)));
    } else if (v == 'futa') {
      showDialog(context: ctx, builder: (_) => AlertDialog(
        title: const Text('Futa Mtu'),
        content: Text('Una uhakika unataka kufuta ${mtu.jilaKamili}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hapana')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(ctx); prov.futaMtu(mtu.id); },
            child: const Text('Futa'),
          ),
        ],
      ));
    }
  }
}

class _RelBadge extends StatelessWidget {
  final String label; final Color color;
  const _RelBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
