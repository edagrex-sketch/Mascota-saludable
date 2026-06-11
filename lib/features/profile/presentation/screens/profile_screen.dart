import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/models/pet_model.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/models/profile_model.dart';
import '../../../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _petService = PetService();
  final _profileService = ProfileService();
  
  List<PetModel> _pets = [];
  ProfileModel? _profile;
  bool _loading = true;
  String _userName = 'Usuario';
  String _memberSince = 'Miembro...';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = AuthService().currentUser;
    if (user != null) {
      String membership = 'Miembro...';
      if (user.createdAt.isNotEmpty) {
        try {
          final date = DateTime.parse(user.createdAt);
          const months = [
            'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
            'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
          ];
          membership = 'Miembro desde ${months[date.month - 1]} ${date.year}';
        } catch (_) {}
      }
      
      if (mounted) {
        setState(() {
          _memberSince = membership;
        });
      }
    }

    try {
      final futures = await Future.wait([
        _petService.getPets(),
        _profileService.getProfile(),
      ]);
      
      final pets = futures[0] as List<PetModel>;
      final profile = futures[1] as ProfileModel?;
      
      if (mounted) {
        setState(() {
          _pets = pets;
          _profile = profile;
          _userName = profile?.fullName ?? user?.email?.split('@').first ?? 'Usuario';
          _avatarUrl = profile?.avatarUrl;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Gestor de Salud',
          style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant),
              image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _avatarUrl == null || _avatarUrl!.isEmpty
                ? const Icon(Icons.person, size: 18, color: AppColors.outline)
                : null,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Profile Header Section
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                      image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _avatarUrl == null || _avatarUrl!.isEmpty
                        ? const Icon(Icons.person, size: 48, color: AppColors.outline)
                        : null,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final updated = await context.push<bool>(
                        AppRoutes.editProfile,
                        extra: _profile,
                      );
                      if (updated == true) {
                        setState(() => _loading = true);
                        _loadData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ]
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _userName,
                style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface),
              ),
              Text(
                _memberSince,
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Quick Shortcut: My Pets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Mascotas',
                style: AppTypography.titleLg.copyWith(color: AppColors.primary),
              ),
              if (_pets.isNotEmpty)
                TextButton(
                  onPressed: () => context.go(AppRoutes.pets),
                  child: Text(
                    'Ver todas',
                    style: AppTypography.labelLg.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_pets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Aún no tienes mascotas registradas.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            )
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: _PetCard(
                      name: pet.name,
                      breed: pet.breed ?? 'Sin raza',
                      imageUrl: pet.photoUrl,
                    ),
                  );
                },
              ),
            ),
            
          const SizedBox(height: 32),

          // List Sections
          _SettingsTile(
            icon: Icons.medical_services,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primaryFixed,
            title: 'Preferencias de Salud',
            subtitle: 'Alergias y condiciones crónicas',
            onTap: () async {
              final updated = await context.push<bool>(
                AppRoutes.healthPreferences,
                extra: _profile,
              );
              if (updated == true) {
                setState(() => _loading = true);
                _loadData();
              }
            },
          ),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.notifications,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryFixed,
            title: 'Configuración de Notificaciones',
            subtitle: 'Vacunas, medicación y alertas',
            onTap: () async {
              final updated = await context.push<bool>(
                AppRoutes.notificationSettings,
                extra: _profile,
              );
              if (updated == true) {
                setState(() => _loading = true);
                _loadData();
              }
            },
          ),

          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.help_outline,
            iconColor: AppColors.outline,
            iconBgColor: AppColors.surfaceContainer,
            title: 'Ayuda y Soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: () {},
          ),
          const SizedBox(height: 48),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _logout(context),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.errorContainer.withOpacity(0.3),
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.error.withOpacity(0.1)),
                ),
              ),
              child: Text('Cerrar Sesión', style: AppTypography.labelLg),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Versión 2.4.0 (PetCare Gold)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.outlineVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Cerrar Sesión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que deseas cerrar sesión?'),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.name,
    required this.breed,
    this.imageUrl,
  });

  final String name;
  final String breed;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3C40).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainer,
              image: imageUrl != null && imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl!.isEmpty
                ? const Icon(Icons.pets, color: AppColors.outline)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppTypography.labelLg.copyWith(color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  breed,
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3C40).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
