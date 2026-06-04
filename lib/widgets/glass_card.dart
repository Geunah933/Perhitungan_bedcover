import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_theme.dart';

/// A reusable glassmorphism card with frosted background effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final double blurAmount;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.blurAmount = 24, // Increased blur for premium feel
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.radiusL;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bgColor = backgroundColor ?? 
        (isDark ? const Color(0xFF161616) : Colors.white.withValues(alpha: 0.95));
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.10) 
        : Colors.white.withValues(alpha: 0.8);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium Gradient Card for hero/header sections
class DarkGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DarkGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        child: Container(
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.premiumGradientDark : AppTheme.premiumGradientLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: isDark ? AppTheme.darkShadow : AppTheme.lightShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
