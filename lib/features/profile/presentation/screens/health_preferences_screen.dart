import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class HealthPreferencesScreen extends StatefulWidget {
  final ProfileModel? profile;

  const HealthPreferencesScreen({super.key, this.profile});

  @override
  State<HealthPreferencesScreen> createState() => _HealthPreferencesScreenState();
}

class _HealthPreferencesScreenState extends State<HealthPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  final _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.profile?.healthPreferences);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay sesión activa')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProfile = ProfileModel(
        id: widget.profile?.id ?? user.id,
        fullName: widget.profile?.fullName,
        avatarUrl: widget.profile?.avatarUrl,
        pushNotificationsEnabled: widget.profile?.pushNotificationsEnabled ?? true,
        emailNotificationsEnabled: widget.profile?.emailNotificationsEnabled ?? true,
        healthPreferences: _notesController.text.trim(),
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferencias guardadas correctamente')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar preferencias: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preferencias de Salud'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alergias y Condiciones',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anota aquí tus alergias, condiciones médicas crónicas o cualquier nota de salud relevante. Esta información nos ayuda a personalizar las sugerencias y avisos de la app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Tus notas médicas',
                      icon: Icons.notes,
                      hint: 'Ej. Alergia al pelo de gato, asma...',
                      controller: _notesController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 48),
                    AppButton.primary(
                      label: 'Guardar Preferencias',
                      onPressed: _savePreferences,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
