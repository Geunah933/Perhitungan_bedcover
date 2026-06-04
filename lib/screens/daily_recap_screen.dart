import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../app_theme.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/summary_card.dart';
import 'detail_screen.dart';

class DailyRecapScreen extends StatefulWidget {
  final DateTime? initialDate;

  const DailyRecapScreen({super.key, this.initialDate});

  @override
  State<DailyRecapScreen> createState() => _DailyRecapScreenState();
}

class _DailyRecapScreenState extends State<DailyRecapScreen> {
  final _db = DatabaseService.instance;
  final _export = ExportService();
  late DateTime _selectedDate;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final orders = await _db.getOrders(tanggal: _selectedDate);
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

    // Group by owner
    final byOwner = <String, List<Order>>{};
    for (final order in _orders) {
      byOwner.putIfAbsent(order.owner, () => []).add(order);
    }

    // Grand totals
    final grandKain = _orders.fold(0.0, (s, o) => s + o.totalKain);
    final grandOngkos = _orders.fold(0, (s, o) => s + o.totalOngkos);
    final grandBantal = _orders.fold(0.0, (s, o) => s + o.totalBantal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Harian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_orders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: _shareRekap,
              tooltip: 'Bagikan Rekap',
            ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border:
                      Border.all(color: theme.colorScheme.outline, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: theme.colorScheme.secondary),
                    const SizedBox(width: 12),
                    Text(
                      formatTanggalLengkap(_selectedDate),
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Icon(Icons.unfold_more_rounded,
                        size: 20, color: theme.colorScheme.secondary),
                  ],
                ),
              ),
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
                              'Tidak ada pesanan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            Text(
                              formatTanggalLengkap(_selectedDate),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          // Per owner sections
                          ...byOwner.entries.map((entry) =>
                              _buildOwnerSection(entry.key, entry.value, theme)),

                          // Grand total
                          if (byOwner.length > 1)
                            GlassCard(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.04),
                              child: SummaryCard(
                                title: 'Total Gabungan',
                                totalKain: grandKain,
                                totalOngkos: grandOngkos,
                                totalBantal: grandBantal,
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
      String owner, List<Order> orders, ThemeData theme) {
    final ownerKain = orders.fold(0.0, (s, o) => s + o.totalKain);
    final ownerOngkos = orders.fold(0, (s, o) => s + o.totalOngkos);
    final ownerBantal = orders.fold(0.0, (s, o) => s + o.totalBantal);

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

        // Motifs list
        ...orders.expand((order) => order.motifs.map((motif) => GlassCard(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(orderId: order.id!),
                  ),
                );
                _loadData();
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          motif.namaMotif,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${motif.totalPcs} pcs • ${formatMeter(motif.totalKain)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(motif.totalOngkos),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: theme.colorScheme.secondary),
                ],
              ),
            ))),

        // Owner summary
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          backgroundColor: theme.colorScheme.surface,
          child: SummaryCard(
            totalKain: ownerKain,
            totalOngkos: ownerOngkos,
            totalBantal: ownerBantal,
            isCompact: true,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  void _shareRekap() {
    final text = _export.formatRekapHarian(_selectedDate, _orders);
    Share.share(text);
  }
}
