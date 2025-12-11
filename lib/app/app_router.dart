import 'package:go_router/go_router.dart';
import '../data/repositories/auth_repo.dart';
import 'routes_list.dart';

class AppRouter {
  final GoRouter router;

  AppRouter(AuthRepo auth)
      : router = GoRouter(
          navigatorKey: rootNavigatorKey, // ОБЯЗАТЕЛЬНО!!!
          initialLocation: '/welcome',
          refreshListenable: auth,
          redirect: (context, state) {
            final isLoggedIn = auth.isLoggedIn;
            final isLoggingIn = state.uri.path == '/login';
            final isWelcome = state.uri.path == '/welcome';

            if (!isLoggedIn && !isLoggingIn && !isWelcome) return '/welcome';
            if (isLoggedIn && (isLoggingIn || isWelcome)) return '/supplies';
            return null;
          },
          routes: appRoutes,
        );
}