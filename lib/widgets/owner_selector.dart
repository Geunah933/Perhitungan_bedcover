import 'package:flutter/material.dart';
import '../app_theme.dart';

/// iOS-style segmented control for selecting owner (Gilang / Bapa)
class OwnerSelector extends StatelessWidget {
  final String selectedOwner;
  final List<String> owners;
  final ValueChanged<String> onChanged;

  const OwnerSelector({
    super.key,
    required this.selectedOwner,
    required this.owners,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.3 : 0.8), // Using a softer background
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: owners.map((owner) {
          final isSelected = owner == selectedOwner;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(owner),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS + 1),
                  boxShadow: isSelected ? (isDark ? AppTheme.darkShadow : AppTheme.lightShadow) : null,
                ),
                child: Text(
                  owner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
