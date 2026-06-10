import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/vaccine_model.dart';
import '../../../../core/services/vaccine_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/widgets/app_button.dart';

class RegisterVaccineScreen extends StatefulWidget {
  const RegisterVaccineScreen({super.key});

  @override
  State<RegisterVaccineScreen> createState() => _RegisterVaccineScreenState();
}

class _RegisterVaccineScreenState extends State<RegisterVaccineScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _vaccineService = VaccineService();

  final _vaccineCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _clinicCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();

  DateTime _applicationDate = DateTime.now();
  DateTime? _nextDoseDate;
  bool _loading = false;
  bool _showSuccess = false;

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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final vaccine = VaccineModel(
        id: generateId(),
        petId: '', // Will be set by the service or from context
        name: _vaccineCtrl.text.trim(),
        applicationDate: _applicationDate,
        nextDoseDate: _nextDoseDate,
        veterinarian: _vetCtrl.text.trim().isEmpty ? null : _vetCtrl.text.trim(),
        clinic: _clinicCtrl.text.trim().isEmpty ? null : _clinicCtrl.text.trim(),
        batchNumber: _batchCtrl.text.trim().isEmpty ? null : _batchCtrl.text.trim(),
        status: _nextDoseDate != null && _nextDoseDate!.isBefore(DateTime.now())
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
            // Pet identity card (placeholder)
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
                        'Nombre de la Mascota',
                        style: AppTypography.titleLg.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Historial de Vacunación',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onPrimaryContainer.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vaccine name
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
              validator: (v) => _vaccineCtrl.text.isEmpty ? 'Selecciona una vacuna' : null,
            ),
            const SizedBox(height: 20),

            // Application date
            _buildLabel('Fecha de Aplicación'),
            const SizedBox(height: 6),
            _buildDatePicker(
              date: _applicationDate,
              onChanged: (d) => setState(() => _applicationDate = d),
            ),
            const SizedBox(height: 20),

            // Next dose date
            _buildLabel('Próxima Dosis (Refuerzo) — opcional'),
            const SizedBox(height: 6),
            _buildDatePicker(
              date: _nextDoseDate,
              onChanged: (d) => setState(() => _nextDoseDate = d),
              hint: 'Selecciona fecha de refuerzo',
            ),
            const SizedBox(height: 24),

            // Medical details card
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

            // Photo upload placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.outlineVariant.withAlpha(50),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
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
                    'Sube una foto legible del sello o comprobante.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Subir foto'),
                  ),
                ],
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
