import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mascota_saludable/features/auth/presentation/screens/splash_screen.dart';

/// Minimal wrapper so the SplashScreen can navigate via GoRouter.
Widget _buildTestApp() {
  return MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(
            body: Center(child: Text('Login')),
          ),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('Splash screen renders branding', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());

    // Verify the splash screen shows the app name and tagline
    expect(find.text('Mascota Saludable'), findsOneWidget);
    expect(find.text('Cuida de los que más te importan'), findsOneWidget);

    // Advance the splash timer and pump the navigation frame
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // After the timer, it should navigate to /login (since Supabase isn't
    // initialized, AuthService().isAuthenticated is false).
    expect(find.text('Login'), findsOneWidget);
  });
}
