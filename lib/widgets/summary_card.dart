import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../utils/formatters.dart';

/// A summary card showing kain, ongkos, and bantal/guling totals
class SummaryCard extends StatelessWidget {
  final double totalKain;
  final int totalOngkos;
  final double totalBantal;
  final String? title;
  final bool isCompact;

  const SummaryCard({
    super.key,
    required this.totalKain,
    required this.totalOngkos,
    required this.totalBantal,
    this.title,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return Row(
        children: [
          _buildCompactItem(
            context,
            Icons.straighten_rounded,
            formatMeter(totalKain),
            'Kain',
          ),
          const SizedBox(width: 16),
          _buildCompactItem(
            context,
            Icons.payments_outlined,
            formatRupiah(totalOngkos),
            'Ongkos',
          ),
          const SizedBox(width: 16),
          _buildCompactItem(
            context,
            Icons.inventory_2_outlined,
            formatDecimal(totalBantal),
            'Bantal',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildRow(
          context,
          icon: Icons.straighten_rounded,
          label: 'Total Kain',
          value: formatMeter(totalKain),
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 10),
        _buildRow(
          context,
          icon: Icons.payments_outlined,
          label: 'Ongkos Jahit',
          value: formatRupiah(totalOngkos),
          color: AppTheme.success,
        ),
        const SizedBox(height: 10),
        _buildRow(
          context,
          icon: Icons.inventory_2_outlined,
          label: 'Total Bantal/Guling',
          value: formatDecimal(totalBantal),
          color: AppTheme.warning,
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactItem(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.secondary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
