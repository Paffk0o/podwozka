import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'screens/home_screen.dart';

abstract final class Routes {
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>(
  (ref) => createAuthRouter(
    ref,
    login: const LoginScreen(
      title: 'Podwózka Kierowca',
      subtitle: 'Woź sąsiadów i zarabiaj w swojej gminie.',
    ),
    homePath: Routes.home,
    routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
  ),
);
