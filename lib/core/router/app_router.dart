import 'package:go_router/go_router.dart';

import '../../presentation/home/home_screen.dart';
import '../../presentation/role_dashboard/role_dashboard_screen.dart';
import '../../presentation/role_feature/role_feature_screen.dart';

abstract final class AppRouter {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String teamRegistration = '/teams';
  static const String scoreboard = '/scoreboard';
  static const String winner = '/winner';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: dashboard,
        builder: (context, state) {
          return RoleDashboardScreen(
            roleId: state.uri.queryParameters['role'] ?? 'usuario',
            email: state.uri.queryParameters['email'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/feature/:role/:featureId',
        builder: (context, state) {
          return RoleFeatureScreen(
            roleId: state.pathParameters['role'] ?? 'orientador',
            featureId: state.pathParameters['featureId'] ?? 'estudiantes',
            email: state.uri.queryParameters['email'] ?? '',
          );
        },
      ),
    ],
  );
}
