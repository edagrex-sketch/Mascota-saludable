import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──
  int _selectedTab = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;
  bool _showSuccess = false;

  // ── Animation ──
  late final AnimationController _successAnimCtrl;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _successAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = CurvedAnimation(
      parent: _successAnimCtrl,
      curve: Curves.elasticOut,
    );
    _successFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimCtrl,
        curve: const Interval(0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _successAnimCtrl.dispose();
    super.dispose();
  }

  // ── Auth ──

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final auth = AuthService();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_selectedTab == 0) {
        // ── Login ──
        await auth.signIn(email: email, password: password);
        if (!mounted) return;
        _onAuthSuccess();
      } else {
        // ── Register ──
        AuthResponse? response;

        try {
          response = await auth.signUp(email: email, password: password);
        } catch (e) {
          final msg = e.toString();
          // If "User already registered", it means the account exists → just log in.
          if (msg.contains('User already registered')) {
            await auth.signIn(email: email, password: password);
            if (!mounted) return;
            _onAuthSuccess();
            return;
          }
          rethrow;
        }

        if (!mounted) return;

        // Session created immediately (email confirmation disabled).
        if (response.session != null) {
          _onAuthSuccess();
          return;
        }

        // Email confirmation is ON → try an auto‑login anyway.
        await auth.signIn(email: email, password: password);
        if (!mounted) return;

        if (AuthService().isAuthenticated) {
          _onAuthSuccess();
        } else {
          _showConfirmationMessage();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _mapAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Plays the success animation then navigates home.
  void _onAuthSuccess() {
    setState(() => _showSuccess = true);
    _successAnimCtrl.forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) context.go(AppRoutes.home);
    });
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
    if (msg.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (msg.contains('network') || msg.contains('SocketException')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }

  // ── Build ──

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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _showSuccess ? _buildSuccessContent() : _buildFormContent(),
          ),
        ),
      ),
    );
  }

  // ── Success content ──

  Widget _buildSuccessContent() {
    return SizedBox(
      key: const ValueKey('success'),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _successFade,
              child: ScaleTransition(
                scale: _successScale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 52,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _successFade,
              child: Text(
                _selectedTab == 0 ? '¡Bienvenido!' : 'Cuenta creada',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _successFade,
              child: Text(
                'Redirigiendo al inicio…',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form content ──

  Widget _buildFormContent() {
    return Column(
      key: const ValueKey('form'),
      children: [
        const SizedBox(height: 32),
        // ── Hero ──
        _buildHero(),
        const SizedBox(height: 32),

        // ── Auth card ──
        _buildAuthCard(),

        const SizedBox(height: 24),

        // ── Legal ──
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
    );
  }

  // ── Hero section ──

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'logo.png',
              width: 96,
              height: 96,
              cacheWidth: 96,
              cacheHeight: 96,
              fit: BoxFit.cover,
            ),
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
    );
  }

  // ── Auth card ──

  Widget _buildAuthCard() {
    return Container(
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
            // ── Tab selector (animated) ──
            _buildAnimatedTabs(),
            const SizedBox(height: 24),

            // ── Animated error ──
            _buildAnimatedError(),

            // ── Email ──
            AppTextField(
              label: 'Correo Electrónico',
              icon: Icons.mail_outline,
              controller: _emailController,
              hint: 'ejemplo@correo.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Password ──
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
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Submit button ──
            _buildSubmitButton(),
            const SizedBox(height: 16),

            // ── Divider ──
            _buildDivider(),
            const SizedBox(height: 16),

            // ── Social buttons ──
            _buildSocialRow(),
          ],
        ),
      ),
    );
  }

  // ── Animated tabs ──

  Widget _buildAnimatedTabs() {
    return Container(
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
          Expanded(child: _buildTab(0, 'Iniciar Sesión')),
          Expanded(child: _buildTab(1, 'Crear Cuenta')),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _errorMessage = null; // clear error on tab switch
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTypography.labelLg.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  // ── Animated error ──

  Widget _buildAnimatedError() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _errorMessage != null
          ? Padding(
              key: ValueKey(_errorMessage),
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withAlpha(50),
                  ),
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
                    GestureDetector(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no_error')),
    );
  }

  // ── Submit button ──

  Widget _buildSubmitButton() {
    return AppButton.primary(
      label: _selectedTab == 0 ? 'Entrar' : 'Crear Cuenta',
      onPressed: _loading ? null : _handleSubmit,
      loading: _loading,
    );
  }

  // ── Divider ──

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o continuar con',
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.outlineVariant)),
      ],
    );
  }

  // ── Social buttons ──

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata, size: 20),
            label: Text('Google', style: AppTypography.labelLg),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.apple, size: 20),
            label: Text('Apple', style: AppTypography.labelLg),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
