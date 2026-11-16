import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_tokens.dart';
import '../providers.dart';

/// Paths handled by [createAuthRouter]. Apps add their own routes under [homePath].
abstract final class AuthRoutes {
  static const splash = '/';
  static const login = '/login';
}

/// GoRouter that keeps signed-out users on the login screen and signed-in users away from it.
///
/// ```dart
/// final routerProvider = Provider<GoRouter>((ref) => createAuthRouter(
///   ref,
///   login: const LoginScreen(title: ..., subtitle: ...),
///   homePath: '/home',
///   routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
/// ));
/// ```
GoRouter createAuthRouter(
  Ref ref, {
  required Widget login,
  required String homePath,
  required List<RouteBase> routes,
}) {
  // Bridge Riverpod -> Listenable so GoRouter re-runs `redirect` when the session changes.
  final authState = ValueNotifier<AsyncValue<AuthTokens?>>(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => authState.value = next);
  ref.onDispose(authState.dispose);

  final router = GoRouter(
    initialLocation: AuthRoutes.splash,
    refreshListenable: authState,
    redirect: (context, state) =>
        authRedirect(auth: authState.value, location: state.matchedLocation, homePath: homePath),
    routes: [
      GoRoute(path: AuthRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AuthRoutes.login, builder: (_, _) => login),
      ...routes,
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Pure redirect logic (unit-tested).
String? authRedirect({
  required AsyncValue<AuthTokens?> auth,
  required String location,
  required String homePath,
}) {
  if (!auth.hasValue) {
    // Still restoring the session from secure storage (or it failed) — wait on the splash.
    return auth.hasError ? AuthRoutes.login : AuthRoutes.splash;
  }
  final signedIn = auth.value != null;
  if (!signedIn) return location == AuthRoutes.login ? null : AuthRoutes.login;
  if (location == AuthRoutes.login || location == AuthRoutes.splash) return homePath;
  return null;
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
