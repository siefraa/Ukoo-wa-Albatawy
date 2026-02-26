import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mtu.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';

class FormuMtuScreen extends StatefulWidget {
  final Mtu? mtu;
  const FormuMtuScreen({super.key, this.mtu});
  @override State<FormuMtuScreen> createState() => _FormuMtuState();
}

class _FormuMtuState extends State<FormuMtuScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _jina, _jinaMwingine, _ukoo,
    _tarehe_kuzaliwa, _tarehe_kufa, _mahali, _simu, _barua, _maelezo;
  String _jinsia = 'Kiume';
  bool _busy = false;
  bool get _isEdit => widget.mtu != null;

  @override
  void initState() {
    super.initState();
    final m = widget.mtu;
    _jina            = TextEditingController(text: m?.jina ?? '');
    _jinaMwingine    = TextEditingController(text: m?.jinaMwingine ?? '');
    _ukoo            = TextEditingController(text: m?.ukoo ?? '');
    _tarehe_kuzaliwa = TextEditingController(text: m?.tarehe_kuzaliwa ?? '');
    _tarehe_kufa     = TextEditingController(text: m?.tarehe_kufa ?? '');
    _mahali          = TextEditingController(text: m?.mahali_kuzaliwa ?? '');
    _simu            = TextEditingController(text: m?.simu ?? '');
    _barua           = TextEditingController(text: m?.barua_pepe ?? '');
    _maelezo         = TextEditingController(text: m?.maelezo ?? '');
    _jinsia          = m?.jinsia ?? 'Kiume';
  }

  @override void dispose() {
    for (final c in [_jina,_jinaMwingine,_ukoo,_tarehe_kuzaliwa,_tarehe_kufa,_mahali,_simu,_barua,_maelezo]) c.dispose();
    super.dispose();
  }

  String? _trim(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final prov = context.read<FamiliaProvider>();

    if (_isEdit) {
      final u = widget.mtu!.copy();
      u.jina = _jina.text.trim();
      u.jinaMwingine = _trim(_jinaMwingine);
      u.ukoo = _trim(_ukoo);
      u.tarehe_kuzaliwa = _trim(_tarehe_kuzaliwa);
      u.tarehe_kufa = _trim(_tarehe_kufa);
      u.mahali_kuzaliwa = _trim(_mahali);
      u.simu = _trim(_simu);
      u.barua_pepe = _trim(_barua);
      u.maelezo = _trim(_maelezo);
      u.jinsia = _jinsia;
      await prov.badilishaTaarifa(u);
    } else {
      await prov.ongezaMtu(
        jina: _jina.text.trim(),
        jinaMwingine: _trim(_jinaMwingine),
        ukoo: _trim(_ukoo),
        tarehe_kuzaliwa: _trim(_tarehe_kuzaliwa),
        tarehe_kufa: _trim(_tarehe_kufa),
        mahali_kuzaliwa: _trim(_mahali),
        jinsia: _jinsia,
        simu: _trim(_simu),
        barua_pepe: _trim(_barua),
        maelezo: _trim(_maelezo),
      );
    }
    setState(() => _busy = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _jinsia == 'Kiume';
    final color = isMale ? AppColors.male : AppColors.female;
    final colorLight = isMale ? AppColors.maleLight : AppColors.femaleLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Hariri Taarifa' : 'Ongeza Mtu Mpya'),
        actions: [
          if (!_busy)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, color: Colors.white, size: 18),
              label: const Text('Hifadhi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          if (_busy)
            const Padding(padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar preview
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [colorLight, color]),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(isMale ? '👨' : '👩', style: const TextStyle(fontSize: 36)),
                  if (_jina.text.isNotEmpty)
                    Text(_jina.text.split(' ').first,
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ),
            ),
            const SizedBox(height: 24),

            _Section('Taarifa za Msingi', Icons.person, color),
            const SizedBox(height: 12),

            _Field(ctrl: _jina, label: 'Jina la Kwanza *', icon: Icons.badge_outlined,
              onChanged: (_) => setState(() {}),
              validator: (v) => v?.trim().isEmpty == true ? 'Jina ni lazima' : null),
            const SizedBox(height: 12),
            _Field(ctrl: _jinaMwingine, label: 'Jina la Kati (Hiari)', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _Field(ctrl: _ukoo, label: 'Jina la Ukoo', icon: Icons.family_restroom),
            const SizedBox(height: 18),

            _Section('Jinsia', Icons.wc, color),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _GenderBtn(label: '👨 Kiume', selected: _jinsia == 'Kiume',
                color: AppColors.male, onTap: () => setState(() => _jinsia = 'Kiume'))),
              const SizedBox(width: 12),
              Expanded(child: _GenderBtn(label: '👩 Kike', selected: _jinsia == 'Kike',
                color: AppColors.female, onTap: () => setState(() => _jinsia = 'Kike'))),
            ]),
            const SizedBox(height: 18),

            _Section('Tarehe na Mahali', Icons.calendar_today, color),
            const SizedBox(height: 12),
            _Field(ctrl: _tarehe_kuzaliwa, label: 'Tarehe ya Kuzaliwa', icon: Icons.cake_outlined,
              hint: 'mfano: 15 Januari 1980'),
            const SizedBox(height: 12),
            _Field(ctrl: _mahali, label: 'Mahali pa Kuzaliwa', icon: Icons.place_outlined),
            const SizedBox(height: 12),
            _Field(ctrl: _tarehe_kufa, label: 'Tarehe ya Kufariki (kama amefariki)', icon: Icons.star_border,
              hint: 'Acha wazi kama bado yuko'),
            const SizedBox(height: 18),

            _Section('Mawasiliano', Icons.contact_phone, color),
            const SizedBox(height: 12),
            _Field(ctrl: _simu, label: 'Namba ya Simu', icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _Field(ctrl: _barua, label: 'Barua Pepe', icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 18),

            _Section('Maelezo Zaidi', Icons.notes, color),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maelezo,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Maelezo (Hiari)',
                hintText: 'Habari zaidi kuhusu mtu huyu...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.parchment,
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _save,
                icon: Icon(_isEdit ? Icons.save : Icons.person_add),
                label: Text(_isEdit ? 'Hifadhi Mabadiliko' : 'Ongeza Mtu',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestMid),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _Section(this.label, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.5)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: color.withOpacity(0.3))),
    ]);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const _Field({required this.ctrl, required this.label, required this.icon,
    this.hint, this.keyboardType, this.onChanged, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  final String label; final bool selected; final Color color; final VoidCallback onTap;
  const _GenderBtn({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? color : Colors.grey))),
      ),
    );
  }
}
