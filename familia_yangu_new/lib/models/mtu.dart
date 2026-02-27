class Mtu {
  final String id;
  String jina;
  String? jinaMwingine;
  String? ukoo;
  String? tarehe_kuzaliwa;
  String? tarehe_kufa;
  String? mahali_kuzaliwa;
  String jinsia; // 'Kiume' | 'Kike'
  String? simu;
  String? barua_pepe;
  String? maelezo;
  String? picha; // reserved

  List<String> watoto;
  List<String> wazazi;
  List<String> wenzi;

  Mtu({
    required this.id,
    required this.jina,
    this.jinaMwingine,
    this.ukoo,
    this.tarehe_kuzaliwa,
    this.tarehe_kufa,
    this.mahali_kuzaliwa,
    this.jinsia = 'Kiume',
    this.simu,
    this.barua_pepe,
    this.maelezo,
    this.picha,
    List<String>? watoto,
    List<String>? wazazi,
    List<String>? wenzi,
  })  : watoto = watoto ?? [],
        wazazi = wazazi ?? [],
        wenzi = wenzi ?? [];

  String get jilaKamili {
    final parts = [jina, if (jinaMwingine?.isNotEmpty == true) jinaMwingine!, if (ukoo?.isNotEmpty == true) ukoo!];
    return parts.join(' ');
  }

  String get herufiKwanza => jina.isNotEmpty ? jina[0].toUpperCase() : '?';
  bool get amefariki => tarehe_kufa?.isNotEmpty == true;

  int? get umri {
    if (tarehe_kuzaliwa == null || tarehe_kuzaliwa!.isEmpty) return null;
    try {
      // try parse year from string like "1950" or "15 Jan 1950"
      final parts = tarehe_kuzaliwa!.split(RegExp(r'[\s/\-,]+'));
      for (final p in parts.reversed) {
        final y = int.tryParse(p);
        if (y != null && y > 1000 && y <= DateTime.now().year) {
          final endYear = amefariki
              ? () {
                  final dp = tarehe_kufa!.split(RegExp(r'[\s/\-,]+'));
                  for (final x in dp.reversed) {
                    final y2 = int.tryParse(x);
                    if (y2 != null && y2 > 1000) return y2;
                  }
                  return DateTime.now().year;
                }()
              : DateTime.now().year;
          return endYear - y;
        }
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jina': jina,
        'jinaMwingine': jinaMwingine,
        'ukoo': ukoo,
        'tarehe_kuzaliwa': tarehe_kuzaliwa,
        'tarehe_kufa': tarehe_kufa,
        'mahali_kuzaliwa': mahali_kuzaliwa,
        'jinsia': jinsia,
        'simu': simu,
        'barua_pepe': barua_pepe,
        'maelezo': maelezo,
        'picha': picha,
        'watoto': watoto,
        'wazazi': wazazi,
        'wenzi': wenzi,
      };

  factory Mtu.fromJson(Map<String, dynamic> j) => Mtu(
        id: j['id'],
        jina: j['jina'],
        jinaMwingine: j['jinaMwingine'],
        ukoo: j['ukoo'],
        tarehe_kuzaliwa: j['tarehe_kuzaliwa'],
        tarehe_kufa: j['tarehe_kufa'],
        mahali_kuzaliwa: j['mahali_kuzaliwa'],
        jinsia: j['jinsia'] ?? 'Kiume',
        simu: j['simu'],
        barua_pepe: j['barua_pepe'],
        maelezo: j['maelezo'],
        picha: j['picha'],
        watoto: List<String>.from(j['watoto'] ?? []),
        wazazi: List<String>.from(j['wazazi'] ?? []),
        wenzi: List<String>.from(j['wenzi'] ?? []),
      );

  Mtu copy() => Mtu.fromJson(toJson());
}
