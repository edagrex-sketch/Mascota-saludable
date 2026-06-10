import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class VaccineHistoryScreen extends StatelessWidget {
  const VaccineHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Vacunación',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Historial completo',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          _HistoryTile(
            vaccine: 'Rabia',
            pet: 'Luna',
            date: '12 Ene 2025',
            vet: 'Dr. García',
            nextDue: '12 Ene 2026',
          ),
          const SizedBox(height: 8),
          _HistoryTile(
            vaccine: 'Moquillo',
            pet: 'Luna',
            date: '12 Ene 2025',
            vet: 'Dr. García',
            nextDue: '12 Ene 2027',
          ),
          const SizedBox(height: 8),
          _HistoryTile(
            vaccine: 'Triple Felina',
            pet: 'Max',
            date: '15 Mar 2025',
            vet: 'Dra. López',
            nextDue: '15 Mar 2026',
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.vaccine,
    required this.pet,
    required this.date,
    required this.vet,
    required this.nextDue,
  });

  final String vaccine;
  final String pet;
  final String date;
  final String vet;
  final String nextDue;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine,
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
                  '$vet • Próximo: $nextDue',
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
