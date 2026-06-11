import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/models/vaccine_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/storage_service.dart';
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
  final _storageService = StorageService();
  final _picker = ImagePicker();

  PetModel? _pet;
  List<VaccineModel> _vaccines = [];
  bool _loading = true;
  bool _uploadingPhoto = false;
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

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Foto de Perfil',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Actualiza la foto de ${_pet?.name ?? 'tu mascota'}',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _BottomSheetPhotoOption(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BottomSheetPhotoOption(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              if (_pet?.photoUrl != null || _pet?.photoUrl?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deletePhoto();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Eliminar foto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (xFile != null) {
        await _updatePetPhoto(File(xFile.path));
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'No se pudo acceder a la cámara/galería');
      }
    }
  }

  Future<void> _updatePetPhoto(File file) async {
    final pet = _pet;
    if (pet == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      // Upload new photo first (so we don't lose the old one if upload fails)
      final newUrl = await _storageService.uploadPetPhoto(
        petId: pet.id,
        file: file,
      );

      // Delete old photo if it exists (new photo is already uploaded)
      if (pet.photoUrl != null) {
        await _storageService.deletePhoto(pet.photoUrl!);
      }

      // Update pet record in DB
      final updatedPet = pet.copyWith(photoUrl: newUrl);
      final savedPet = await _petService.updatePet(updatedPet);

      if (!mounted) return;
      setState(() {
        _pet = savedPet;
        _uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Foto actualizada correctamente'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ErrorHandler.showSnackBar(context, e);
    }
  }

  Future<void> _deletePhoto() async {
    final pet = _pet;
    if (pet?.photoUrl == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      await _storageService.deletePhoto(pet!.photoUrl!);

      final updatedPet = pet.copyWith(photoUrl: null);
      final savedPet = await _petService.updatePet(updatedPet);

      if (!mounted) return;
      setState(() {
        _pet = savedPet;
        _uploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Foto eliminada'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ErrorHandler.showSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_pet == null) return _buildError();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 448,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _buildResumenTab(),
              _buildVacunasTab(),
              _buildConsultasTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final pet = _pet;
    if (pet == null) return const SizedBox.shrink();
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
                    // Editable photo
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: pet.photoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      pet.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.pets,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.pets,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                          ),
                          // Camera overlay
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Uploading overlay
                          if (_uploadingPhoto)
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(80),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
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

  Widget _buildResumenTab() {
    final pet = _pet;
    if (pet == null) return const SizedBox.shrink();
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
                onTap: () => context.push(
                  AppRoutes.registerVaccine,
                  extra: widget.petId,
                ).then((_) => _loadData()),
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
            onAction: () => context.push(
              AppRoutes.registerVaccine,
              extra: widget.petId,
            ).then((_) => _loadData()),
          ),
      ],
    );
  }

  Widget _buildVacunasTab() {
    final pet = _pet;
    if (pet == null) return const SizedBox.shrink();
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
              onPressed: () => context.push(
                AppRoutes.registerVaccine,
                extra: widget.petId,
              ).then((_) => _loadData()),
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
            onAction: () => context.push(
              AppRoutes.registerVaccine,
              extra: widget.petId,
            ).then((_) => _loadData()),
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
    final pet = _pet;
    if (pet == null) return const SizedBox.shrink();
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

  Widget _buildTabBar() {
    const tabs = ['Resumen', 'Vacunas', 'Consultas'];
    return Container(
      color: AppColors.surface,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 14),
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

// ──────────────────────────────────────────────────────────────
// Photo option widget for bottom sheet
// ──────────────────────────────────────────────────────────────

class _BottomSheetPhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetPhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withAlpha(50),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
