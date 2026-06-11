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
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/widgets/app_button.dart';

class RegisterVaccineScreen extends StatefulWidget {
  /// Optional: if provided, the pet selector will be pre-selected and locked.
  final String? initialPetId;

  const RegisterVaccineScreen({super.key, this.initialPetId});

  @override
  State<RegisterVaccineScreen> createState() => _RegisterVaccineScreenState();
}

class _RegisterVaccineScreenState extends State<RegisterVaccineScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _vaccineService = VaccineService();
  final _petService = PetService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  final _vaccineCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();

  DateTime _applicationDate = DateTime.now();
  DateTime? _nextDoseDate;
  bool _loading = false;
  bool _loadingPets = true;
  bool _showSuccess = false;
  bool _uploadingCert = false;

  File? _certificateFile;

  // Pet selection
  List<PetModel> _pets = [];
  PetModel? _selectedPet;

  static const _vaccineOptions = [
    'Rabia',
    'Polivalente (Séxtuple)',
    'Tos de las perreras',
    'Leptospirosis',
    'Parvovirus',
    'Moquillo',
    'Hepatitis',
    'Triple Felina',
    'Leucemia Felina',
    'Otra...',
  ];

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
    _loadPets();
  }

  @override
  void dispose() {
    _vaccineCtrl.dispose();
    _vetCtrl.dispose();
    _clinicCtrl.dispose();
    _batchCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await _petService.getPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _loadingPets = false;
        // Pre-select if initialPetId was provided
        if (widget.initialPetId != null) {
          _selectedPet = pets.where((p) => p.id == widget.initialPetId).firstOrNull;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPets = false);
      ErrorHandler.showSnackBar(context, e);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPet == null) {
      ErrorHandler.showSnackBar(context, 'Selecciona una mascota');
      return;
    }

    setState(() => _loading = true);

    try {
      final vaccineId = generateId();

      // Upload certificate photo first if selected
      String? certificateUrl;
      if (_certificateFile != null) {
        setState(() => _uploadingCert = true);
        certificateUrl = await _storageService.uploadVaccineCertificate(
          vaccineId: vaccineId,
          file: _certificateFile!,
        );
        setState(() => _uploadingCert = false);
      }

      final vaccine = VaccineModel(
        id: vaccineId,
        petId: _selectedPet!.id,
        name: _vaccineCtrl.text.trim(),
        applicationDate: _applicationDate,
        nextDoseDate: _nextDoseDate,
        veterinarian:
            _vetCtrl.text.trim().isEmpty ? null : _vetCtrl.text.trim(),
        clinic:
            _clinicCtrl.text.trim().isEmpty ? null : _clinicCtrl.text.trim(),
        batchNumber:
            _batchCtrl.text.trim().isEmpty ? null : _batchCtrl.text.trim(),
        certificateUrl: certificateUrl,
        status: _nextDoseDate != null &&
                _nextDoseDate!.isBefore(DateTime.now())
            ? 'overdue'
            : 'pending',
        createdAt: DateTime.now(),
      );

      await _vaccineService.createVaccine(vaccine);

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
                'Foto del Carnet',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toma o selecciona una foto legible del comprobante',
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
              if (_certificateFile != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _certificateFile = null);
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
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (xFile != null) {
        setState(() => _certificateFile = File(xFile.path));
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
          'Nueva Vacuna',
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
            // ── Pet Selector ──
            _buildLabel('Mascota'),
            const SizedBox(height: 6),
            if (_loadingPets)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (_pets.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Registra una mascota primero',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedPet?.id,
                items: _pets
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Row(
                            children: [
                              const Icon(Icons.pets,
                                  size: 18, color: AppColors.primaryContainer),
                              const SizedBox(width: 8),
                              Text(
                                p.name,
                                style: AppTypography.bodyLg.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                ' • ${p.breed}',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: widget.initialPetId != null
                    ? null // Locked when coming from detail screen
                    : (v) {
                        setState(() {
                          _selectedPet =
                              _pets.where((p) => p.id == v).firstOrNull;
                        });
                      },
                decoration: _inputDecoration(
                  hint: 'Selecciona una mascota',
                  icon: Icons.pets,
                ),
                validator: (_) =>
                    _selectedPet == null ? 'Selecciona una mascota' : null,
              ),
            const SizedBox(height: 24),

            // ── Pet Identity Card ──
            if (_selectedPet != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(20),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.pets,
                          color: AppColors.primaryContainer, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPet!.name,
                          style: AppTypography.titleLg.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          '${_selectedPet!.breed} • ${_selectedPet!.ageYears} ${_selectedPet!.ageYears == 1 ? 'año' : 'años'}',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.onPrimaryContainer.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.pets,
                          color: AppColors.outline, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona una mascota',
                          style: AppTypography.titleLg.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                        Text(
                          'Historial de Vacunación',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // ── Vaccine name ──
            _buildLabel('Nombre de la Vacuna'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              items: _vaccineOptions
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: AppTypography.bodyMd),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) _vaccineCtrl.text = v;
                _formKey.currentState?.validate();
              },
              decoration: _inputDecoration(
                hint: 'Selecciona una vacuna',
                icon: Icons.vaccines,
              ),
              validator: (v) =>
                  _vaccineCtrl.text.isEmpty ? 'Selecciona una vacuna' : null,
            ),
            const SizedBox(height: 20),

            // ── Application date ──
            _buildLabel('Fecha de Aplicación'),
            const SizedBox(height: 6),
            _buildDatePicker(
              date: _applicationDate,
              onChanged: (d) => setState(() => _applicationDate = d),
            ),
            const SizedBox(height: 20),

            // ── Next dose date ──
            _buildLabel('Próxima Dosis (Refuerzo) — opcional'),
            const SizedBox(height: 6),
            _buildDatePicker(
              date: _nextDoseDate,
              onChanged: (d) => setState(() => _nextDoseDate = d),
              hint: 'Selecciona fecha de refuerzo',
            ),
            const SizedBox(height: 24),

            // ── Medical details card ──
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles Médicos',
                    style: AppTypography.titleLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Veterinario / Clínica'),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _vetCtrl,
                    hint: 'Dr. Martínez o Clínica Central',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Clínica'),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _clinicCtrl,
                    hint: 'Nombre de la clínica',
                    icon: Icons.local_hospital,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Número de Lote / Batch'),
                  const SizedBox(height: 6),
                  _buildInput(
                    controller: _batchCtrl,
                    hint: 'Ej: LOT-2024-X99',
                    icon: Icons.qr_code,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Certificate photo picker ──
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _certificateFile != null
                        ? AppColors.primary.withAlpha(50)
                        : AppColors.outlineVariant.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    if (_certificateFile != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _certificateFile!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Uploading overlay
                          if (_uploadingCert)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(80),
                                  borderRadius: BorderRadius.circular(16),
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
                            ),
                        ],
                      )
                    else ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.add_a_photo,
                            color: AppColors.primaryContainer, size: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Foto del Carnet',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toca para tomar foto o seleccionar de la galería',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            AppButton.primary(
              label: 'Guardar Registro',
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
      padding: const EdgeInsets.only(left: 4, bottom: 6),
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
  }) {
    return TextFormField(
      controller: controller,
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outlineVariant),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      ),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required ValueChanged<DateTime> onChanged,
    String? hint,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                  surface: AppColors.surface,
                  onSurface: AppColors.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              date != null
                  ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                  : (hint ?? 'Seleccionar fecha'),
              style: AppTypography.bodyMd.copyWith(
                color: date != null
                    ? AppColors.onSurface
                    : AppColors.outlineVariant,
              ),
            ),
          ],
        ),
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
                if (_certificateFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.file(
                      _certificateFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                  '¡Registro Guardado!',
                  style: AppTypography.headlineMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedPet != null)
                  Text(
                    'Vacuna registrada para ${_selectedPet!.name}.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    'La vacuna ha sido registrada correctamente.',
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
