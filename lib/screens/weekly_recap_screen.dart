import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../app_theme.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/summary_card.dart';

class WeeklyRecapScreen extends StatefulWidget {
  const WeeklyRecapScreen({super.key});

  @override
  State<WeeklyRecapScreen> createState() => _WeeklyRecapScreenState();
}

class _WeeklyRecapScreenState extends State<WeeklyRecapScreen> {
  final _db = DatabaseService.instance;
  final _export = ExportService();
  late DateTime _weekStart; // Monday
  late DateTime _weekEnd; // Saturday
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setCurrentWeek();
    _loadData();
  }

  void _setCurrentWeek() {
    final now = DateTime.now();
    // Find Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(monday.year, monday.month, monday.day);
    _weekEnd = _weekStart.add(const Duration(days: 5)); // Saturday
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final orders = await _db.getOrdersInRange(_weekStart, _weekEnd);
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group by owner → by day
    final data = <String, Map<DateTime, List<Order>>>{};
    for (final order in _orders) {
      final dayKey = DateTime(
          order.tanggal.year, order.tanggal.month, order.tanggal.day);
      data
          .putIfAbsent(order.owner, () => {})
          .putIfAbsent(dayKey, () => [])
          .add(order);
    }

    // Grand totals
    final grandKain = _orders.fold(0.0, (s, o) => s + o.totalKain);
    final grandOngkos = _orders.fold(0, (s, o) => s + o.totalOngkos);
    final grandBantal = _orders.fold(0.0, (s, o) => s + o.totalBantal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Mingguan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_orders.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: _copyRekap,
              tooltip: 'Salin',
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: _shareRekap,
              tooltip: 'Bagikan',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Week navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _prevWeek,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: theme.colorScheme.outline, width: 0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Minggu Kerja',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatRentangMinggu(_weekStart, _weekEnd),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextWeek,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: theme.colorScheme.outline, width: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2))
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_rounded,
                                size: 48,
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada pesanan minggu ini',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          // Per owner
                          ...data.entries.map((ownerEntry) =>
                              _buildOwnerSection(
                                  ownerEntry.key, ownerEntry.value, theme)),

                          // Grand total
                          if (data.length > 1)
                            DarkGlassCard(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Gabungan',
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDarkRow('Kain', formatMeter(grandKain)),
                                  const SizedBox(height: 8),
                                  _buildDarkRow(
                                      'Ongkos Jahit', formatRupiah(grandOngkos)),
                                  const SizedBox(height: 8),
                                  _buildDarkRow('Bantal/Guling',
                                      formatDecimal(grandBantal)),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerSection(
      String owner, Map<DateTime, List<Order>> dayOrders, ThemeData theme) {
    final ownerKain =
        dayOrders.values.expand((l) => l).fold(0.0, (s, o) => s + o.totalKain);
    final ownerOngkos = dayOrders.values
        .expand((l) => l)
        .fold(0, (s, o) => s + o.totalOngkos);
    final ownerBantal = dayOrders.values
        .expand((l) => l)
        .fold(0.0, (s, o) => s + o.totalBantal);

    // Sort days
    final sortedDays = dayOrders.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: owner == 'Gilang'
                      ? const LinearGradient(
                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)])
                      : const LinearGradient(
                          colors: [Color(0xFF34C759), Color(0xFF30D158)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    owner[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(owner, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),

        // Day breakdown
        GlassCard(
          child: Column(
            children: [
              ...sortedDays.map((day) {
                final dayTotal = dayOrders[day]!
                    .fold(0, (int s, o) => s + o.totalOngkos);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatHari(day),
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        formatRupiah(dayTotal),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 20),
              SummaryCard(
                title: 'Total $owner',
                totalKain: ownerKain,
                totalOngkos: ownerOngkos,
                totalBantal: ownerBantal,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDarkRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _weekEnd = _weekEnd.subtract(const Duration(days: 7));
    });
    _loadData();
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _weekEnd = _weekEnd.add(const Duration(days: 7));
    });
    _loadData();
  }

  void _copyRekap() {
    final data = _buildExportData();
    final text = _export.formatRekapMingguan(_weekStart, _weekEnd, data);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rekap disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareRekap() {
    final data = _buildExportData();
    final text = _export.formatRekapMingguan(_weekStart, _weekEnd, data);
    Share.share(text);
  }

  Map<String, Map<DateTime, List<Order>>> _buildExportData() {
    final data = <String, Map<DateTime, List<Order>>>{};
    for (final order in _orders) {
      final dayKey = DateTime(
          order.tanggal.year, order.tanggal.month, order.tanggal.day);
      data
          .putIfAbsent(order.owner, () => {})
          .putIfAbsent(dayKey, () => [])
          .add(order);
    }
    return data;
  }
}
