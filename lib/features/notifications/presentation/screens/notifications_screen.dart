import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Avisos y Recordatorios',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Sugerencias de Cuidado',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _SuggestionCard(
            title: 'Hidratación en verano',
            subtitle: 'Cómo asegurar que tus mascotas se mantengan frescas.',
            color: AppColors.secondaryContainer,
          ),
          const SizedBox(height: 12),
          _SuggestionCard(
            title: 'Alimentación balanceada',
            subtitle:
                'Consejos para una dieta equilibrada según la edad y raza.',
            color: AppColors.primaryFixed,
          ),
          const SizedBox(height: 24),
          Text(
            'Recordatorios',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _ReminderTile(
            title: 'Vacuna de Rabia - Max',
            subtitle: 'Vence en 15 días',
            isUrgent: true,
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            title: 'Desparasitación - Luna',
            subtitle: 'Vence en 30 días',
            isUrgent: false,
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            title: 'Chequeo anual - Oliver',
            subtitle: 'Vence en 45 días',
            isUrgent: false,
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: color,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withAlpha(180),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.subtitle,
    required this.isUrgent,
  });

  final String title;
  final String subtitle;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.errorContainer.withAlpha(50)
                  : AppColors.primaryContainer.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUrgent ? Icons.priority_high : Icons.notifications_outlined,
              color: isUrgent ? AppColors.error : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelMd.copyWith(
                    color: isUrgent
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isUrgent ? Icons.error_outline : Icons.check_circle_outline,
            color: isUrgent ? AppColors.error : const Color(0xFF2E7D32),
            size: 20,
          ),
        ],
      ),
    );
  }
}
