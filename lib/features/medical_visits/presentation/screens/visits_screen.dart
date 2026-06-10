import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visitas Veterinarias',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Historial de Visitas',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _VisitTile(
            pet: 'Luna',
            reason: 'Revisión General',
            date: '12 Ene 2025',
            vet: 'Dr. García - Clínica Central',
          ),
          const SizedBox(height: 8),
          _VisitTile(
            pet: 'Max',
            reason: 'Vacunación',
            date: '15 Mar 2025',
            vet: 'Dra. López - VetCare',
          ),
          const SizedBox(height: 8),
          _VisitTile(
            pet: 'Luna',
            reason: 'Control de Peso',
            date: '20 Nov 2024',
            vet: 'Dr. García - Clínica Central',
          ),
        ],
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({
    required this.pet,
    required this.reason,
    required this.date,
    required this.vet,
  });

  final String pet;
  final String reason;
  final String date;
  final String vet;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services,
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
                  reason,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pet • $date',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  vet,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant.withAlpha(180),
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
