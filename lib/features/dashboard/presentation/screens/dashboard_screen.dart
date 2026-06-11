import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../../../shared/widgets/app_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _petService = PetService();

  List<PetModel> _pets = [];
  bool _loading = true;
  String? _error;
  String _userName = '';

  late final AnimationController _staggerCtrl;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
      final user = AuthService().currentUser;
      final pets = await _petService.getPets();

      if (!mounted) return;
      setState(() {
        _pets = pets;
        _userName =
            user?.userMetadata?['full_name'] as String? ?? user?.email ?? 'Usuario';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primaryFixed,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${_userName.split(' ')[0]}!',
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
      body: _loading
          ? _buildLoading()
          : _error != null && _pets.isEmpty
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 16, bottom: 100),
                      children: [
                        // Pet summary horizontal scroll
                        if (_pets.isNotEmpty) ...[
                          _buildSectionHeader(
                            title: 'Mis Mascotas',
                            actionLabel:
                                _pets.length > 1 ? 'Ver todas' : null,
                            onAction: () => context.go(AppRoutes.pets),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              children: _pets.map((pet) {
                                final index = _pets.indexOf(pet);
                                return _AnimatedPetCard(
                                  pet: pet,
                                  index: index,
                                  staggerCtrl: _staggerCtrl,
                                  onTap: () =>
                                      context.push('${AppRoutes.pets}/${pet.id}'),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

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
                                onTap: () => context
                                    .push(AppRoutes.registerVaccine),
                              ),
                              _QuickAction(
                                icon: Icons.medical_services_outlined,
                                label: 'Consulta',
                                color: AppColors.primaryFixed,
                                onTap: () {},
                              ),
                              _QuickAction(
                                icon: Icons.calendar_month_outlined,
                                label: 'Calendario',
                                color: AppColors.surfaceContainer,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Vaccination alert (first pet with pending vaccines)
                        if (_pets.isNotEmpty)
                          _buildVaccineAlert(),
                        const SizedBox(height: 24),

                        // Upcoming appointments (placeholder)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              if (_pets.isEmpty)
                                _buildEmptyAppointment()
                              else
                                _buildAppointmentCard(),
                            ],
                          ),
                        ),

                        // If no pets, show empty state
                        if (_pets.isEmpty) ...[
                          const SizedBox(height: 60),
                          _buildNoPetsState(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVaccineAlert() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryContainer, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.priority_high,
                      color: AppColors.primaryFixed, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'ACCIÓN PENDIENTE',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.primaryFixed,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Vacuna de Rabia',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_pets.first.name} necesita su refuerzo anual para mantener su carnet de salud al día.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.registerVaccine),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'Agendar ahora',
                style: AppTypography.labelLg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return AppCard(
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
                  'Revisión General',
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
                    Flexible(
                      child: Text(
                        'Clínica Veterinaria Central',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
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
    );
  }

  Widget _buildEmptyAppointment() {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_busy,
                color: AppColors.outline, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            'No hay citas programadas',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.pets, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu familia empieza aquí',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Añade a tu primera mascota para empezar a gestionar su salud de forma profesional.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addPet).then((_) => _loadData()),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Mascota'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Mascotas',
                style: AppTypography.titleLg.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: List.generate(
              2,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: DashboardPetShimmer(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (_) => const ShimmerLoader(
                  width: 56, height: 80, borderRadius: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const ShimmerLoader(
              width: double.infinity, height: 200, borderRadius: 24),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error al cargar datos',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated pet summary card ──

class _AnimatedPetCard extends StatelessWidget {
  final PetModel pet;
  final int index;
  final AnimationController staggerCtrl;
  final VoidCallback onTap;

  const _AnimatedPetCard({
    required this.pet,
    required this.index,
    required this.staggerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: staggerCtrl,
      curve: Interval(
        (index * 0.15).clamp(0.0, 0.7),
        ((index * 0.15) + 0.3).clamp(0.1, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    final isHealthy = pet.status == 'healthy';

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
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          onTap: onTap,
          child: SizedBox(
            width: 280,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isHealthy
                        ? AppColors.primaryContainer.withAlpha(30)
                        : AppColors.errorContainer.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: pet.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            pet.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.pets,
                              size: 36,
                              color: isHealthy
                                  ? AppColors.primaryContainer
                                  : AppColors.error,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          size: 36,
                          color: isHealthy
                              ? AppColors.primaryContainer
                              : AppColors.error,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pet.name,
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pet.ageYears} ${pet.ageYears == 1 ? 'año' : 'años'} • ${pet.breed}',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isHealthy
                                  ? AppColors.primary
                                  : AppColors.error)
                              .withAlpha(13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isHealthy
                                    ? AppColors.primary
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pet.statusLabel,
                              style: AppTypography.labelMd.copyWith(
                                color: isHealthy
                                    ? AppColors.primary
                                    : AppColors.error,
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
          ),
        ),
      ),
    );
  }
}

// ── Quick action button ──

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.onSurface, size: 24),
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
