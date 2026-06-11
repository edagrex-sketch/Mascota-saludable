import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../shared/widgets/app_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final ProfileModel? profile;

  const NotificationSettingsScreen({super.key, this.profile});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _profileService = ProfileService();
  bool _isLoading = false;
  
  late bool _pushEnabled;
  late bool _emailEnabled;

  @override
  void initState() {
    super.initState();
    _pushEnabled = widget.profile?.pushNotificationsEnabled ?? true;
    _emailEnabled = widget.profile?.emailNotificationsEnabled ?? true;
  }

  Future<void> _saveSettings() async {
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
        pushNotificationsEnabled: _pushEnabled,
        emailNotificationsEnabled: _emailEnabled,
        healthPreferences: widget.profile?.healthPreferences,
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada correctamente')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar configuración: $e')),
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
        title: const Text('Notificaciones'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSwitchTile(
                  title: 'Notificaciones',
                  subtitle: 'Alertas en tu dispositivo sobre citas, medicinas y recordatorios.',
                  icon: Icons.notifications_active_outlined,
                  value: _pushEnabled,
                  onChanged: (val) => setState(() => _pushEnabled = val),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  title: 'Correos Electrónicos',
                  subtitle: 'Resúmenes semanales, noticias y alertas críticas a tu email.',
                  icon: Icons.email_outlined,
                  value: _emailEnabled,
                  onChanged: (val) => setState(() => _emailEnabled = val),
                ),
                const SizedBox(height: 48),
                AppButton.primary(
                  label: 'Guardar Configuración',
                  onPressed: _saveSettings,
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
