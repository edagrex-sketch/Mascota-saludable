import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/models/vaccine_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/vaccine_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/routes/app_router.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key, required this.petId});

  final String petId;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  final _petService = PetService();
  final _vaccineService = VaccineService();

  PetModel? _pet;
  List<VaccineModel> _vaccines = [];
  bool _loading = true;
  String? _error;
  int _selectedTab = 0;

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
    _loadData();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pet = await _petService.getPet(widget.petId);
      final vaccines = await _vaccineService.getVaccines(widget.petId);
      if (!mounted) return;
      setState(() {
        _pet = pet;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error != null && _pet == null) return _buildError();

    return Scaffold(
      body: _pet == null
          ? _buildError()
          : CustomScrollView(
              slivers: [
                // Hero header
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  backgroundColor: AppColors.surface,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeroHeader(),
                  ),
                ),
                // Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabs: ['Resumen', 'Vacunas', 'Consultas'],
                    selectedTab: _selectedTab,
                    onTabChanged: (index) {
                      setState(() => _selectedTab = index);
                    },
                  ),
                ),
                // Content
                SliverFillRemaining(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _buildTabContent(_selectedTab),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroHeader() {
    final pet = _pet!;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
          ),
        ),
        // Decorative elements
        Positioned(
          right: -40,
          top: -40,
          child: Icon(
            Icons.pets,
            size: 200,
            color: Colors.white.withAlpha(15),
          ),
        ),
        // Pet info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet avatar + name
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: AppTypography.headlineLgMobile.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _HeroChip(
                                icon: Icons.pets,
                                label: pet.breed,
                              ),
                              _HeroChip(
                                icon: Icons.calendar_today,
                                label: '${pet.ageYears} ${pet.ageYears == 1 ? 'año' : 'años'}',
                              ),
                              if (pet.weightKg > 0)
                                _HeroChip(
                                  icon: Icons.monitor_weight,
                                  label: '${pet.weightKg.toStringAsFixed(1)} kg',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(int tab) {
    switch (tab) {
      case 0:
        return _buildResumenTab();
      case 1:
        return _buildVacunasTab();
      case 2:
        return _buildConsultasTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildResumenTab() {
    final pet = _pet!;
    return ListView(
      key: const ValueKey('resumen'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        // Quick info cards
        Row(
          children: [
            _MetricCard(
              icon: Icons.vaccines,
              label: 'Vacunas',
              value: '${_vaccines.length}',
            ),
            const SizedBox(width: 12),
            _MetricCard(
              icon: Icons.check_circle,
              label: 'Completadas',
              value: '${_vaccines.where((v) => v.status == 'completed').length}',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 12),
            _MetricCard(
              icon: Icons.warning_amber,
              label: 'Pendientes',
              value: '${_vaccines.where((v) => v.status != 'completed').length}',
              color: AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.vaccines,
                label: 'Registrar Vacuna',
                onTap: () => context.push(AppRoutes.registerVaccine),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.medical_services_outlined,
                label: 'Nueva Consulta',
                onTap: () {},
                outline: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Vaccine timeline preview
        if (_vaccines.isNotEmpty) ...[
          Text(
            'Últimas Vacunas',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          ..._vaccines.take(3).map((v) => _VaccineTimelineItem(
                vaccine: v,
                isLast: v == _vaccines.last,
              )),
          if (_vaccines.length > 3)
            TextButton(
              onPressed: () => setState(() => _selectedTab = 1),
              child: Text(
                'Ver todas (${_vaccines.length})',
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ] else
          _buildEmptySection(
            icon: Icons.vaccines,
            title: 'Sin vacunas registradas',
            subtitle: 'Registra la primera vacuna de ${pet.name}',
            onAction: () => context.push(AppRoutes.registerVaccine),
          ),
      ],
    );
  }

  Widget _buildVacunasTab() {
    return ListView(
      key: const ValueKey('vacunas'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial de Vacunación',
              style: AppTypography.titleLg.copyWith(color: AppColors.primary),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.registerVaccine),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_vaccines.isEmpty)
          _buildEmptySection(
            icon: Icons.vaccines,
            title: 'Aún no hay registros',
            subtitle:
                'Mantén a tu mascota protegida registrando su primera vacuna hoy mismo.',
            onAction: () => context.push(AppRoutes.registerVaccine),
          )
        else
          ..._vaccines.map((v) => _VaccineTimelineItem(
                vaccine: v,
                isLast: v == _vaccines.last,
              )),
      ],
    );
  }

  Widget _buildConsultasTab() {
    return ListView(
      key: const ValueKey('consultas'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        Text(
          'Consultas Veterinarias',
          style: AppTypography.titleLg.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        _buildEmptySection(
          icon: Icons.medical_services_outlined,
          title: 'Sin consultas registradas',
          subtitle: 'Las visitas al veterinario aparecerán aquí.',
          actionLabel: 'Coming soon',
        ),
      ],
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onAction,
    String actionLabel = 'Registrar ahora',
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.outline.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text(actionLabel,
                  style: AppTypography.labelLg),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Error al cargar',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Supporting widgets
// ──────────────────────────────────────────────────────────────

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withAlpha(200)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMd.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(10),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.headlineMd.copyWith(
                color: c,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outline;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: outline ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: outline ? AppColors.primary : AppColors.onPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelLg.copyWith(
                color: outline ? AppColors.primary : AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccineTimelineItem extends StatelessWidget {
  final VaccineModel vaccine;
  final bool isLast;

  const _VaccineTimelineItem({
    required this.vaccine,
    required this.isLast,
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

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: dotColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(dotIcon, color: dotColor, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.outlineVariant.withAlpha(100),
                    ),
                  ),
              ],
            ),
          ),
          // Content
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
                        Text(
                          vaccine.name,
                          style: AppTypography.titleLg.copyWith(
                            color: AppColors.primary,
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
                    const SizedBox(height: 6),
                    _InfoRow(
                        icon: Icons.calendar_today,
                        text:
                            '${vaccine.applicationDate.day}/${vaccine.applicationDate.month}/${vaccine.applicationDate.year}'),
                    if (vaccine.veterinarian != null)
                      _InfoRow(
                          icon: Icons.person,
                          text: vaccine.veterinarian!),
                    if (vaccine.clinic != null)
                      _InfoRow(
                          icon: Icons.local_hospital,
                          text: vaccine.clinic!),
                    if (vaccine.nextDoseDate != null && !isCompleted) ...[
                      const SizedBox(height: 6),
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
                  ],
                ),
              ),
            ),
          ),
        ],
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  _TabBarDelegate({
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: AppTypography.labelLg.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(tabs[index], textAlign: TextAlign.center),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      selectedTab != oldDelegate.selectedTab;
}
