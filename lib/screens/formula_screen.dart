import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/formula.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';

class FormulaScreen extends StatefulWidget {
  const FormulaScreen({super.key});

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen> {
  final _db = DatabaseService.instance;
  List<Formula> _formulas = [];
  List<OngkosConfig> _ongkosConfigs = [];
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final formulas = await _db.getFormulas();
    final ongkos = await _db.getOngkosConfigs();
    if (mounted) {
      setState(() {
        _formulas = formulas;
        _ongkosConfigs = ongkos;
        _isLoading = false;
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final normalFormulas =
        _formulas.where((f) => !f.isTinggi30).toList();
    final tinggi30Formulas =
        _formulas.where((f) => f.isTinggi30).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.error, fontSize: 14),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    children: [
                      // ── Patokan Kain Normal ──
                      _buildSectionHeader('Patokan Kain Normal', theme),
                      GlassCard(
                        child: Column(
                          children: normalFormulas
                              .map((f) => _buildFormulaRow(f, theme))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Patokan Kain Tinggi 30 ──
                      _buildSectionHeader('Patokan Kain Tinggi 30', theme),
                      GlassCard(
                        child: Column(
                          children: tinggi30Formulas
                              .map((f) => _buildFormulaRow(f, theme))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Ongkos Jahit ──
                      _buildSectionHeader('Ongkos Jahit', theme),
                      GlassCard(
                        child: Column(
                          children: _ongkosConfigs
                              .map((c) => _buildOngkosRow(c, theme))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Save button
                if (_hasChanges)
                  Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom:
                          MediaQuery.of(context).padding.bottom + 12,
                      top: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                            color: theme.colorScheme.outline, width: 0.5),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Simpan Perubahan'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildFormulaRow(Formula formula, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${formula.ukuran}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text('=', style: TextStyle(color: theme.colorScheme.secondary)),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _editFormula(formula),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDecimal(formula.kainMeter),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'm',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngkosRow(OngkosConfig config, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Ukuran ${config.ukuranMin}–${config.ukuranMax}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _editOngkos(config),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatRupiah(config.harga),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '/pcs',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editFormula(Formula formula) async {
    final controller = TextEditingController(
      text: formula.kainMeter.toString().replaceAll('.', ','),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ukuran ${formula.ukuran}${formula.isTinggi30 ? " (Tinggi 30)" : ""}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Meter kain',
            suffixText: 'm',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.replaceAll(',', '.');
              final value = double.tryParse(text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null) {
      setState(() {
        formula.kainMeter = result;
        _hasChanges = true;
      });
    }
  }

  Future<void> _editOngkos(OngkosConfig config) async {
    final controller = TextEditingController(
      text: config.harga.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ongkos Ukuran ${config.ukuranMin}–${config.ukuranMax}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Harga per pcs',
            prefixText: 'Rp',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(ctx, value);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null) {
      setState(() {
        config.harga = result;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      for (final f in _formulas) {
        await _db.updateFormula(f);
      }
      for (final c in _ongkosConfigs) {
        await _db.updateOngkosConfig(c);
      }

      setState(() => _hasChanges = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perubahan berhasil disimpan'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
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
    }
  }

  Future<void> _resetToDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset ke Default'),
        content: const Text(
          'Semua rumus akan dikembalikan ke nilai awal. Lanjutkan?',
        ),
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.resetFormulas();
      _loadData();
    }
  }
}
