import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/parser_service.dart';
import '../services/calculator_service.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import 'preview_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _textController = TextEditingController();
  final _parser = ParserService();
  DateTime _selectedDate = DateTime.now();
  bool _isProcessing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Date Picker ──
                    Text(
                      'Tanggal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusM),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(
                              color: theme.colorScheme.outline, width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18, color: theme.colorScheme.secondary),
                            const SizedBox(width: 12),
                            Text(
                              formatTanggalLengkap(_selectedDate),
                              style: theme.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                size: 20, color: theme.colorScheme.secondary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Chat Input ──
                    Text(
                      'Pesan WhatsApp',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                            color: theme.colorScheme.outline, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 12,
                            minLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Tempel pesan WhatsApp di sini…\n\n'
                                  'Contoh:\n'
                                  'Pokemon Kuning\n'
                                  '90 4 pcs\n'
                                  '140 3 pcs\n'
                                  '160 10 pcs',
                              hintStyle: TextStyle(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                                fontSize: 14,
                                height: 1.6,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              fontFamily: 'monospace',
                            ),
                          ),
                          // Divider
                          const Divider(height: 1),
                          // Action bar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _textController.clear(),
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 16),
                                  label: const Text('Hapus'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.secondary,
                                    textStyle:
                                        const TextStyle(fontSize: 13),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _textController.text.isEmpty
                                      ? ''
                                      : '${_textController.text.split('\n').where((l) => l.trim().isNotEmpty).length} baris',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom Button ──
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
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing || _textController.text.trim().isEmpty
                      ? null
                      : _processRekap,
                  child: _isProcessing
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
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 8),
                            Text('Proses Rekap'),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    }
  }

  Future<void> _processRekap() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Parse the chat text
      final result = _parser.parse(text);

      if (result.motifs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data pesanan yang bisa dibaca'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Show warnings if any
      if (result.warnings.isNotEmpty && mounted) {
        final proceed = await _showWarnings(result.warnings);
        if (!proceed) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      // Load formulas from DB and calculate
      final db = DatabaseService.instance;
      final formulas = await db.getFormulas();
      final ongkosConfigs = await db.getOngkosConfigs();

      final calculator = CalculatorService(
        kainNormal: {for (final f in formulas.where((f) => !f.isTinggi30)) f.ukuran: f.kainMeter},
        kainTinggi30: {for (final f in formulas.where((f) => f.isTinggi30)) f.ukuran: f.kainMeter},
        ongkosConfigs: ongkosConfigs,
      );

      final calculatedMotifs = calculator.calculateAll(result.motifs);

      if (mounted) {
        // Navigate to preview
        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewScreen(
              motifs: calculatedMotifs,
              tanggal: _selectedDate,
            ),
          ),
        );

        if (saved == true) {
          _textController.clear();
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
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
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showWarnings(List<ParseWarning> warnings) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppTheme.warning, size: 24),
                SizedBox(width: 8),
                Text('Peringatan'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warnings.map((w) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.message,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (w.suggestedUkuran != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Akan menggunakan ukuran ${w.suggestedUkuran}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(ctx).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Edit Manual'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
