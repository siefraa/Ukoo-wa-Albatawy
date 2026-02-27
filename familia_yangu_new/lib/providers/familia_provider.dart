import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/mtu.dart';
import '../models/mtumiaji_auth.dart';

class FamiliaProvider extends ChangeNotifier {
  Map<String, Mtu> _watu = {};
  MtumiajiAuth? _mtumiaji;
  bool _imepakia = false;
  String _utafutaji = '';
  String? _mtuChaguliwa; // selected node in tree

  final _uuid = const Uuid();

  // ── Getters ──
  Map<String, Mtu> get watu => _watu;
  MtumiajiAuth? get mtumiaji => _mtumiaji;
  bool get imeingia => _mtumiaji != null;
  bool get imepakia => _imepakia;
  String? get mtuChaguliwa => _mtuChaguliwa;

  List<Mtu> get watuwote => _watu.values.toList()
    ..sort((a, b) => a.jina.compareTo(b.jina));

  List<Mtu> get matokeoUtafutaji {
    if (_utafutaji.isEmpty) return watuwote;
    final q = _utafutaji.toLowerCase();
    return watuwote.where((m) =>
      m.jilaKamili.toLowerCase().contains(q) ||
      (m.simu?.contains(q) ?? false) ||
      (m.barua_pepe?.toLowerCase().contains(q) ?? false) ||
      (m.mahali_kuzaliwa?.toLowerCase().contains(q) ?? false) ||
      (m.ukoo?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  void badilishaUtafutaji(String q) {
    _utafutaji = q;
    notifyListeners();
  }

  void chaguaMtu(String? id) {
    _mtuChaguliwa = _mtuChaguliwa == id ? null : id;
    notifyListeners();
  }

  void futa_chaguo() {
    _mtuChaguliwa = null;
    notifyListeners();
  }

  FamiliaProvider() { _pakia(); }

  // ── PERSISTENCE ──
  Future<void> _pakia() async {
    final p = await SharedPreferences.getInstance();
    final authJson = p.getString('auth_v2');
    if (authJson != null) {
      try { _mtumiaji = MtumiajiAuth.fromJson(jsonDecode(authJson)); } catch (_) {}
    }
    await _pakiaData();
    _imepakia = true;
    notifyListeners();
  }

  Future<void> _pakiaData() async {
    final p = await SharedPreferences.getInstance();
    final key = 'data_${_mtumiaji?.id ?? "guest"}';
    final raw = p.getString(key);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _watu = m.map((k, v) => MapEntry(k, Mtu.fromJson(v)));
      } catch (_) {}
    }
  }

  Future<void> _hifadhi() async {
    final p = await SharedPreferences.getInstance();
    final key = 'data_${_mtumiaji?.id ?? "guest"}';
    final enc = _watu.map((k, v) => MapEntry(k, v.toJson()));
    await p.setString(key, jsonEncode(enc));
  }

  // ── AUTH ──
  static String _hash(String s) {
    var h = 5381;
    for (var c in s.codeUnits) { h = ((h << 5) + h + c) & 0x7FFFFFFF; }
    return h.toRadixString(16);
  }

  Future<String?> jiandikisha({required String jina, required String neno, String? familiaJina}) async {
    final p = await SharedPreferences.getInstance();
    final all = p.getStringList('users_v2') ?? [];
    for (final u in all) {
      final parsed = MtumiajiAuth.fromJson(jsonDecode(u));
      if (parsed.jina.toLowerCase() == jina.toLowerCase()) return 'Jina "$jina" limetumika tayari';
    }
    final user = MtumiajiAuth(
      id: _uuid.v4(),
      jina: jina,
      neno_siri_hash: _hash(neno),
      familia_jina: familiaJina?.isNotEmpty == true ? familiaJina : 'Familia ya $jina',
      tarehe_kujiandikisha: DateTime.now(),
    );
    all.add(jsonEncode(user.toJson()));
    await p.setStringList('users_v2', all);
    await p.setString('auth_v2', jsonEncode(user.toJson()));
    _mtumiaji = user;
    _watu = {};
    notifyListeners();
    return null;
  }

  Future<String?> ingia({required String jina, required String neno}) async {
    final p = await SharedPreferences.getInstance();
    final all = p.getStringList('users_v2') ?? [];
    for (final u in all) {
      final parsed = MtumiajiAuth.fromJson(jsonDecode(u));
      if (parsed.jina.toLowerCase() == jina.toLowerCase() && parsed.neno_siri_hash == _hash(neno)) {
        _mtumiaji = parsed;
        await p.setString('auth_v2', jsonEncode(parsed.toJson()));
        await _pakiaData();
        notifyListeners();
        return null;
      }
    }
    return 'Jina au neno siri si sahihi';
  }

  Future<void> toka() async {
    (await SharedPreferences.getInstance()).remove('auth_v2');
    _mtumiaji = null;
    _watu = {};
    _mtuChaguliwa = null;
    notifyListeners();
  }

  // ── CRUD ──
  Future<Mtu> ongezaMtu({
    required String jina,
    String? jinaMwingine,
    String? ukoo,
    String? tarehe_kuzaliwa,
    String? tarehe_kufa,
    String? mahali_kuzaliwa,
    String jinsia = 'Kiume',
    String? simu,
    String? barua_pepe,
    String? maelezo,
  }) async {
    final m = Mtu(
      id: _uuid.v4(),
      jina: jina, jinaMwingine: jinaMwingine, ukoo: ukoo,
      tarehe_kuzaliwa: tarehe_kuzaliwa, tarehe_kufa: tarehe_kufa,
      mahali_kuzaliwa: mahali_kuzaliwa, jinsia: jinsia,
      simu: simu, barua_pepe: barua_pepe, maelezo: maelezo,
    );
    _watu[m.id] = m;
    await _hifadhi();
    notifyListeners();
    return m;
  }

  Future<void> badilishaTaarifa(Mtu m) async {
    _watu[m.id] = m;
    await _hifadhi();
    notifyListeners();
  }

  Future<void> futaMtu(String id) async {
    final m = _watu[id];
    if (m == null) return;
    for (final cid in m.watoto) { _watu[cid]?.wazazi.remove(id); }
    for (final pid in m.wazazi) { _watu[pid]?.watoto.remove(id); }
    for (final sid in m.wenzi) { _watu[sid]?.wenzi.remove(id); }
    _watu.remove(id);
    if (_mtuChaguliwa == id) _mtuChaguliwa = null;
    await _hifadhi();
    notifyListeners();
  }

  // ── RELATIONSHIPS ──
  Future<void> ongezaMtoto({required String mzaziId, required String mtotoId}) async {
    if (!_watu.containsKey(mzaziId) || !_watu.containsKey(mtotoId)) return;
    if (!_watu[mzaziId]!.watoto.contains(mtotoId)) _watu[mzaziId]!.watoto.add(mtotoId);
    if (!_watu[mtotoId]!.wazazi.contains(mzaziId)) _watu[mtotoId]!.wazazi.add(mzaziId);
    await _hifadhi(); notifyListeners();
  }

  Future<void> ongezaMzazi({required String mtotoId, required String mzaziId}) =>
      ongezaMtoto(mzaziId: mzaziId, mtotoId: mtotoId);

  Future<void> ongezaMwenzi({required String id1, required String id2}) async {
    if (!_watu.containsKey(id1) || !_watu.containsKey(id2)) return;
    if (!_watu[id1]!.wenzi.contains(id2)) _watu[id1]!.wenzi.add(id2);
    if (!_watu[id2]!.wenzi.contains(id1)) _watu[id2]!.wenzi.add(id1);
    await _hifadhi(); notifyListeners();
  }

  Future<void> ondoaUhusiano({required String id1, required String id2, required String aina}) async {
    if (aina == 'mwenzi') {
      _watu[id1]?.wenzi.remove(id2);
      _watu[id2]?.wenzi.remove(id1);
    } else if (aina == 'mtoto') {
      _watu[id1]?.watoto.remove(id2);
      _watu[id2]?.wazazi.remove(id1);
    } else if (aina == 'mzazi') {
      _watu[id1]?.wazazi.remove(id2);
      _watu[id2]?.watoto.remove(id1);
    }
    await _hifadhi(); notifyListeners();
  }

  // ── HELPERS ──
  List<Mtu> watotoWa(String id) =>
      (_watu[id]?.watoto ?? []).map((i) => _watu[i]).whereType<Mtu>().toList();
  List<Mtu> wazaziWa(String id) =>
      (_watu[id]?.wazazi ?? []).map((i) => _watu[i]).whereType<Mtu>().toList();
  List<Mtu> wenziWa(String id) =>
      (_watu[id]?.wenzi ?? []).map((i) => _watu[i]).whereType<Mtu>().toList();

  List<Mtu> nduguWa(String id) {
    final m = _watu[id];
    if (m == null) return [];
    final Set<String> ids = {};
    for (final pid in m.wazazi) {
      for (final cid in _watu[pid]?.watoto ?? []) {
        if (cid != id) ids.add(cid);
      }
    }
    return ids.map((i) => _watu[i]).whereType<Mtu>().toList();
  }

  List<Mtu> get mizizi => _watu.values.where((m) => m.wazazi.isEmpty).toList();

  /// Returns all IDs related to [id] (for tree highlight)
  Set<String> wahusikaoNa(String id) {
    final rel = <String>{id};
    final m = _watu[id];
    if (m == null) return rel;
    for (final sid in m.wenzi) { rel.add(sid); }
    for (final pid in m.wazazi) {
      rel.add(pid);
      rel.addAll(_watu[pid]?.wenzi ?? []);
    }
    for (final cid in m.watoto) {
      rel.add(cid);
      rel.addAll(_watu[cid]?.wenzi ?? []);
    }
    // also include person's own spouse's parents
    for (final sid in m.wenzi) {
      for (final pid in _watu[sid]?.wazazi ?? []) { rel.add(pid); }
    }
    return rel;
  }

  String uhusianoNi(String sourceId, String targetId) {
    final s = _watu[sourceId];
    final t = _watu[targetId];
    if (s == null || t == null) return 'Haijulikani';

    if (s.wenzi.contains(targetId)) {
      return t.jinsia == 'Kike' ? 'Mke' : 'Mume';
    }
    if (s.wazazi.contains(targetId)) {
      return t.jinsia == 'Kike' ? 'Mama' : 'Baba';
    }
    if (s.watoto.contains(targetId)) {
      return t.jinsia == 'Kike' ? 'Binti' : 'Mwana';
    }
    // sibling
    for (final pid in s.wazazi) {
      if (t.wazazi.contains(pid)) {
        return t.jinsia == 'Kike' ? 'Dada' : 'Kaka';
      }
    }
    // grandparent
    for (final pid in s.wazazi) {
      if (_watu[pid]?.wazazi.contains(targetId) == true) {
        return t.jinsia == 'Kike' ? 'Nyanya' : 'Babu';
      }
    }
    // grandchild
    for (final cid in s.watoto) {
      if (_watu[cid]?.watoto.contains(targetId) == true) {
        return t.jinsia == 'Kike' ? 'Mjukuu (msichana)' : 'Mjukuu (mvulana)';
      }
    }
    return 'Mwanafamilia';
  }

  // ── IMPORT / EXPORT ──
  String exportJson() {
    return jsonEncode({
      'app': 'FamiliaYangu',
      'version': '2.0',
      'familia': _mtumiaji?.familia_jina ?? 'Familia',
      'tarehe': DateTime.now().toIso8601String(),
      'watu': _watu.map((k, v) => MapEntry(k, v.toJson())),
    });
  }

  Future<String?> importJson(String raw) async {
    try {
      final dec = jsonDecode(raw) as Map<String, dynamic>;
      final watuMap = dec['watu'] as Map<String, dynamic>;
      _watu = watuMap.map((k, v) => MapEntry(k, Mtu.fromJson(v)));
      await _hifadhi();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Hitilafu: $e';
    }
  }

  Future<void> futaDataYote() async {
    _watu = {};
    _mtuChaguliwa = null;
    await _hifadhi();
    notifyListeners();
  }
}
