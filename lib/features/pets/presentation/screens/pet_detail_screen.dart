import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/models/vaccine_model.dart';
import '../../../../core/models/medical_visit_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/vaccine_service.dart';
import '../../../../core/services/medical_visit_service.dart';
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
  final _medicalVisitService = MedicalVisitService();
  final _picker = ImagePicker();

  PetModel? _pet;
  List<VaccineModel> _vaccines = [];
  List<MedicalVisitModel> _visits = [];
  bool _loading = true;
  bool _uploadingPhoto = false;
  String? _error;
  int _selectedTab = 0;
  final _scrollController = ScrollController();
  bool _isScrolled = false;

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
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 80;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pet = await _petService.getPet(widget.petId);
      final vaccines = await _vaccineService.getVaccines(widget.petId);
      List<MedicalVisitModel> visits = [];
      try {
        visits = await _medicalVisitService.getVisits(widget.petId);
      } catch (_) {
      }
      if (!mounted) return;
      setState(() {
        _pet = pet;
        _vaccines = vaccines;
        _visits = visits;
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
        final bytes = await xFile.readAsBytes();
        await _updatePetPhoto(bytes, xFile.name);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(
            context, 'No se pudo acceder a la cámara/galería');
      }
    }
  }

  Future<void> _updatePetPhoto(Uint8List bytes, String fileName) async {
    final pet = _pet;
    if (pet == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final newUrl = await _storageService.uploadPetPhotoBytes(
        petId: pet.id,
        bytes: bytes,
        fileName: fileName,
      );

      if (pet.photoUrl != null) {
        await _storageService.deletePhoto(pet.photoUrl!);
      }

      final updatedPet = pet.copyWith(photoUrl: newUrl);
      final savedPet = await _petService.updatePet(updatedPet);

      if (!mounted) return;
      setState(() {
        _pet = savedPet;
        _uploadingPhoto = false;
      });

      if (mounted) {
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
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                stretch: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  selectedTab: _selectedTab,
                  onTap: (index) => setState(() => _selectedTab = index),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
          _buildTopBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isScrolled
              ? AppColors.surface.withAlpha(230)
              : Colors.transparent,
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: _isScrolled ? AppColors.primary : Colors.white,
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.pets);
                    }
                  },
                ),
                if (_isScrolled)
                  Flexible(
                    child: Text(
                      'Ficha de ${_pet?.name ?? ''}',
                      style: AppTypography.titleLg.copyWith(
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: _isScrolled ? AppColors.primary : Colors.white,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: _isScrolled ? AppColors.primary : Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
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
        if (pet.photoUrl != null)
          Image.network(
            pet.photoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildHeroGradient(),
          )
        else
          _buildHeroGradient(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withAlpha(0),
                  AppColors.primary.withAlpha(200),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 68,
          right: 20,
          child: GestureDetector(
            onTap: _showPhotoOptions,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(100)),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        if (_uploadingPhoto)
          Container(
            color: Colors.black.withAlpha(80),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HeroChip(
                      icon: Icons.pets,
                      label: pet.breed,
                    ),
                    _HeroChip(
                      icon: Icons.calendar_today,
                      label:
                          '${pet.ageYears} ${pet.ageYears == 1 ? 'año' : 'años'}',
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
        ),
      ],
    );
  }

  Widget _buildHeroGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryContainer],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 120,
          color: Colors.white.withAlpha(30),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildResumenTab();
      case 1:
        return _buildMedicoTab();
      case 2:
        return _buildVacunasTab();
      case 3:
        return _buildDiarioTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResumenTab() {
    final pet = _pet;
    if (pet == null) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 1024),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.vaccines,
                  label: 'Registrar Vacuna',
                  onTap: () => context
                      .push(
                        AppRoutes.registerVaccine,
                        extra: widget.petId,
                      )
                      .then((_) => _loadData()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.medical_services,
                  label: 'Nueva Consulta',
                  onTap: () {},
                  outline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cronograma de Vacunación',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedTab = 2),
                child: const Text(
                  'Ver Historial',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: _vaccines.isEmpty
                ? _buildEmptyTimeline(pet)
                : _buildVaccineTimeline(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultas Recientes',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (_visits.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedTab = 1),
                  child: const Text(
                    'Explorar Notas',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_visits.isEmpty)
            _buildEmptyState(
              icon: Icons.medical_services_outlined,
              title: 'Sin consultas registradas',
              subtitle: 'Las visitas al veterinario aparecerán aquí.',
            )
          else
            ...List.generate(
              _visits.length > 2 ? 2 : _visits.length,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: i < _visits.length - 1 ? 12 : 0),
                child: _MedicalVisitCard(visit: _visits[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimeline(PetModel pet) {
    return Column(
      children: [
        Icon(
          Icons.vaccines,
          size: 48,
          color: AppColors.outline.withAlpha(80),
        ),
        const SizedBox(height: 12),
        Text(
          'Sin vacunas registradas',
          style: AppTypography.titleLg.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Registra la primera vacuna de ${pet.name}',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context
              .push(
                AppRoutes.registerVaccine,
                extra: widget.petId,
              )
              .then((_) => _loadData()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: const Text('Registrar ahora'),
        ),
      ],
    );
  }

  Widget _buildVaccineTimeline() {
    return Column(
      children: List.generate(
        _vaccines.length > 3 ? 3 : _vaccines.length,
        (index) {
          final vaccine = _vaccines[index];
          final isLast = index == (_vaccines.length > 3 ? 2 : _vaccines.length - 1);
          return _VaccineTimelineItem(
            vaccine: vaccine,
            isLast: isLast,
            showNextDose: vaccine.status != 'completed' &&
                index == 0,
          );
        },
      ),
    );
  }

  Widget _buildMedicoTab() {
    if (_visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: _buildEmptyState(
          icon: Icons.medical_services_outlined,
          title: 'Sin visitas médicas',
          subtitle:
              'Las consultas veterinarias y diagnósticos aparecerán aquí.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial Médico',
              style: AppTypography.titleLg.copyWith(
                color: AppColors.primary,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _visits.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < _visits.length - 1 ? 12 : 0),
            child: _MedicalVisitCard(visit: _visits[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildVacunasTab() {
    if (_vaccines.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: _buildEmptyState(
          icon: Icons.vaccines,
          title: 'Aún no hay registros',
          subtitle:
              'Mantén a tu mascota protegida registrando su primera vacuna hoy mismo.',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial de Vacunación',
              style: AppTypography.titleLg.copyWith(
                color: AppColors.primary,
              ),
            ),
            TextButton.icon(
              onPressed: () => context
                  .push(
                    AppRoutes.registerVaccine,
                    extra: widget.petId,
                  )
                  .then((_) => _loadData()),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _vaccines.length,
          (index) {
            final vaccine = _vaccines[index];
            final isLast = index == _vaccines.length - 1;
            return _VaccineTimelineItem(
              vaccine: vaccine,
              isLast: isLast,
              showNextDose: vaccine.status != 'completed' &&
                  vaccine.nextDoseDate != null &&
                  index < 2,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiarioTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: _buildEmptyState(
        icon: Icons.menu_book_outlined,
        title: 'Diario de cambios',
        subtitle:
            'Registra cambios físicos y observaciones diarias de tu mascota.',
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.outline.withAlpha(80)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando ficha...',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _error ?? 'Error al cargar',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No pudimos cargar la información de esta mascota.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final ValueChanged<int> onTap;

  const _SliverTabBarDelegate({
    required this.selectedTab,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    const tabs = ['Resumen', 'Médico', 'Vacunas', 'Diario'];
    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = index == selectedTab;
            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTypography.labelLg.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(tabs[index]),
                    ),
                    if (isSelected)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.selectedTab != selectedTab;
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withAlpha(220)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelLg.copyWith(color: Colors.white),
          ),
        ],
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
          border:
              outline ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: outline ? AppColors.primary : AppColors.onPrimary,
            ),
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
  final bool showNextDose;

  const _VaccineTimelineItem({
    required this.vaccine,
    required this.isLast,
    this.showNextDose = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = vaccine.status == 'completed';
    final isOverdue = vaccine.isOverdue;

    Color dotColor;
    IconData dotIcon;
    if (isCompleted) {
      dotColor = AppColors.secondaryContainer;
      dotIcon = Icons.check;
    } else if (isOverdue) {
      dotColor = AppColors.errorContainer;
      dotIcon = Icons.warning_amber;
    } else {
      dotColor = AppColors.primaryContainer;
      dotIcon = Icons.event;
    }

    Color iconColor;
    if (isCompleted) {
      iconColor = AppColors.onSecondaryContainer;
    } else if (isOverdue) {
      iconColor = AppColors.onErrorContainer;
    } else {
      iconColor = AppColors.onPrimaryContainer;
    }

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(dotIcon, color: iconColor, size: 22),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.outlineVariant.withAlpha(80),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(vaccine.applicationDate),
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vaccine.name,
                      style: AppTypography.titleLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vaccine.veterinarian != null || vaccine.clinic != null)
                      Text(
                        [
                          if (vaccine.veterinarian != null)
                            'Dra. ${vaccine.veterinarian}',
                          if (vaccine.clinic != null)
                            '${vaccine.clinic}',
                        ].join(' • '),
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    if (showNextDose && vaccine.nextDoseDate != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PRÓXIMA: ${_formatDate(vaccine.nextDoseDate!)}',
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

class _MedicalVisitCard extends StatelessWidget {
  final MedicalVisitModel visit;

  const _MedicalVisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: AppColors.secondary.withAlpha(150),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit.reason,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSecondaryFixed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(visit.visitDate),
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            visit.diagnosis ?? visit.reason,
            style: AppTypography.titleLg.copyWith(
              color: AppColors.primary,
            ),
          ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              visit.notes!,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: Text(
                    visit.veterinarian.isNotEmpty
                        ? visit.veterinarian[0].toUpperCase()
                        : 'V',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    visit.veterinarian,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (visit.clinic != null)
                  Text(
                    visit.clinic!,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

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
