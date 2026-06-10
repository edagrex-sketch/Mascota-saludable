import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Multi-variant button following the Premium Modern design system
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  }) : _variant = _AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  }) : _variant = _AppButtonVariant.ghost;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
              if (icon == null && _variant == _AppButtonVariant.primary)
                const SizedBox(width: 8),
              if (_variant == _AppButtonVariant.primary)
                const Icon(Icons.arrow_forward, size: 20),
            ],
          );

    switch (_variant) {
      case _AppButtonVariant.primary:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.primary.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: child,
          ),
        );
      case _AppButtonVariant.secondary:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              disabledBackgroundColor:
                  AppColors.secondaryContainer.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: child,
          ),
        );
      case _AppButtonVariant.outline:
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          ),
        );
      case _AppButtonVariant.ghost:
        return TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.labelLg,
          ),
          child: child,
        );
    }
  }
}

enum _AppButtonVariant { primary, secondary, outline, ghost }
