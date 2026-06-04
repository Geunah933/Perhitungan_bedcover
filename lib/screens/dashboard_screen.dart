import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/order.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import '../widgets/quick_menu_button.dart';
import 'input_screen.dart';
import 'daily_recap_screen.dart';
import 'weekly_recap_screen.dart';
import 'formula_screen.dart';
import 'detail_screen.dart';
import '../theme_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseService.instance;
  List<Order> _todayOrders = [];
  List<Order> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final today = DateTime.now();
    final todayOrders = await _db.getOrders(tanggal: today);
    final recentOrders = await _db.getOrders(limit: 5);
    if (mounted) {
      setState(() {
        _todayOrders = todayOrders;
        _recentOrders = recentOrders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              snap: true,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.premiumGradientDark
                          : AppTheme.premiumGradientLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Gilang Mandiri'),
                ],
              ),
              actions: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, mode, child) {
                    final isDark = mode == ThemeMode.dark ||
                        (mode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark);
                    return IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      ),
                      onPressed: () {
                        themeNotifier.value =
                            isDark ? ThemeMode.light : ThemeMode.dark;
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Today's Summary Card ──
                    DarkGlassCard(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white54,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatTanggalLengkap(today),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white54,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white38,
                                ),
                              ),
                            )
                          else if (_todayOrders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Belum ada pesanan hari ini',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white38,
                                ),
                              ),
                            )
                          else
                            _buildTodaySummary(theme),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Quick Menu ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Menu',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.85,
                        children: [
                          QuickMenuButton(
                            icon: Icons.add_box_rounded,
                            label: 'Input\nPesanan',
                            iconColor: theme.colorScheme.primary,
                            onTap: () => _navigateTo(const InputScreen()),
                          ),
                          QuickMenuButton(
                            icon: Icons.today_rounded,
                            label: 'Rekap\nHarian',
                            iconColor: AppTheme.success,
                            onTap: () => _navigateTo(const DailyRecapScreen()),
                          ),
                          QuickMenuButton(
                            icon: Icons.date_range_rounded,
                            label: 'Rekap\nMingguan',
                            iconColor: AppTheme.warning,
                            onTap: () => _navigateTo(const WeeklyRecapScreen()),
                          ),
                          QuickMenuButton(
                            icon: Icons.tune_rounded,
                            label: 'Data\nRumus',
                            iconColor: theme.colorScheme.secondary,
                            onTap: () => _navigateTo(const FormulaScreen()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Recent Orders ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pesanan Terbaru',
                            style: theme.textTheme.headlineSmall,
                          ),
                          if (_recentOrders.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                // Switch to orders tab
                                final scaffold = context.findAncestorStateOfType<State>();
                                if (scaffold != null) {
                                  // Navigate through bottom nav
                                }
                              },
                              child: Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_recentOrders.isEmpty)
                      GlassCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 48,
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada pesanan',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ketuk "Input Pesanan" untuk mulai',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._recentOrders.map((order) => _buildOrderCard(order, theme)),

                    const SizedBox(height: 100), // bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(ThemeData theme) {
    // Group by owner
    final byOwner = <String, List<Order>>{};
    for (final order in _todayOrders) {
      byOwner.putIfAbsent(order.owner, () => []).add(order);
    }

    int totalGabungan = 0;

    return Column(
      children: [
        ...byOwner.entries.map((entry) {
          final ownerTotal = entry.value.fold(0, (int s, o) => s + o.totalOngkos);
          totalGabungan += ownerTotal;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  formatRupiah(ownerTotal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(color: Colors.white12, height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Gabungan',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              formatRupiah(totalGabungan),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order, ThemeData theme) {
    return GlassCard(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: order.owner == 'Gilang'
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                order.owner[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: order.owner == 'Gilang'
                      ? theme.colorScheme.primary
                      : AppTheme.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  '${order.owner} • ${formatTanggalPendek(order.tanggal)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(order.totalOngkos),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    _loadData();
  }
}
