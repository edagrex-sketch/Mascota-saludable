import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de Mascota',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Pet header
          AppCard(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.pets,
                    size: 48,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Luna',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Golden Retriever • 4 años',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '● Saludable',
                    style: AppTypography.labelLg.copyWith(
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick info chips
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today,
                label: 'Próxima vacuna: En 12 días',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section buttons
          AppCard(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.vaccines, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historial de Vacunación',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '3 vacunas registradas',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visitas Veterinarias',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '2 visitas registradas',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.outline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMd.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
