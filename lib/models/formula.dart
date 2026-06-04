class Formula {
  int? id;
  int ukuran;
  bool isTinggi30;
  double kainMeter;

  Formula({
    this.id,
    required this.ukuran,
    this.isTinggi30 = false,
    required this.kainMeter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ukuran': ukuran,
      'is_tinggi_30': isTinggi30 ? 1 : 0,
      'kain_meter': kainMeter,
    };
  }

  factory Formula.fromMap(Map<String, dynamic> map) {
    return Formula(
      id: map['id'] as int?,
      ukuran: map['ukuran'] as int,
      isTinggi30: (map['is_tinggi_30'] as int) == 1,
      kainMeter: (map['kain_meter'] as num).toDouble(),
    );
  }
}

class OngkosConfig {
  int? id;
  int ukuranMin;
  int ukuranMax;
  int harga;

  OngkosConfig({
    this.id,
    required this.ukuranMin,
    required this.ukuranMax,
    required this.harga,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ukuran_min': ukuranMin,
      'ukuran_max': ukuranMax,
      'harga': harga,
    };
  }

  factory OngkosConfig.fromMap(Map<String, dynamic> map) {
    return OngkosConfig(
      id: map['id'] as int?,
      ukuranMin: map['ukuran_min'] as int,
      ukuranMax: map['ukuran_max'] as int,
      harga: map['harga'] as int,
    );
  }
}
