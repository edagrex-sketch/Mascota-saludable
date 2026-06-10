import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/routes/app_router.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

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
            Text(
              'Gestor de Salud',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.primary,
              ),
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            'Tus Mascotas',
            style: AppTypography.headlineLgMobile.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestiona el bienestar de tus compañeros',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o raza...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outlineVariant,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.outline,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 20),

          // Pet cards
          _PetCard(
            name: 'Luna',
            breed: 'Golden Retriever',
            years: '4 años',
            status: 'Saludable',
            isHealthy: true,
            progress: 0.85,
            nextVaccine: 'En 12 días',
            onTap: () => context.go('${AppRoutes.pets}/1'),
          ),
          const SizedBox(height: 12),
          _PetCard(
            name: 'Oliver',
            breed: 'Siamés',
            years: '2 años',
            status: 'Revisión pendiente',
            isHealthy: false,
            progress: 0.4,
            nextVaccine: '¡Urgente!',
            vaccineLabel: 'Chequeo anual',
            onTap: () => context.go('${AppRoutes.pets}/2'),
          ),
          const SizedBox(height: 12),
          _PetCard(
            name: 'Max',
            breed: 'Bulldog Francés',
            years: '6 meses',
            status: 'Saludable',
            isHealthy: true,
            progress: 0.95,
            nextVaccine: 'Completado',
            vaccineLabel: 'Desparasitación',
            onTap: () => context.go('${AppRoutes.pets}/3'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.name,
    required this.breed,
    required this.years,
    required this.status,
    required this.isHealthy,
    required this.progress,
    required this.nextVaccine,
    this.vaccineLabel,
    required this.onTap,
  });

  final String name;
  final String breed;
  final String years;
  final String status;
  final bool isHealthy;
  final double progress;
  final String nextVaccine;
  final String? vaccineLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 32,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: AppTypography.titleLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHealthy
                                ? const Color(0xFFE8F5E9)
                                : AppColors.errorContainer.withAlpha(50),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isHealthy
                                  ? const Color(0xFFC8E6C9)
                                  : AppColors.errorContainer,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            status,
                            style: AppTypography.labelMd.copyWith(
                              color: isHealthy
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      breed,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      years,
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurfaceVariant.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                isHealthy ? AppColors.primary : AppColors.secondary,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vaccineLabel ?? 'Próxima vacuna',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                nextVaccine,
                style: AppTypography.labelMd.copyWith(
                  color: isHealthy ? AppColors.primary : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
