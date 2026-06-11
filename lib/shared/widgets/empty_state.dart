import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Premium empty state widget with illustration, title, subtitle, and optional CTA.
///
/// Includes subtle entry animation.
class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCtaPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with pulse background
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(13),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 56,
                      color: AppColors.primary.withAlpha(100),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // CTA button
                if (widget.ctaLabel != null && widget.onCtaPressed != null)
                  AppButton.primary(
                    label: widget.ctaLabel!,
                    onPressed: widget.onCtaPressed,
                  ),

                if (widget.secondaryLabel != null &&
                    widget.onSecondaryPressed != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppButton.ghost(
                      label: widget.secondaryLabel!,
                      onPressed: widget.onSecondaryPressed,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
