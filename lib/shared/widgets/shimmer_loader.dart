import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Premium skeleton loader with slow calm pulse animation.
///
/// Follows the design system: pulse between Soft Grey (#F2F2F2) and
/// slightly darker Ivory (#EBEBEB) with 2s duration.
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.margin,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              const Color(0xFFF2F2F2),
              const Color(0xFFEBEBEB),
              _animation.value,
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built shimmer card for pet list items.
class PetCardShimmer extends StatelessWidget {
  const PetCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const ShimmerLoader(width: 64, height: 64, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerLoader(width: 100, height: 20),
                    const ShimmerLoader(width: 80, height: 24, borderRadius: 999),
                  ],
                ),
                const SizedBox(height: 6),
                const ShimmerLoader(width: 140, height: 14),
                const SizedBox(height: 4),
                const ShimmerLoader(width: 60, height: 14),
                const SizedBox(height: 12),
                const ShimmerLoader(width: double.infinity, height: 4, borderRadius: 999),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerLoader(width: 80, height: 12),
                    ShimmerLoader(width: 60, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-built shimmer for dashboard pet cards.
class DashboardPetShimmer extends StatelessWidget {
  const DashboardPetShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: 280,
        child: Row(
          children: [
            const ShimmerLoader(width: 72, height: 72, borderRadius: 12),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ShimmerLoader(width: 80, height: 20),
                SizedBox(height: 6),
                ShimmerLoader(width: 120, height: 14),
                SizedBox(height: 8),
                ShimmerLoader(width: 100, height: 20, borderRadius: 999),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
