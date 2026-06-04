import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/order.dart';
import '../models/motif_order.dart';
import '../models/order_item.dart';
import '../services/calculator_service.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/summary_card.dart';

class PreviewScreen extends StatefulWidget {
  final List<MotifOrder> motifs;
  final DateTime tanggal;
  final Order? existingOrder; // For edit mode

  const PreviewScreen({
    super.key,
    required this.motifs,
    required this.tanggal,
    this.existingOrder,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late List<MotifOrder> _motifs;
  late CalculatorService _calculator;
  final Map<int, String> _motifOwners = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _motifs = widget.motifs.map((m) => m.copyWith()).toList();
    // Default all motifs to Bapa
    for (int i = 0; i < _motifs.length; i++) {
      _motifOwners[i] = widget.existingOrder?.owner ?? 'Bapa';
    }
    _calculator = CalculatorService();
    _loadFormulas();
  }

  Future<void> _loadFormulas() async {
    final db = DatabaseService.instance;
    final formulas = await db.getFormulas();
    final ongkosConfigs = await db.getOngkosConfigs();
    _calculator = CalculatorService(
      kainNormal: {for (final f in formulas.where((f) => !f.isTinggi30)) f.ukuran: f.kainMeter},
      kainTinggi30: {for (final f in formulas.where((f) => f.isTinggi30)) f.ukuran: f.kainMeter},
      ongkosConfigs: ongkosConfigs,
    );
    _recalculate();
  }

  void _recalculate() {
    setState(() {
      _motifs = _calculator.calculateAll(_motifs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Aggregate totals
    final totalKain = _motifs.fold(0.0, (s, m) => s + m.totalKain);
    final totalOngkos = _motifs.fold(0, (s, m) => s + m.totalOngkos);
    final totalBantal = _motifs.fold(0.0, (s, m) => s + m.totalBantal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Rekap'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 120),
              children: [
                // Header info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap badge owner untuk ubah Gilang/Bapa',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        formatTanggalLengkap(widget.tanggal),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Motif cards
                ..._motifs.asMap().entries.map((entry) {
                  final motifIndex = entry.key;
                  final motif = entry.value;
                  return _buildMotifCard(motif, motifIndex, theme);
                }),

                // Grand total
                GlassCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SummaryCard(
                    title: 'Total Keseluruhan',
                    totalKain: totalKain,
                    totalOngkos: totalOngkos,
                    totalBantal: totalBantal,
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 12,
              top: 12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveOrder,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Simpan Pesanan'),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotifCard(MotifOrder motif, int motifIndex, ThemeData theme) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(0),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  motif.namaMotif,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.existingOrder == null) {
                    setState(() {
                      _motifOwners[motifIndex] =
                          _motifOwners[motifIndex] == 'Bapa' ? 'Gilang' : 'Bapa';
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _motifOwners[motifIndex] == 'Gilang'
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _motifOwners[motifIndex] == 'Gilang'
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: _motifOwners[motifIndex] == 'Gilang'
                            ? theme.colorScheme.primary
                            : AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _motifOwners[motifIndex]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _motifOwners[motifIndex] == 'Gilang'
                              ? theme.colorScheme.primary
                              : AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${motif.totalPcs} pcs • ${formatMeter(motif.totalKain)}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            color: theme.colorScheme.primary,
            onPressed: () => _addItem(motifIndex),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Rincian Kain',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Hasil',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Items
            ...motif.items.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              return _buildItemRow(item, motifIndex, itemIndex, theme);
            }),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Summary
            SummaryCard(
              totalKain: motif.totalKain,
              totalOngkos: motif.totalOngkos,
              totalBantal: motif.totalBantal,
              isCompact: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(
      OrderItem item, int motifIndex, int itemIndex, ThemeData theme) {
    return Dismissible(
      key: ValueKey('${motifIndex}_$itemIndex'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _motifs[motifIndex].items.removeAt(itemIndex);
          if (_motifs[motifIndex].items.isEmpty) {
            _motifs.removeAt(motifIndex);
          }
        });
        _recalculate();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppTheme.error.withValues(alpha: 0.1),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.error, size: 20),
      ),
      child: InkWell(
        onTap: () => _editItem(motifIndex, itemIndex),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${item.pcs} pcs × ${formatDecimal(item.kainPerPcs)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatMeter(item.totalKain),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editItem(int motifIndex, int itemIndex) async {
    final item = _motifs[motifIndex].items[itemIndex];
    final pcsController = TextEditingController(text: item.pcs.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${item.label}'),
        content: TextField(
          controller: pcsController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Jumlah (pcs)',
            suffixText: 'pcs',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final pcs = int.tryParse(pcsController.text);
              if (pcs != null && pcs > 0) {
                Navigator.pop(ctx, pcs);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    pcsController.dispose();

    if (result != null) {
      setState(() {
        _motifs[motifIndex].items[itemIndex] =
            item.copyWith(pcs: result);
      });
      _recalculate();
    }
  }

  Future<void> _addItem(int motifIndex) async {
    final ukuranController = TextEditingController();
    final pcsController = TextEditingController();
    bool isTinggi30 = false;

    final result = await showDialog<OrderItem>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tambah Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ukuranController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ukuran',
                  hintText: '90, 100, 120, 140, 160, 180, 200',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pcsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (pcs)',
                  suffixText: 'pcs',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Tinggi 30'),
                value: isTinggi30,
                onChanged: (v) => setDialogState(() => isTinggi30 = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final ukuran = int.tryParse(ukuranController.text);
                final pcs = int.tryParse(pcsController.text);
                if (ukuran != null && pcs != null && pcs > 0) {
                  Navigator.pop(
                    ctx,
                    OrderItem(
                      ukuran: ukuran,
                      pcs: pcs,
                      isTinggi30: isTinggi30,
                    ),
                  );
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );

    ukuranController.dispose();
    pcsController.dispose();

    if (result != null) {
      setState(() {
        _motifs[motifIndex].items.add(result);
      });
      _recalculate();
    }
  }

  Future<void> _saveOrder() async {
    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;

      // Group motifs by owner
      final motifsByOwner = <String, List<MotifOrder>>{
        'Gilang': [],
        'Bapa': [],
      };

      for (int i = 0; i < _motifs.length; i++) {
        final owner = _motifOwners[i] ?? 'Bapa';
        motifsByOwner[owner]!.add(_motifs[i]);
      }

      if (widget.existingOrder != null) {
        final order = Order(
          id: widget.existingOrder?.id,
          owner: widget.existingOrder!.owner,
          tanggal: widget.tanggal,
          motifs: _motifs,
        );
        await db.updateOrder(order);
      } else {
        // Create separate orders
        for (final entry in motifsByOwner.entries) {
          final owner = entry.key;
          final ownerMotifs = entry.value;

          if (ownerMotifs.isNotEmpty) {
            final order = Order(
              owner: owner,
              tanggal: widget.tanggal,
              motifs: ownerMotifs,
            );
            await db.insertOrder(order);
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pesanan berhasil disimpan'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
