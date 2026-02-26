import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';
import '../nyumbani_screen.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.forest, AppColors.forestMid, AppColors.parchment],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  child: const Center(
                    child: Text('🌳', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Familia Yangu',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.parchment,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TabBar(
                          controller: _tabs,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.forestMid,
                          indicator: BoxDecoration(
                            color: AppColors.forestMid,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tabs: const [
                            Tab(text: 'Ingia'),
                            Tab(text: 'Jiandikishe'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabs,
                            children: const [
                              _Ingia(),
                              _Jiandikisha(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────── LOGIN ───────────
class _Ingia extends StatefulWidget {
  const _Ingia();
  @override State<_Ingia> createState() => _IngiaState();
}
class _IngiaState extends State<_Ingia> {
  final _form = GlobalKey<FormState>();
  final _jina = TextEditingController();
  final _neno = TextEditingController();
  bool _show = false, _busy = false;

  @override void dispose() { _jina.dispose(); _neno.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final err = await context.read<FamiliaProvider>().ingia(jina: _jina.text.trim(), neno: _neno.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NyumbaniScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Text('Karibu tena! 👋',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forestMid)),
          const SizedBox(height: 4),
          Text('Ingiza taarifa zako kuendelea',
            style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 22),

          _Field(ctrl: _jina, label: 'Jina la kuingia', icon: Icons.person_outline,
            next: true, validator: (v) => (v?.trim().isEmpty ?? true) ? 'Weka jina' : null),
          const SizedBox(height: 14),
          _Field(ctrl: _neno, label: 'Neno Siri', icon: Icons.lock_outline,
            obscure: !_show, toggle: () => setState(() => _show = !_show), showing: _show,
            onSubmit: (_) => _submit(),
            validator: (v) => (v?.isEmpty ?? true) ? 'Weka neno siri' : null),
          const SizedBox(height: 28),

          SizedBox(height: 50, child: ElevatedButton(
            onPressed: _busy ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestMid),
            child: _busy ? const SizedBox(width:22,height:22,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2.5))
                : const Text('INGIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          )),
        ]),
      ),
    );
  }
}

// ─────────── REGISTER ───────────
class _Jiandikisha extends StatefulWidget {
  const _Jiandikisha();
  @override State<_Jiandikisha> createState() => _JiandikishaState();
}
class _JiandikishaState extends State<_Jiandikisha> {
  final _form = GlobalKey<FormState>();
  final _jina = TextEditingController();
  final _familia = TextEditingController();
  final _neno = TextEditingController();
  final _neno2 = TextEditingController();
  bool _show = false, _busy = false;

  @override void dispose() { _jina.dispose(); _familia.dispose(); _neno.dispose(); _neno2.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final err = await context.read<FamiliaProvider>().jiandikisha(
      jina: _jina.text.trim(), neno: _neno.text, familiaJina: _familia.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NyumbaniScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Text('Unda Akaunti Mpya 🌳',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forestMid)),
          const SizedBox(height: 4),
          Text('Jaza fomu hii kuanza safari ya ukoo wako',
            style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 22),

          _Field(ctrl: _jina, label: 'Jina la kuingia *', icon: Icons.person_outline,
            next: true,
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return 'Jina ni lazima';
              if ((v?.trim().length ?? 0) < 3) return 'Angalau herufi 3';
              return null;
            }),
          const SizedBox(height: 14),
          _Field(ctrl: _familia, label: 'Jina la Familia (Hiari)', icon: Icons.home_outlined,
            next: true, validator: (_) => null),
          const SizedBox(height: 14),
          _Field(ctrl: _neno, label: 'Neno Siri *', icon: Icons.lock_outline,
            obscure: !_show, toggle: () => setState(() => _show = !_show), showing: _show,
            next: true,
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Weka neno siri';
              if ((v?.length ?? 0) < 4) return 'Angalau herufi 4';
              return null;
            }),
          const SizedBox(height: 14),
          _Field(ctrl: _neno2, label: 'Thibitisha Neno Siri *', icon: Icons.lock_person_outlined,
            obscure: !_show,
            onSubmit: (_) => _submit(),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Thibitisha neno siri';
              if (v != _neno.text) return 'Maneno siri hayafanani';
              return null;
            }),
          const SizedBox(height: 28),

          SizedBox(height: 50, child: ElevatedButton.icon(
            onPressed: _busy ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestMid),
            icon: _busy ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2.5))
                : const Icon(Icons.how_to_reg),
            label: Text(_busy ? 'Inajiandikisha...' : 'JIANDIKISHE',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1)),
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ─────────── Shared Field Widget ───────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool next;
  final bool? showing;
  final VoidCallback? toggle;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmit;

  const _Field({
    required this.ctrl, required this.label, required this.icon,
    this.obscure = false, this.next = false, this.showing,
    this.toggle, this.validator, this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      textInputAction: next ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: onSubmit,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: toggle != null
          ? IconButton(icon: Icon(showing! ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: toggle)
          : null,
      ),
    );
  }
}
