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
import 'preview_screen.dart';

class DetailScreen extends StatefulWidget {
  final int orderId;

  const DetailScreen({super.key, required this.orderId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _db = DatabaseService.instance;
  final _export = ExportService();
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await _db.getOrder(widget.orderId);
    if (mounted) {
      setState(() {
        _order = order;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_order != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: _editOrder,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: _copyRekap,
              tooltip: 'Salin Rekap',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _deleteOrder();
                if (value == 'share') _shareRekap();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Bagikan'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18,
                          color: AppTheme.error),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _order == null
              ? const Center(child: Text('Pesanan tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatTanggalLengkap(_order!.tanggal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _order!.owner,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Motifs
                    ..._order!.motifs.map((motif) => GlassCard(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motif.namaMotif,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),

                              // Section header
                              Text(
                                'Rincian Kain',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Items
                              ...motif.items.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                      color: theme.colorScheme.primary,
                                                      height: 1.4),
                                              children: [
                                                TextSpan(
                                                  text: '${item.label} ',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '(${item.pcs} pcs) = ${item.pcs} × ${formatDecimal(item.kainPerPcs)}',
                                                  style: TextStyle(
                                                      color: theme.colorScheme.secondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formatMeter(item.totalKain),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),

                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              SummaryCard(
                                totalKain: motif.totalKain,
                                totalOngkos: motif.totalOngkos,
                                totalBantal: motif.totalBantal,
                              ),
                            ],
                          ),
                        )),

                    // Grand total
                    if (_order!.motifs.length > 1)
                      GlassCard(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.03),
                        child: SummaryCard(
                          title: 'Total Keseluruhan',
                          totalKain: _order!.totalKain,
                          totalOngkos: _order!.totalOngkos,
                          totalBantal: _order!.totalBantal,
                        ),
                      ),
                  ],
                ),
    );
  }

  Future<void> _editOrder() async {
    if (_order == null) return;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          motifs: _order!.motifs,
          tanggal: _order!.tanggal,
          existingOrder: _order,
        ),
      ),
    );

    if (saved == true) {
      _loadOrder();
    }
  }

  void _copyRekap() {
    if (_order == null) return;
    final text = _export.formatOrder(_order!);
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
    if (_order == null) return;
    final text = _export.formatOrder(_order!);
    Share.share(text);
  }

  Future<void> _deleteOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && _order != null) {
      await _db.deleteOrder(_order!.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
