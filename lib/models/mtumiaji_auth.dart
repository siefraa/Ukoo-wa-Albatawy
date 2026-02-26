class MtumiajiAuth {
  final String id;
  String jina;
  String neno_siri_hash;
  String? familia_jina;
  DateTime tarehe_kujiandikisha;

  MtumiajiAuth({
    required this.id,
    required this.jina,
    required this.neno_siri_hash,
    this.familia_jina,
    required this.tarehe_kujiandikisha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'jina': jina,
        'neno_siri_hash': neno_siri_hash,
        'familia_jina': familia_jina,
        'tarehe_kujiandikisha': tarehe_kujiandikisha.toIso8601String(),
      };

  factory MtumiajiAuth.fromJson(Map<String, dynamic> j) => MtumiajiAuth(
        id: j['id'],
        jina: j['jina'],
        neno_siri_hash: j['neno_siri_hash'],
        familia_jina: j['familia_jina'],
        tarehe_kujiandikisha: DateTime.parse(j['tarehe_kujiandikisha']),
      );
}
