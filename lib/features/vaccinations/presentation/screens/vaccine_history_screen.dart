import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/vaccine_model.dart';
import '../../../../core/services/vaccine_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';

class VaccineHistoryScreen extends StatefulWidget {
  const VaccineHistoryScreen({super.key});

  @override
  State<VaccineHistoryScreen> createState() => _VaccineHistoryScreenState();
}

class _VaccineHistoryScreenState extends State<VaccineHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _vaccineService = VaccineService();

  List<VaccineModel> _vaccines = [];
  bool _loading = true;
  String? _error;
  int _filterIndex = 0;

  late final AnimationController _staggerCtrl;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _loadVaccines();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVaccines() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Note: In a real app, you'd pass the petId or load all vaccines
      // For now, we fetch vaccines for a demo pet
      final vaccines = await _vaccineService.getVaccines('');
      if (!mounted) return;
      setState(() {
        _vaccines = vaccines;
        _loading = false;
      });
      _staggerCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ErrorHandler.mapError(e);
      });
      ErrorHandler.showRetrySnackBar(context, _loadVaccines);
    }
  }

  List<VaccineModel> get _filteredVaccines {
    switch (_filterIndex) {
      case 0:
        return _vaccines;
      case 1:
        return _vaccines.where((v) => v.status != 'completed').toList();
      case 2:
        return _vaccines.where((v) => v.status == 'completed').toList();
      default:
        return _vaccines;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de Vacunas',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(AppRoutes.registerVaccine).then((_) => _loadVaccines()),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildLoading();

    if (_error != null && _vaccines.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Error al cargar',
        subtitle: _error!,
        ctaLabel: 'Reintentar',
        onCtaPressed: _loadVaccines,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadVaccines,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // Pet selector summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.pets,
                            color: AppColors.primaryContainer, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todas las mascotas',
                            style: AppTypography.titleLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${_vaccines.length} vacunas registradas',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      isSelected: _filterIndex == 0,
                      onTap: () => setState(() => _filterIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Próximas',
                      isSelected: _filterIndex == 1,
                      onTap: () => setState(() => _filterIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Completadas',
                      isSelected: _filterIndex == 2,
                      onTap: () => setState(() => _filterIndex = 2),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Timeline
            if (_filteredVaccines.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vaccine = _filteredVaccines[index];
                      return _TimelineItem(
                        vaccine: vaccine,
                        isLast: index == _filteredVaccines.length - 1,
                        index: index,
                        staggerCtrl: _staggerCtrl,
                      );
                    },
                    childCount: _filteredVaccines.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ShimmerLoader(width: double.infinity, height: 68, borderRadius: 12),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(right: 8),
              child: ShimmerLoader(width: 80, height: 32, borderRadius: 999),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const ShimmerLoader(width: 40, height: 40, borderRadius: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoader(width: double.infinity, height: 80, borderRadius: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aún no hay registros',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mantén a tu mascota protegida registrando su primera vacuna hoy mismo.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context
                  .push(AppRoutes.registerVaccine)
                  .then((_) => _loadVaccines()),
              icon: const Icon(Icons.add),
              label: const Text('Registrar primera vacuna'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filters ──

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTypography.labelLg.copyWith(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Timeline Item ──

class _TimelineItem extends StatelessWidget {
  final VaccineModel vaccine;
  final bool isLast;
  final int index;
  final AnimationController staggerCtrl;

  const _TimelineItem({
    required this.vaccine,
    required this.isLast,
    required this.index,
    required this.staggerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = vaccine.status == 'completed';
    final isOverdue = vaccine.isOverdue;

    Color dotColor;
    IconData dotIcon;
    if (isCompleted) {
      dotColor = const Color(0xFF2E7D32);
      dotIcon = Icons.check_circle;
    } else if (isOverdue) {
      dotColor = AppColors.error;
      dotIcon = Icons.error;
    } else {
      dotColor = AppColors.secondary;
      dotIcon = Icons.schedule;
    }

    final anim = CurvedAnimation(
      parent: staggerCtrl,
      curve: Interval(
        (index * 0.1).clamp(0.0, 0.8),
        ((index * 0.1) + 0.3).clamp(0.1, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)),
            child: child,
          ),
        );
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dotColor.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 3,
                      ),
                    ),
                    child: Icon(dotIcon, color: dotColor, size: 20),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.outlineVariant.withAlpha(80),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(8),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vaccine.name,
                              style: AppTypography.titleLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: dotColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              vaccine.statusLabel,
                              style: AppTypography.labelMd.copyWith(
                                color: dotColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        text:
                            '${vaccine.applicationDate.day}/${vaccine.applicationDate.month}/${vaccine.applicationDate.year}',
                      ),
                      if (vaccine.veterinarian != null)
                        _InfoRow(
                            icon: Icons.person, text: vaccine.veterinarian!),
                      if (vaccine.clinic != null)
                        _InfoRow(
                            icon: Icons.local_hospital, text: vaccine.clinic!),
                      if (vaccine.nextDoseDate != null && !isCompleted) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notifications_active,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Próxima: ${vaccine.nextDoseDate!.day}/${vaccine.nextDoseDate!.month}/${vaccine.nextDoseDate!.year}',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isCompleted && vaccine.batchNumber != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.description,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              'Certificado disponible',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
