import '../models/order_item.dart';
import '../models/motif_order.dart';
import '../models/formula.dart';
import '../utils/constants.dart';

class CalculatorService {
  /// Kain lookup maps (bisa di-override dari database)
  Map<int, double> kainNormal;
  Map<int, double> kainTinggi30;

  /// Ongkos configs (bisa di-override dari database)
  List<OngkosConfig> ongkosConfigs;

  CalculatorService({
    Map<int, double>? kainNormal,
    Map<int, double>? kainTinggi30,
    List<OngkosConfig>? ongkosConfigs,
  })  : kainNormal = kainNormal ?? Map.from(defaultKainNormal),
        kainTinggi30 = kainTinggi30 ?? Map.from(defaultKainTinggi30),
        ongkosConfigs = ongkosConfigs ??
            [
              OngkosConfig(ukuranMin: 90, ukuranMax: 120, harga: ongkosKecil),
              OngkosConfig(ukuranMin: 140, ukuranMax: 200, harga: ongkosBesar),
            ];

  /// Hitung semua field pada OrderItem berdasarkan ukuran, pcs, dan tinggi30
  OrderItem calculate(OrderItem item) {
    // Lookup kain per pcs
    final kainMap = item.isTinggi30 ? kainTinggi30 : kainNormal;
    final kainPerPcs = kainMap[item.ukuran] ?? 0.0;

    // Total kain
    final totalKain = item.pcs * kainPerPcs;

    // Ongkos per pcs
    final ongkosPerPcs = _getOngkos(item.ukuran);

    // Total ongkos
    final totalOngkos = item.pcs * ongkosPerPcs;

    // Total bantal/guling
    final totalBantal = _getTotalBantal(item.ukuran, item.pcs);

    return item.copyWith(
      kainPerPcs: kainPerPcs,
      totalKain: totalKain,
      ongkosPerPcs: ongkosPerPcs,
      totalOngkos: totalOngkos,
      totalBantal: totalBantal,
    );
  }

  /// Hitung semua item dalam MotifOrder
  MotifOrder calculateMotif(MotifOrder motif) {
    final calculatedItems = motif.items.map(calculate).toList();
    return motif.copyWith(items: calculatedItems);
  }

  /// Hitung semua motif
  List<MotifOrder> calculateAll(List<MotifOrder> motifs) {
    return motifs.map(calculateMotif).toList();
  }

  /// Dapatkan ongkos jahit per pcs berdasarkan ukuran
  int _getOngkos(int ukuran) {
    for (final config in ongkosConfigs) {
      if (ukuran >= config.ukuranMin && ukuran <= config.ukuranMax) {
        return config.harga;
      }
    }
    // Default: ukuran besar
    return ongkosBesar;
  }

  /// Hitung total bantal/guling
  /// Ukuran 90-120: pcs ÷ 2
  /// Ukuran 140-200: pcs langsung
  double _getTotalBantal(int ukuran, int pcs) {
    if (ukuran <= batasUkuranKecil) {
      return pcs / 2.0;
    }
    return pcs.toDouble();
  }

  /// Update kain lookup dari database formulas
  void updateFormulas(List<Formula> formulas) {
    for (final f in formulas) {
      if (f.isTinggi30) {
        kainTinggi30[f.ukuran] = f.kainMeter;
      } else {
        kainNormal[f.ukuran] = f.kainMeter;
      }
    }
  }

  /// Update ongkos configs
  void updateOngkos(List<OngkosConfig> configs) {
    ongkosConfigs = configs;
  }
}
