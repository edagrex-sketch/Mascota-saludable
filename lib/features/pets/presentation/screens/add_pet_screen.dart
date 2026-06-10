import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/services/pet_service.dart';
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

  bool _loading = false;
  bool _showSuccess = false;

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
      final pet = PetModel(
        id: generateId(),
        userId: '',
        name: _nameCtrl.text.trim(),
        breed: _breedCtrl.text.trim(),
        ageYears: int.tryParse(_ageCtrl.text) ?? 0,
        weightKg: double.tryParse(_weightCtrl.text) ?? 0,
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
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(30),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 48,
                  color: AppColors.primaryContainer,
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
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Requerido' : null,
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
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Requerido' : null,
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
