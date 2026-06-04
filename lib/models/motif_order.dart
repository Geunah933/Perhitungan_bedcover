import 'order_item.dart';

class MotifOrder {
  int? id;
  int? orderId;
  String namaMotif;
  List<OrderItem> items;

  MotifOrder({
    this.id,
    this.orderId,
    required this.namaMotif,
    List<OrderItem>? items,
  }) : items = items ?? [];

  double get totalKain =>
      items.fold(0.0, (sum, item) => sum + item.totalKain);

  int get totalOngkos =>
      items.fold(0, (sum, item) => sum + item.totalOngkos);

  double get totalBantal =>
      items.fold(0.0, (sum, item) => sum + item.totalBantal);

  int get totalPcs =>
      items.fold(0, (sum, item) => sum + item.pcs);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'nama_motif': namaMotif,
    };
  }

  factory MotifOrder.fromMap(Map<String, dynamic> map, {List<OrderItem>? items}) {
    return MotifOrder(
      id: map['id'] as int?,
      orderId: map['order_id'] as int?,
      namaMotif: map['nama_motif'] as String,
      items: items ?? [],
    );
  }

  MotifOrder copyWith({
    int? id,
    int? orderId,
    String? namaMotif,
    List<OrderItem>? items,
  }) {
    return MotifOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      namaMotif: namaMotif ?? this.namaMotif,
      items: items ?? List.from(this.items),
    );
  }
}
