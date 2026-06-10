import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(
                Icons.person,
                color: AppColors.primaryFixed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola!',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Gestor de Salud',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        children: [
          // Pet summary horizontal scroll
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _PetSummaryCard(
                  name: 'Luna',
                  years: '4 años',
                  breed: 'Golden',
                  status: 'Al día',
                  statusColor: AppColors.primary,
                ),
                const SizedBox(width: 12),
                _PetSummaryCard(
                  name: 'Max',
                  years: '2 años',
                  breed: 'Maine Coon',
                  status: '1 Alerta',
                  statusColor: AppColors.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickAction(
                  icon: Icons.vaccines,
                  label: 'Nueva Vacuna',
                  color: AppColors.secondaryFixed,
                ),
                _QuickAction(
                  icon: Icons.medical_services_outlined,
                  label: 'Consulta',
                  color: AppColors.primaryFixed,
                ),
                _QuickAction(
                  icon: Icons.calendar_month_outlined,
                  label: 'Calendario',
                  color: AppColors.surfaceContainer,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vaccination alert
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.priority_high,
                          color: AppColors.primaryFixed, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'ACCIÓN PENDIENTE',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.primaryFixed,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vacuna de Rabia',
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max necesita su refuerzo anual para mantener su carnet de salud al día.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onPrimary,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      'Agendar ahora',
                      style: AppTypography.labelLg,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming appointments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Próximas Citas',
                      style: AppTypography.titleLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Ver todas',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MAÑ',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '12',
                              style: AppTypography.titleLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Revisión General - Luna',
                              style: AppTypography.bodyLg.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  'Clínica Veterinaria Central',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '09:30 AM',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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

class _PetSummaryCard extends StatelessWidget {
  const _PetSummaryCard({
    required this.name,
    required this.years,
    required this.breed,
    required this.status,
    required this.statusColor,
  });

  final String name;
  final String years;
  final String breed;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 280,
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.pets,
                size: 36,
                color: AppColors.primaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppTypography.titleLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$years • $breed',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: AppTypography.labelMd.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
