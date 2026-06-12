import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pets/presentation/screens/pet_list_screen.dart';
import '../../features/pets/presentation/screens/pet_detail_screen.dart';
import '../../features/pets/presentation/screens/add_pet_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccination_status_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccine_history_screen.dart';
import '../../features/vaccinations/presentation/screens/register_vaccine_screen.dart';
import '../../features/medical_visits/presentation/screens/visits_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/health_preferences_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../core/models/profile_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../services/auth_service.dart';

/// Route path constants
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const pets = '/pets';
  static const petDetail = '/pets/:id';
  static const addPet = '/pets/add';
  static const vaccinations = '/vaccinations';
  static const vaccineHistory = '/vaccinations/history';
  static const registerVaccine = '/vaccinations/register';
  static const visits = '/visits';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const healthPreferences = '/profile/health-preferences';
  static const notificationSettings = '/profile/notification-settings';
}

/// Routes that require the user to be authenticated.
final _protectedRoutes = <String>{
  AppRoutes.home,
  AppRoutes.pets,
  AppRoutes.notifications,
  AppRoutes.profile,
  AppRoutes.editProfile,
  AppRoutes.healthPreferences,
  AppRoutes.notificationSettings,
  AppRoutes.vaccinations,
  AppRoutes.vaccineHistory,
  AppRoutes.registerVaccine,
  AppRoutes.visits,
};

/// Routes that should only be accessible when the user is **not** authenticated.
final _guestOnlyRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.login,
};

/// GoRouter instance for the app
final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: _authGuard,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.vaccinations,
      builder: (_, state) => const VaccinationStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.vaccineHistory,
      builder: (_, state) => const VaccineHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.visits,
      builder: (_, state) => const VisitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.addPet,
      builder: (_, state) => const AddPetScreen(),
    ),
    GoRoute(
      path: AppRoutes.registerVaccine,
      builder: (_, state) => RegisterVaccineScreen(
        initialPetId: state.extra as String?,
      ),
    ),
    // Pet detail is outside ShellRoute so it renders as a full-screen page
    // without the bottom navigation bar (matching the design intent).
    GoRoute(
      path: AppRoutes.petDetail,
      builder: (_, state) => PetDetailScreen(
        petId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (_, state) => EditProfileScreen(
        profile: state.extra as ProfileModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.healthPreferences,
      builder: (_, state) => HealthPreferencesScreen(
        profile: state.extra as ProfileModel?,
      ),
    ),
    GoRoute(
      path: AppRoutes.notificationSettings,
      builder: (_, state) => NotificationSettingsScreen(
        profile: state.extra as ProfileModel?,
      ),
    ),
    ShellRoute(
      builder: (_, state, child) => AppBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (_, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.pets,
          pageBuilder: (_, state) => const NoTransitionPage(
            child: PetListScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          pageBuilder: (_, state) => const NoTransitionPage(
            child: NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (_, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);

/// Authentication redirect guard.
///
/// - If the user is on a guest-only route (splash, login) and already
///   authenticated → redirect to [/home].
/// - If the user is on a protected route and **not** authenticated → redirect
///   to [/login].
/// - Otherwise → let the navigation proceed (`null`).
String? _authGuard(BuildContext context, GoRouterState state) {
  final isLoggedIn = AuthService().isAuthenticated;
  final path = state.uri.path;

  // Splash → always let it render so it can decide on its own.
  if (path == AppRoutes.splash) return null;

  // Authenticated user trying to reach a guest-only route → go home.
  if (isLoggedIn && _matchesAny(path, _guestOnlyRoutes)) {
    return AppRoutes.home;
  }

  // Unauthenticated user trying to reach a protected page → go login.
  if (!isLoggedIn && _matchesAny(path, _protectedRoutes)) {
    return AppRoutes.login;
  }

  return null;
}

/// Checks whether [path] matches any route in [routes], either exactly or as
/// a prefix (for routes that have nested sub-routes, e.g. `/pets/123`).
bool _matchesAny(String path, Set<String> routes) {
  return routes.any((r) => path == r || path.startsWith('$r/'));
}
