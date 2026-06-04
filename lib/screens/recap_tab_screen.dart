import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'daily_recap_screen.dart';
import 'weekly_recap_screen.dart';

class RecapTabScreen extends StatelessWidget {
  const RecapTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildRecapOption(
              context,
              theme,
              icon: Icons.today_rounded,
              iconColor: theme.colorScheme.primary,
              title: 'Rekap Harian',
              subtitle: 'Lihat ringkasan pesanan per hari',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyRecapScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecapOption(
              context,
              theme,
              icon: Icons.date_range_rounded,
              iconColor: AppTheme.warning,
              title: 'Rekap Mingguan',
              subtitle: 'Lihat ringkasan pesanan Senin–Sabtu',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyRecapScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapOption(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(color: theme.colorScheme.outline, width: 0.5),
            boxShadow: theme.brightness == Brightness.dark ? AppTheme.darkShadow : AppTheme.lightShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.secondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
