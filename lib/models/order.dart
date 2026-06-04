import 'motif_order.dart';

class Order {
  int? id;
  String owner;
  DateTime tanggal;
  DateTime? createdAt;
  List<MotifOrder> motifs;

  Order({
    this.id,
    required this.owner,
    required this.tanggal,
    this.createdAt,
    List<MotifOrder>? motifs,
  }) : motifs = motifs ?? [];

  double get totalKain =>
      motifs.fold(0.0, (sum, m) => sum + m.totalKain);

  int get totalOngkos =>
      motifs.fold(0, (sum, m) => sum + m.totalOngkos);

  double get totalBantal =>
      motifs.fold(0.0, (sum, m) => sum + m.totalBantal);

  int get totalPcs =>
      motifs.fold(0, (sum, m) => sum + m.totalPcs);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner': owner,
      'tanggal': tanggal.toIso8601String().split('T').first,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, {List<MotifOrder>? motifs}) {
    return Order(
      id: map['id'] as int?,
      owner: map['owner'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      motifs: motifs ?? [],
    );
  }
}
