import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import 'detail_screen.dart';
import 'input_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final _db = DatabaseService.instance;
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _db.getOrders();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pesanan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 64,
                        color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pesanan',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InputScreen()),
                          );
                          _loadOrders();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Input Pesanan'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderTile(order, theme);
                    },
                  ),
                ),
      floatingActionButton: _orders.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputScreen()),
                );
                _loadOrders();
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            )
          : null,
    );
  }

  Widget _buildOrderTile(Order order, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(orderId: order.id!),
              ),
            );
            _loadOrders();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(color: theme.colorScheme.outline, width: 0.5),
            ),
            child: Row(
              children: [
                // Owner avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: order.owner == 'Gilang'
                        ? const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5856D6)])
                        : const LinearGradient(
                            colors: [Color(0xFF34C759), Color(0xFF30D158)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      order.owner[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.motifs.map((m) => m.namaMotif).join(', '),
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            order.owner,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' • ${formatTanggalPendek(order.tanggal)}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            ' • ${order.totalPcs} pcs',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(order.totalOngkos),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      formatMeter(order.totalKain),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: theme.colorScheme.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
