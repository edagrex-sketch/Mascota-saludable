import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class VaccinationStatusScreen extends StatelessWidget {
  const VaccinationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estado de Vacunas',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Calendario de Vacunación',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _VaccineTile(
            name: 'Rabia',
            date: '12 Ene 2025',
            status: 'Completada',
            isCompleted: true,
          ),
          const SizedBox(height: 8),
          _VaccineTile(
            name: 'Moquillo',
            date: '12 Ene 2025',
            status: 'Completada',
            isCompleted: true,
          ),
          const SizedBox(height: 8),
          _VaccineTile(
            name: 'Parvovirus',
            date: '15 Jun 2025',
            status: 'Pendiente',
            isCompleted: false,
          ),
          const SizedBox(height: 8),
          _VaccineTile(
            name: 'Hepatitis',
            date: '20 Dic 2025',
            status: 'Programada',
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

class _VaccineTile extends StatelessWidget {
  const _VaccineTile({
    required this.name,
    required this.date,
    required this.status,
    required this.isCompleted,
  });

  final String name;
  final String date;
  final String status;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFE8F5E9)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.schedule,
              color:
                  isCompleted ? const Color(0xFF2E7D32) : AppColors.outline,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFE8F5E9)
                  : AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: AppTypography.labelMd.copyWith(
                color: isCompleted
                    ? const Color(0xFF2E7D32)
                    : AppColors.onSecondaryFixed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
