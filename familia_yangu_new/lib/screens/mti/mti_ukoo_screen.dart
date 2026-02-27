import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mtu.dart';
import '../../providers/familia_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/mtu_node.dart';
import '../watu/maelezo_mtu_screen.dart';

// ──────────────────────────────────────────────────────
//  Layout constants
// ──────────────────────────────────────────────────────
const double _nodeR   = 44.0;   // node radius
const double _nodeD   = _nodeR * 2;
const double _hGap    = 28.0;   // horizontal gap between siblings
const double _genH    = 160.0;  // vertical space per generation
const double _spouseW = 80.0;   // horizontal space for spouse node from center

class MtiUkooScreen extends StatefulWidget {
  const MtiUkooScreen({super.key});
  @override State<MtiUkooScreen> createState() => _MtiUkooState();
}

class _MtiUkooState extends State<MtiUkooScreen> {
  final _transformCtrl = TransformationController();
  String? _rootId;

  @override void dispose() { _transformCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FamiliaProvider>();
    final watu = prov.watuwote;

    if (watu.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🌳', style: TextStyle(fontSize: 80, color: AppColors.forestLight.withOpacity(0.4))),
          const SizedBox(height: 16),
          Text('Hakuna watu bado.\nOngeza watu kwanza.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontSize: 15)),
        ]),
      );
    }

    final root = _rootId != null && prov.watu.containsKey(_rootId)
        ? prov.watu[_rootId]!
        : (prov.mizizi.isNotEmpty ? prov.mizizi.first : watu.first);

    final selected = prov.mtuChaguliwa;
    final highlighted = selected != null ? prov.wahusikaoNa(selected) : null;

    // Build layout
    final layout = _buildLayout(root, prov);
    final canvasW = (layout.maxX + _nodeR + 40).clamp(400.0, 4000.0);
    final canvasH = (layout.maxY + _nodeR + 60).clamp(400.0, 3000.0);

    return Column(
      children: [
        // ── Controls bar ──
        _ControlBar(
          watu: watu, rootId: root.id,
          onRootChanged: (id) => setState(() { _rootId = id; _transformCtrl.value = Matrix4.identity(); }),
          onCenter: () => _transformCtrl.value = Matrix4.identity(),
          selectedId: selected,
          onClearSelection: () { prov.futa_chaguo(); },
        ),

        // ── Tree canvas ──
        Expanded(
          child: InteractiveViewer(
            transformationController: _transformCtrl,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.2,
            maxScale: 4.0,
            child: SizedBox(
              width: canvasW,
              height: canvasH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Connections layer
                  CustomPaint(
                    size: Size(canvasW, canvasH),
                    painter: _ConnectionPainter(
                      positions: layout.positions,
                      connections: layout.connections,
                      highlighted: highlighted,
                    ),
                  ),
                  // Nodes
                  ...layout.positions.entries.map((e) {
                    final id = e.key;
                    final pos = e.value;
                    final m = prov.watu[id];
                    if (m == null) return const SizedBox.shrink();
                    final isSel = id == selected;
                    final isRel = highlighted?.contains(id) ?? false;
                    final isDim = highlighted != null && !isRel;
                    return Positioned(
                      left: pos.dx - _nodeR,
                      top: pos.dy - _nodeR,
                      child: Tooltip(
                        message: _tooltip(m, prov, selected),
                        child: MtuNode(
                          mtu: m,
                          isSelected: isSel,
                          isRelated: isRel && !isSel,
                          isDimmed: isDim,
                          size: _nodeD,
                          onTap: () {
                            if (isSel) {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => MaelezoMtuScreen(mtuId: id)));
                            } else {
                              prov.chaguaMtu(id);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  // Generation labels
                  ...layout.genLabels.entries.map((e) => Positioned(
                    left: 8, top: e.value - 18,
                    child: Text('— ${e.key}',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic,
                        color: AppColors.forestMid.withOpacity(0.5))),
                  )),
                ],
              ),
            ),
          ),
        ),

        // ── Legend ──
        _Legend(selectedId: selected, provider: prov),
      ],
    );
  }

  String _tooltip(Mtu m, FamiliaProvider prov, String? selectedId) {
    final rel = selectedId != null && selectedId != m.id
        ? prov.uhusianoNi(selectedId, m.id) : '';
    final parts = [m.jilaKamili];
    if (rel.isNotEmpty) parts.add('($rel)');
    if (m.tarehe_kuzaliwa?.isNotEmpty == true) parts.add('🎂 ${m.tarehe_kuzaliwa}');
    return parts.join(' · ');
  }
}

// ──────────────────────────────────────────────────────
//  Layout engine
// ──────────────────────────────────────────────────────
class _LayoutResult {
  final Map<String, Offset> positions;
  final List<_Connection> connections;
  final Map<String, double> genLabels;
  double maxX = 0, maxY = 0;
  _LayoutResult({required this.positions, required this.connections, required this.genLabels});
}

class _Connection {
  final String fromId, toId;
  final bool isSpouse;
  const _Connection({required this.fromId, required this.toId, required this.isSpouse});
}

_LayoutResult _buildLayout(Mtu root, FamiliaProvider prov) {
  final positions = <String, Offset>{};
  final connections = <_Connection>[];
  final genLabels = <String, double>{};
  final visited = <String>{};
  double maxX = 0, maxY = 0;

  // Recursive subtree width calculator
  double _subtreeWidth(String id, Set<String> vis) {
    if (vis.contains(id)) return _nodeD.toDouble();
    vis.add(id);
    final children = prov.watotoWa(id);
    final wenzi = prov.wenziWa(id);
    // spouse offset
    final spouseExtra = wenzi.isEmpty ? 0.0 : (_spouseW + _nodeD);
    if (children.isEmpty) return max(_nodeD + spouseExtra, _nodeD.toDouble());
    double w = 0;
    for (final c in children) { w += _subtreeWidth(c.id, {...vis}); }
    w += _hGap * (children.length - 1);
    return max(w + spouseExtra, _nodeD.toDouble());
  }

  void _layout(String id, double cx, double cy, Set<String> vis) {
    if (vis.contains(id)) return;
    vis.add(id);
    positions[id] = Offset(cx, cy);
    maxX = max(maxX, cx + _nodeR);
    maxY = max(maxY, cy + _nodeR);

    final m = prov.watu[id];
    if (m == null) return;

    // Place spouse(s)
    double spouseOffsetX = cx;
    for (final sp in prov.wenziWa(id)) {
      spouseOffsetX += _spouseW + _nodeD;
      if (!vis.contains(sp.id)) {
        positions[sp.id] = Offset(spouseOffsetX, cy);
        vis.add(sp.id);
        maxX = max(maxX, spouseOffsetX + _nodeR);
        connections.add(_Connection(fromId: id, toId: sp.id, isSpouse: true));
      }
    }

    // Place children
    final children = prov.watotoWa(id);
    if (children.isEmpty) return;

    // Total width needed for children
    double total = 0;
    final widths = <double>[];
    for (final c in children) {
      final w = _subtreeWidth(c.id, <String>{...vis});
      widths.add(w);
      total += w;
    }
    total += _hGap * (children.length - 1);

    // Mid-point between node and its spouse(s)
    double midX = positions[id]!.dx;
    if (m.wenzi.isNotEmpty) {
      double lastSpouseX = positions[m.wenzi.last]!.dx;
      midX = (positions[id]!.dx + lastSpouseX) / 2;
    }

    double startX = midX - total / 2 + widths[0] / 2;
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final childX = startX;
      final childY = cy + _genH;
      _layout(child.id, childX, childY, vis);
      connections.add(_Connection(fromId: id, toId: child.id, isSpouse: false));
      if (i + 1 < children.length) {
        startX += widths[i] / 2 + _hGap + widths[i + 1] / 2;
      }
    }
  }

  // Generation label names
  const genNames = ['Babu Mkubwa', 'Babu na Bibi', 'Wazazi', 'Watoto', 'Wajukuu', 'Kizazi cha 6'];

  _layout(root.id, 400, 80, visited);

  // Determine generations from y positions
  final ys = positions.values.map((p) => p.dy).toSet().toList()..sort();
  for (int i = 0; i < ys.length; i++) {
    genLabels[i < genNames.length ? genNames[i] : 'Kizazi ${i + 1}'] = ys[i];
  }

  final result = _LayoutResult(positions: positions, connections: connections, genLabels: genLabels);
  result.maxX = maxX; result.maxY = maxY;
  return result;
}

// ──────────────────────────────────────────────────────
//  Connection painter (SVG-style lines)
// ──────────────────────────────────────────────────────
class _ConnectionPainter extends CustomPainter {
  final Map<String, Offset> positions;
  final List<_Connection> connections;
  final Set<String>? highlighted;

  const _ConnectionPainter({required this.positions, required this.connections, required this.highlighted});

  @override
  void paint(Canvas canvas, Size size) {
    final spousePaint = Paint()
      ..color = AppColors.bark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final parentPaint = Paint()
      ..color = AppColors.forestMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final dimPaint = Paint()
      ..color = AppColors.bark.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spouseDash = [6.0, 3.0];

    for (final conn in connections) {
      final from = positions[conn.fromId];
      final to = positions[conn.toId];
      if (from == null || to == null) continue;

      final isDim = highlighted != null &&
          (!highlighted!.contains(conn.fromId) || !highlighted!.contains(conn.toId));

      if (conn.isSpouse) {
        final paint = isDim ? dimPaint : spousePaint;
        _drawDashed(canvas, from, to, paint, spouseDash);
        // Heart in middle
        if (!isDim) {
          final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
          canvas.drawCircle(mid, 6, Paint()..color = AppColors.bark.withOpacity(0.6));
          final tp = TextPainter(
            text: const TextSpan(text: '♥', style: TextStyle(fontSize: 10, color: Colors.white)),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
        }
      } else {
        // Parent-child elbow
        final paint = isDim ? dimPaint : parentPaint;
        final midY = (from.dy + to.dy) / 2;
        final path = Path()
          ..moveTo(from.dx, from.dy + _nodeR)
          ..lineTo(from.dx, midY)
          ..lineTo(to.dx, midY)
          ..lineTo(to.dx, to.dy - _nodeR);
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint, List<double> dash) {
    final dx = to.dx - from.dx, dy = to.dy - from.dy;
    final len = sqrt(dx * dx + dy * dy);
    final ux = dx / len, uy = dy / len;
    double dist = 0;
    bool drawing = true;
    while (dist < len) {
      final seg = drawing ? dash[0] : dash[1];
      final end = min(dist + seg, len);
      if (drawing) {
        canvas.drawLine(
          Offset(from.dx + ux * dist, from.dy + uy * dist),
          Offset(from.dx + ux * end, from.dy + uy * end),
          paint,
        );
      }
      dist = end;
      drawing = !drawing;
    }
  }

  @override bool shouldRepaint(covariant _ConnectionPainter old) =>
    old.highlighted != highlighted || old.connections != connections;
}

// ──────────────────────────────────────────────────────
//  Control bar
// ──────────────────────────────────────────────────────
class _ControlBar extends StatelessWidget {
  final List<Mtu> watu;
  final String rootId;
  final ValueChanged<String> onRootChanged;
  final VoidCallback onCenter;
  final String? selectedId;
  final VoidCallback onClearSelection;

  const _ControlBar({
    required this.watu, required this.rootId,
    required this.onRootChanged, required this.onCenter,
    required this.selectedId, required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.parchmentDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.account_tree, color: AppColors.forestMid, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.forestLight.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: rootId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                  items: watu.map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.jilaKamili, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (id) { if (id != null) onRootChanged(id); },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: AppColors.forestMid),
            tooltip: 'Rudisha Katikati',
            onPressed: onCenter,
            padding: EdgeInsets.zero, iconSize: 22,
          ),
          if (selectedId != null)
            TextButton.icon(
              onPressed: onClearSelection,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Futa Chaguo', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.forestMid,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Legend bar (matches HTML footer)
// ──────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final String? selectedId;
  final FamiliaProvider provider;

  const _Legend({required this.selectedId, required this.provider});

  @override
  Widget build(BuildContext context) {
    final m = selectedId != null ? provider.watu[selectedId] : null;

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.forest, AppColors.forestMid],
        ),
      ),
      child: m != null
          ? Center(
              child: Text(
                '${m.jinsia == "Kike" ? "👩" : "👨"} ${m.jilaKamili} amechaguliwa · Gusa tena kuona maelezo',
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontStyle: FontStyle.italic),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(color: AppColors.male, label: 'Mwanaume'),
                _LegendItem(color: AppColors.female, label: 'Mwanamke', female: true),
                _LegendSpouse(),
                _LegendParent(),
              ],
            ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool female;
  const _LegendItem({required this.color, required this.label, this.female = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _LegendSpouse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28, height: 3,
          child: CustomPaint(painter: _DashPainter()),
        ),
        const SizedBox(width: 6),
        const Text('Mke/Mume', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bark..strokeWidth = 2.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height/2), Offset(min(x+5, size.width), size.height/2), paint);
      x += 8;
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _LegendParent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 3, color: AppColors.forestLight),
        const SizedBox(width: 6),
        const Text('Mzazi-Mtoto', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
