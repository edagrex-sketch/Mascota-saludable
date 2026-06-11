import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shimmer_loader.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen>
    with SingleTickerProviderStateMixin {
  final _petService = PetService();
  final _searchController = TextEditingController();

  List<PetModel> _allPets = [];
  List<PetModel> _filteredPets = [];
  bool _loading = true;
  String? _error;
  Timer? _searchDebounce;

  // Animation
  late final AnimationController _staggerCtrl;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _loadPets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final pets = await _petService.getPets();
      if (!mounted) return;
      setState(() {
        _allPets = pets;
        _filteredPets = pets;
        _loading = false;
      });
      _staggerCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = ErrorHandler.mapError(e);
      });
      ErrorHandler.showRetrySnackBar(context, _loadPets);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = value.toLowerCase().trim();
      setState(() {
        if (query.isEmpty) {
          _filteredPets = _allPets;
        } else {
          _filteredPets = _allPets.where((p) {
            return p.name.toLowerCase().contains(query) ||
                p.breed.toLowerCase().contains(query);
          }).toList();
        }
      });
      _staggerCtrl.forward(from: 0);
    });
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPet(),
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null && _allPets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: Icons.cloud_off,
          title: 'Error al cargar',
          subtitle: _error!,
          ctaLabel: 'Reintentar',
          onCtaPressed: _loadPets,
        ),
      );
    }

    if (_allPets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: Icons.pets,
          title: 'Tu familia empieza aquí',
          subtitle:
              'Añade a tu primera mascota para empezar a gestionar su salud de forma profesional.',
          ctaLabel: 'Añadir Mascota',
          onCtaPressed: _navigateToAddPet,
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadPets,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // Header
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
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style:
                    AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              ),
            ),
            const SizedBox(height: 20),

            // Results count
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_filteredPets.length} ${_filteredPets.length == 1 ? 'resultado' : 'resultados'}',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),

            // Pet cards
            if (_filteredPets.isEmpty && _searchController.text.isNotEmpty)
              _buildNoResults()
            else
              ...List.generate(_filteredPets.length, (index) {
                final pet = _filteredPets[index];
                final delay = index * 100;
                return _AnimatedPetCard(
                  key: ValueKey(pet.id),
                  pet: pet,
                  index: index,
                  delay: delay,
                  staggerCtrl: _staggerCtrl,
                  onTap: () => context.go('${AppRoutes.pets}/${pet.id}'),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        const ShimmerLoader(width: 180, height: 32),
        const SizedBox(height: 4),
        const ShimmerLoader(width: 240, height: 16),
        const SizedBox(height: 20),
        const ShimmerLoader(width: double.infinity, height: 48, borderRadius: 12),
        const SizedBox(height: 20),
        ...List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: PetCardShimmer(),
        )),
      ],
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.outline.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: AppTypography.titleLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'No encontramos mascotas que coincidan con tu búsqueda.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPet() {
    context.push(AppRoutes.addPet).then((_) => _loadPets());
  }
}

/// Pet card with stagger entry animation.
class _AnimatedPetCard extends StatelessWidget {
  final PetModel pet;
  final int index;
  final int delay;
  final AnimationController staggerCtrl;
  final VoidCallback onTap;

  const _AnimatedPetCard({
    super.key,
    required this.pet,
    required this.index,
    required this.delay,
    required this.staggerCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardAnim = CurvedAnimation(
      parent: staggerCtrl,
      curve: Interval(
        (index * 0.1).clamp(0.0, 0.8),
        ((index * 0.1) + 0.3).clamp(0.1, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: cardAnim,
      builder: (context, child) {
        return Opacity(
          opacity: cardAnim.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - cardAnim.value)),
            child: child,
          ),
        );
      },
      child: _PetCard(pet: pet, onTap: onTap),
    );
  }
}

/// Individual pet card.
class _PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const _PetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHealthy = pet.status == 'healthy';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    // Pet avatar
                    Container(
                      width: 64,
                      height: 64,
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
                                  size: 32,
                                  color: isHealthy
                                      ? AppColors.primaryContainer
                                      : AppColors.error,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.pets,
                              size: 32,
                              color: isHealthy
                                  ? AppColors.primaryContainer
                                  : AppColors.error,
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
                                pet.name,
                                style: AppTypography.titleLg.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              _StatusBadge(
                                label: pet.statusLabel,
                                isHealthy: isHealthy,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pet.breed,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${pet.ageYears} ${pet.ageYears == 1 ? 'año' : 'años'}',
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
                // Health progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pet.healthProgress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.surfaceContainer,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHealthy ? AppColors.primary : AppColors.secondary,
                        ),
                        minHeight: 4,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pet.status == 'healthy'
                          ? 'Próxima vacuna'
                          : 'Atención requerida',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      pet.status == 'healthy' ? 'Al día' : '¡Revisar!',
                      style: AppTypography.labelMd.copyWith(
                        color:
                            isHealthy ? AppColors.primary : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status badge chip.
class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isHealthy;

  const _StatusBadge({required this.label, required this.isHealthy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        label,
        style: AppTypography.labelMd.copyWith(
          color: isHealthy
              ? const Color(0xFF2E7D32)
              : AppColors.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
