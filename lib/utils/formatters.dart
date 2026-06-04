import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Initialize Indonesian locale data
Future<void> initLocale() async {
  await initializeDateFormatting('id_ID', null);
}

/// Format Rupiah: 540000 → "Rp540.000"
String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

/// Format meter: 99.36 → "99,36 m"
String formatMeter(double meter) {
  final formatter = NumberFormat('#,##0.##', 'id_ID');
  return '${formatter.format(meter)} m';
}

/// Format decimal: 3.5 → "3,5"
String formatDecimal(double value) {
  final formatter = NumberFormat('#,##0.##', 'id_ID');
  return formatter.format(value);
}

/// Format tanggal lengkap: "Selasa, 2 Juni 2026"
String formatTanggalLengkap(DateTime date) {
  final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  return formatter.format(date);
}

/// Format tanggal pendek: "2 Jun 2026"
String formatTanggalPendek(DateTime date) {
  final formatter = DateFormat('d MMM yyyy', 'id_ID');
  return formatter.format(date);
}

/// Format hari saja: "Senin", "Selasa"
String formatHari(DateTime date) {
  final formatter = DateFormat('EEEE', 'id_ID');
  return formatter.format(date);
}

/// Format rentang minggu: "Senin 1 Juni – Sabtu 6 Juni"
String formatRentangMinggu(DateTime senin, DateTime sabtu) {
  final fmtHari = DateFormat('EEEE', 'id_ID');
  final fmtTanggal = DateFormat('d MMMM', 'id_ID');
  return '${fmtHari.format(senin)} ${fmtTanggal.format(senin)} – '
      '${fmtHari.format(sabtu)} ${fmtTanggal.format(sabtu)}';
}
