import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/widgets/app_button.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _petService = PetService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  File? _photoFile;
  bool _loading = false;
  bool _showSuccess = false;
  bool _uploadingPhoto = false;

  late final AnimationController _successCtrl;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkFade;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
    _checkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final petId = generateId();

      // Upload photo first if selected (use the real petId directly)
      String? photoUrl;
      if (_photoFile != null) {
        setState(() => _uploadingPhoto = true);
        photoUrl = await _storageService.uploadPetPhoto(
          petId: petId,
          file: _photoFile!,
        );
        setState(() => _uploadingPhoto = false);
      }

      final pet = PetModel(
        id: petId,
        userId: '',
        name: _nameCtrl.text.trim(),
        breed: _breedCtrl.text.trim(),
        ageYears: int.tryParse(_ageCtrl.text) ?? 0,
        weightKg: double.tryParse(_weightCtrl.text) ?? 0,
        photoUrl: photoUrl,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _petService.createPet(pet);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _showSuccess = true;
      });
      _successCtrl.forward();

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) context.pop(true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ErrorHandler.showSnackBar(context, e);
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
                'Foto de perfil',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona una imagen para la mascota',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _PhotoOption(
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
                    child: _PhotoOption(
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
              if (_photoFile != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _photoFile = null;
                      });
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
        setState(() => _photoFile = File(xFile.path));
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'No se pudo acceder a la $source');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nueva Mascota',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
      ),
      body: _showSuccess ? _buildSuccessContent() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo picker ──
            Center(
              child: GestureDetector(
                onTap: _showPhotoOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(30),
                        borderRadius: BorderRadius.circular(32),
                        image: _photoFile != null
                            ? DecorationImage(
                                image: FileImage(_photoFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _photoFile == null
                          ? const Icon(
                              Icons.pets,
                              size: 56,
                              color: AppColors.primaryContainer,
                            )
                          : null,
                    ),
                    // Camera FAB overlay
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                    // Uploading overlay
                    if (_uploadingPhoto)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(80),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
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
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Toca para agregar foto',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('Nombre'),
            const SizedBox(height: 6),
            _buildInput(
              controller: _nameCtrl,
              hint: 'Ej: Luna',
              icon: Icons.pets,
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Ingresa el nombre' : null,
            ),
            const SizedBox(height: 20),
            _buildLabel('Raza'),
            const SizedBox(height: 6),
            _buildInput(
              controller: _breedCtrl,
              hint: 'Ej: Golden Retriever',
              icon: Icons.category,
              showCamera: true,
              validator: (v) =>
                  v?.trim().isEmpty ?? true ? 'Ingresa la raza' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Edad (años)'),
                      const SizedBox(height: 6),
            _buildInput(
              controller: _ageCtrl,
              hint: 'Ej: 4',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Requerido';
                final val = int.tryParse(v!.trim());
                if (val == null) return 'Número inválido';
                if (val < 0) return 'No puede ser negativo';
                if (val > 50) return 'Edad muy alta';
                return null;
              },
            ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Peso (kg)'),
                      const SizedBox(height: 6),
            _buildInput(
              controller: _weightCtrl,
              hint: 'Ej: 28.5',
              icon: Icons.monitor_weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Requerido';
                final val = double.tryParse(v!.trim());
                if (val == null) return 'Peso inválido';
                if (val < 0) return 'No puede ser negativo';
                if (val > 200) return 'Peso muy alto';
                return null;
              },
            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('Notas (opcional)'),
            const SizedBox(height: 6),
            _buildInput(
              controller: _notesCtrl,
              hint: 'Cualquier detalle adicional...',
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            AppButton.primary(
              label: 'Guardar Mascota',
              loading: _loading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTypography.labelMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool showCamera = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.outlineVariant,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        ),
        suffixIcon: showCamera
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implementar reconocimiento de raza por foto
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Reconocimiento por foto próximamente'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Center(
      child: AnimatedBuilder(
        animation: _successCtrl,
        builder: (context, _) {
          return FadeTransition(
            opacity: _checkFade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show photo if uploaded, otherwise check icon
                if (_photoFile != null)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      image: DecorationImage(
                        image: FileImage(_photoFile!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  )
                else
                  Transform.scale(
                    scale: _checkScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  '¡Mascota Registrada!',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_nameCtrl.text.trim()} ha sido añadida correctamente.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Photo option widget for bottom sheet
// ──────────────────────────────────────────────────────────────

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoOption({
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
