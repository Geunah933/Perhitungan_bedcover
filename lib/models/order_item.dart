class OrderItem {
  int? id;
  int? motifOrderId;
  int ukuran;
  int pcs;
  bool isTinggi30;
  double kainPerPcs;
  double totalKain;
  int ongkosPerPcs;
  int totalOngkos;
  double totalBantal;

  OrderItem({
    this.id,
    this.motifOrderId,
    required this.ukuran,
    required this.pcs,
    this.isTinggi30 = false,
    this.kainPerPcs = 0,
    this.totalKain = 0,
    this.ongkosPerPcs = 0,
    this.totalOngkos = 0,
    this.totalBantal = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'motif_order_id': motifOrderId,
      'ukuran': ukuran,
      'pcs': pcs,
      'is_tinggi_30': isTinggi30 ? 1 : 0,
      'kain_per_pcs': kainPerPcs,
      'total_kain': totalKain,
      'ongkos_per_pcs': ongkosPerPcs,
      'total_ongkos': totalOngkos,
      'total_bantal': totalBantal,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      motifOrderId: map['motif_order_id'] as int?,
      ukuran: map['ukuran'] as int,
      pcs: map['pcs'] as int,
      isTinggi30: (map['is_tinggi_30'] as int) == 1,
      kainPerPcs: (map['kain_per_pcs'] as num).toDouble(),
      totalKain: (map['total_kain'] as num).toDouble(),
      ongkosPerPcs: map['ongkos_per_pcs'] as int,
      totalOngkos: map['total_ongkos'] as int,
      totalBantal: (map['total_bantal'] as num).toDouble(),
    );
  }

  OrderItem copyWith({
    int? id,
    int? motifOrderId,
    int? ukuran,
    int? pcs,
    bool? isTinggi30,
    double? kainPerPcs,
    double? totalKain,
    int? ongkosPerPcs,
    int? totalOngkos,
    double? totalBantal,
  }) {
    return OrderItem(
      id: id ?? this.id,
      motifOrderId: motifOrderId ?? this.motifOrderId,
      ukuran: ukuran ?? this.ukuran,
      pcs: pcs ?? this.pcs,
      isTinggi30: isTinggi30 ?? this.isTinggi30,
      kainPerPcs: kainPerPcs ?? this.kainPerPcs,
      totalKain: totalKain ?? this.totalKain,
      ongkosPerPcs: ongkosPerPcs ?? this.ongkosPerPcs,
      totalOngkos: totalOngkos ?? this.totalOngkos,
      totalBantal: totalBantal ?? this.totalBantal,
    );
  }

  /// Label singkat: "120 tinggi 30" atau "160"
  String get label {
    final suffix = isTinggi30 ? ' tinggi 30' : '';
    return '$ukuran$suffix';
  }
}
