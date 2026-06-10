import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Brief delay so the splash screen is visible.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final isLoggedIn = AuthService().isAuthenticated;
    final destination = isLoggedIn ? AppRoutes.home : AppRoutes.login;

    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 24),
            Text(
              'Mascota Saludable',
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuida de los que más te importan',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryFixedDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
