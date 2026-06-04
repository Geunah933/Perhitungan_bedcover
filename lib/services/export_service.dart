import '../models/order.dart';
import '../utils/formatters.dart';

class ExportService {
  /// Format satu Order lengkap untuk share/copy ke WhatsApp
  String formatOrder(Order order) {
    final buffer = StringBuffer();

    buffer.writeln(formatTanggalLengkap(order.tanggal));
    buffer.writeln();
    buffer.writeln(order.owner);
    buffer.writeln();

    for (final motif in order.motifs) {
      buffer.writeln(motif.namaMotif);
      buffer.writeln();
      buffer.writeln('Rincian Kain');

      for (final item in motif.items) {
        final label = item.isTinggi30
            ? '${item.ukuran} tinggi 30'
            : '${item.ukuran}';
        buffer.writeln(
          '$label (${item.pcs} pcs) = '
          '${item.pcs} × ${formatDecimal(item.kainPerPcs)} = '
          '${formatMeter(item.totalKain)}',
        );
      }

      buffer.writeln();
      buffer.writeln('Total Kain: ${formatMeter(motif.totalKain)}');
      buffer.writeln('Ongkos Jahit: ${formatRupiah(motif.totalOngkos)}');
      buffer.writeln('Total Bantal/Guling: ${formatDecimal(motif.totalBantal)}');
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  /// Format rekap harian untuk share
  String formatRekapHarian(DateTime tanggal, List<Order> orders) {
    final buffer = StringBuffer();
    buffer.writeln('REKAP HARIAN');
    buffer.writeln(formatTanggalLengkap(tanggal));
    buffer.writeln();

    // Group by owner
    final byOwner = <String, List<Order>>{};
    for (final order in orders) {
      byOwner.putIfAbsent(order.owner, () => []).add(order);
    }

    double totalKainGabungan = 0;
    int totalOngkosGabungan = 0;
    double totalBantalGabungan = 0;

    for (final entry in byOwner.entries) {
      buffer.writeln('━━━ ${entry.key} ━━━');
      buffer.writeln();

      double ownerKain = 0;
      int ownerOngkos = 0;
      double ownerBantal = 0;

      for (final order in entry.value) {
        for (final motif in order.motifs) {
          buffer.writeln('• ${motif.namaMotif}');
          ownerKain += motif.totalKain;
          ownerOngkos += motif.totalOngkos;
          ownerBantal += motif.totalBantal;
        }
      }

      buffer.writeln();
      buffer.writeln('Kain: ${formatMeter(ownerKain)}');
      buffer.writeln('Ongkos: ${formatRupiah(ownerOngkos)}');
      buffer.writeln('Bantal/Guling: ${formatDecimal(ownerBantal)}');
      buffer.writeln();

      totalKainGabungan += ownerKain;
      totalOngkosGabungan += ownerOngkos;
      totalBantalGabungan += ownerBantal;
    }

    buffer.writeln('━━━ TOTAL GABUNGAN ━━━');
    buffer.writeln('Kain: ${formatMeter(totalKainGabungan)}');
    buffer.writeln('Ongkos: ${formatRupiah(totalOngkosGabungan)}');
    buffer.writeln('Bantal/Guling: ${formatDecimal(totalBantalGabungan)}');

    return buffer.toString().trimRight();
  }

  /// Format rekap mingguan
  String formatRekapMingguan(
    DateTime senin,
    DateTime sabtu,
    Map<String, Map<DateTime, List<Order>>> data,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('REKAP MINGGUAN');
    buffer.writeln(formatRentangMinggu(senin, sabtu));
    buffer.writeln();

    double totalKainGabungan = 0;
    int totalOngkosGabungan = 0;
    double totalBantalGabungan = 0;

    for (final ownerEntry in data.entries) {
      buffer.writeln('━━━ ${ownerEntry.key} ━━━');
      buffer.writeln();

      double ownerKain = 0;
      int ownerOngkos = 0;
      double ownerBantal = 0;

      for (final dayEntry in ownerEntry.value.entries) {
        final dayOngkos = dayEntry.value.fold(0, (int s, o) => s + o.totalOngkos);
        buffer.writeln('${formatHari(dayEntry.key)}: ${formatRupiah(dayOngkos)}');

        for (final order in dayEntry.value) {
          ownerKain += order.totalKain;
          ownerOngkos += order.totalOngkos;
          ownerBantal += order.totalBantal;
        }
      }

      buffer.writeln();
      buffer.writeln('Total ${ownerEntry.key}');
      buffer.writeln('Kain: ${formatMeter(ownerKain)}');
      buffer.writeln('Ongkos Jahit: ${formatRupiah(ownerOngkos)}');
      buffer.writeln('Bantal/Guling: ${formatDecimal(ownerBantal)}');
      buffer.writeln();

      totalKainGabungan += ownerKain;
      totalOngkosGabungan += ownerOngkos;
      totalBantalGabungan += ownerBantal;
    }

    buffer.writeln('━━━ TOTAL GABUNGAN ━━━');
    buffer.writeln('Kain: ${formatMeter(totalKainGabungan)}');
    buffer.writeln('Ongkos Jahit: ${formatRupiah(totalOngkosGabungan)}');
    buffer.writeln('Bantal/Guling: ${formatDecimal(totalBantalGabungan)}');

    return buffer.toString().trimRight();
  }
}
