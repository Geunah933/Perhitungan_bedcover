import '../models/order_item.dart';
import '../models/motif_order.dart';
import '../utils/constants.dart';

/// Hasil parsing satu line chat WhatsApp
class ParsedLine {
  final int ukuran;
  final int pcs;
  final bool isTinggi30;

  ParsedLine({
    required this.ukuran,
    required this.pcs,
    this.isTinggi30 = false,
  });
}

/// Warning yang muncul saat parsing (misal typo ukuran)
class ParseWarning {
  final String originalText;
  final int? suggestedUkuran;
  final String message;
  final int lineIndex;
  int? resolvedUkuran; // null = belum resolved

  ParseWarning({
    required this.originalText,
    this.suggestedUkuran,
    required this.message,
    required this.lineIndex,
    this.resolvedUkuran,
  });
}

/// Hasil parsing keseluruhan
class ParseResult {
  final List<MotifOrder> motifs;
  final List<ParseWarning> warnings;

  ParseResult({required this.motifs, required this.warnings});
}

class ParserService {
  /// Regex pattern untuk line item pesanan
  /// Matches: "90 4 pcs", "120 tinggi 30 3 pcs", "160 10pcs", "180 tinggi30 3pcs"
  static final RegExp _itemPattern = RegExp(
    r'^\s*(\d+)\s+(tinggi\s*30\s+)?(\d+)\s*pcs\s*$',
    caseSensitive: false,
  );

  /// Parse teks WhatsApp menjadi list MotifOrder + warnings
  ParseResult parse(String text) {
    final lines = text.split('\n');
    final motifs = <MotifOrder>[];
    final warnings = <ParseWarning>[];
    MotifOrder? currentMotif;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip empty lines
      if (line.isEmpty) continue;

      // Coba match sebagai item pesanan
      final match = _itemPattern.firstMatch(line);

      if (match != null) {
        final ukuranRaw = int.parse(match.group(1)!);
        final isTinggi30 = match.group(2) != null;
        final pcs = int.parse(match.group(3)!);

        // Validasi ukuran
        if (validUkuran.contains(ukuranRaw)) {
          // Ukuran valid
          final item = OrderItem(
            ukuran: ukuranRaw,
            pcs: pcs,
            isTinggi30: isTinggi30,
          );

          if (currentMotif == null) {
            // Tidak ada nama motif sebelumnya, buat default
            currentMotif = MotifOrder(namaMotif: 'Tanpa Nama');
            motifs.add(currentMotif);
          }
          currentMotif.items.add(item);
        } else {
          // Ukuran tidak valid → cari suggestion
          final suggested = _findClosestUkuran(ukuranRaw);
          warnings.add(ParseWarning(
            originalText: line,
            suggestedUkuran: suggested,
            message: 'Ukuran $ukuranRaw tidak dikenali.'
                '${suggested != null ? ' Apakah maksud Anda $suggested?' : ''}',
            lineIndex: i,
          ));

          // Tetap tambahkan item dengan ukuran suggested (jika ada)
          // Item ini akan di-flag untuk review di preview screen
          if (suggested != null && currentMotif != null) {
            final item = OrderItem(
              ukuran: suggested,
              pcs: pcs,
              isTinggi30: isTinggi30,
            );
            currentMotif.items.add(item);
          }
        }
      } else {
        // Bukan item pesanan → ini nama motif
        // Tapi pastikan bukan hanya angka random
        if (!_isJunkLine(line)) {
          currentMotif = MotifOrder(namaMotif: line);
          motifs.add(currentMotif);
        }
      }
    }

    return ParseResult(motifs: motifs, warnings: warnings);
  }

  /// Cari ukuran terdekat yang valid dari input salah
  int? _findClosestUkuran(int input) {
    // Strategi 1: Hapus digit berulang
    // 1220 → 120, 900 → 90, 1100 → 100
    final str = input.toString();

    // Coba hapus 1 digit berulang
    for (int i = 0; i < str.length; i++) {
      final reduced = str.substring(0, i) + str.substring(i + 1);
      if (reduced.isNotEmpty) {
        final val = int.tryParse(reduced);
        if (val != null && validUkuran.contains(val)) return val;
      }
    }

    // Coba tambah 0
    final withZero = input * 10;
    if (validUkuran.contains(withZero)) return withZero;

    // Coba hapus 0
    if (input % 10 == 0) {
      final withoutZero = input ~/ 10;
      if (validUkuran.contains(withoutZero)) return withoutZero;
    }

    // Strategi 2: Cari ukuran terdekat secara numerik
    int? closest;
    int minDiff = 999999;
    for (final valid in validUkuran) {
      final diff = (input - valid).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = valid;
      }
    }

    // Hanya suggest jika cukup dekat (within 30% of the value)
    if (closest != null && minDiff < closest * 0.3) {
      return closest;
    }

    return closest; // Return closest anyway, user can reject
  }

  /// Cek apakah line adalah "junk" (bukan nama motif yang valid)
  bool _isJunkLine(String line) {
    // Line yang hanya berisi angka tanpa konteks
    if (RegExp(r'^\d+$').hasMatch(line)) return true;
    // Line yang terlalu pendek (1 karakter)
    if (line.length < 2) return true;
    return false;
  }
}
