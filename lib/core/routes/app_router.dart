import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/pets/presentation/screens/pet_list_screen.dart';
import '../../features/pets/presentation/screens/pet_detail_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccination_status_screen.dart';
import '../../features/vaccinations/presentation/screens/vaccine_history_screen.dart';
import '../../features/medical_visits/presentation/screens/visits_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

/// Route path constants
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const pets = '/pets';
  static const petDetail = '/pets/:id';
  static const vaccinations = '/vaccinations';
  static const vaccineHistory = '/vaccinations/history';
  static const visits = '/visits';
  static const notifications = '/notifications';
  static const profile = '/profile';
}

/// GoRouter instance for the app
final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.vaccinations,
      builder: (_, _) => const VaccinationStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.vaccineHistory,
      builder: (_, _) => const VaccineHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.visits,
      builder: (_, _) => const VisitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, _) => const ProfileScreen(),
    ),
    ShellRoute(
      builder: (_, _, child) => AppBottomNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (_, _) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.pets,
          pageBuilder: (_, _) => const NoTransitionPage(
            child: PetListScreen(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => PetDetailScreen(
                petId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.notifications,
          pageBuilder: (_, _) => const NoTransitionPage(
            child: NotificationsScreen(),
          ),
        ),
      ],
    ),
  ],
);
