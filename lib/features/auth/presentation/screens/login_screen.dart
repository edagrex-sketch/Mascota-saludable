import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedTab = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final auth = AuthService();

      if (_selectedTab == 0) {
        // ── Login ──
        await auth.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) context.go(AppRoutes.home);
      } else {
        // ── Register ──
        final response = await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (response.session != null) {
          // Session created immediately (email confirmation disabled).
          context.go(AppRoutes.home);
        } else {
          // Email confirmation is required — notify the user.
          _showConfirmationMessage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapAuthError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showConfirmationMessage() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Revisa tu correo'),
        content: const Text(
          'Te enviamos un enlace de confirmación. Revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Entendido',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _mapAuthError(Object error) {
    final msg = error.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (msg.contains('User already registered')) {
      return 'Ya existe una cuenta con este correo.';
    }
    if (msg.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.pets, size: 24),
            const SizedBox(width: 8),
            Text(
              'Gestor de Salud',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Hero section
              Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      size: 40,
                      color: AppColors.primaryFixed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenido de nuevo',
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cuida de los que más te importan hoy.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Auth card
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Tab selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  decoration: BoxDecoration(
                                    border: _selectedTab == 0
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Iniciar Sesión',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.labelLg.copyWith(
                                      color: _selectedTab == 0
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTab = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  decoration: BoxDecoration(
                                    border: _selectedTab == 1
                                        ? const Border(
                                            bottom: BorderSide(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    'Crear Cuenta',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.labelLg.copyWith(
                                      color: _selectedTab == 1
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 18, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email field
                      AppTextField(
                        label: 'Correo Electrónico',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        hint: 'ejemplo@correo.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) {
                            return 'Correo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      AppTextField(
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        hint: '••••••••',
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (v.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      AppButton.primary(
                        label: _selectedTab == 0 ? 'Entrar' : 'Crear Cuenta',
                        onPressed: _handleSubmit,
                        loading: _loading,
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.outlineVariant)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'o continuar con',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.g_mobiledata, size: 20),
                              label: Text(
                                'Google',
                                style: AppTypography.labelLg,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.onSurface,
                                side: const BorderSide(
                                    color: AppColors.outlineVariant),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.apple, size: 20),
                              label: Text(
                                'Apple',
                                style: AppTypography.labelLg,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.onSurface,
                                side: const BorderSide(
                                    color: AppColors.outlineVariant),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Legal text
              Text.rich(
                TextSpan(
                  text: 'Al continuar, aceptas nuestros ',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Términos de Servicio',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' y '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
