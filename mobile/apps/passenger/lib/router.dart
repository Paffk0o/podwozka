import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'features/history/history_screens.dart';
import 'home_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>(
  (ref) => createAuthRouter(
    ref,
    login: const LoginScreen(
      title: 'Podwózka',
      subtitle: 'Przejazdy w Twojej gminie — teraz albo na później.',
    ),
    homePath: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const ProfileGate(child: HomeScreen()),
        routes: [
          GoRoute(path: 'history', builder: (_, _) => const HistoryScreen()),
          GoRoute(
            path: 'rides/:rideId',
            builder: (_, state) => RideDetailsScreen(rideId: state.pathParameters['rideId']!),
          ),
        ],
      ),
    ],
  ),
);
