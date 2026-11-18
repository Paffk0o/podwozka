import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'features/onboarding/providers/onboarding_controller.dart';
import 'features/onboarding/ui/onboarding_screen.dart';

/// Approved driver with the `driver` role in the token → work mode; everyone else → application.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRole = ref.watch(
      authControllerProvider.select((auth) => auth.value?.hasRole('driver') ?? false),
    );
    final status = ref.watch(onboardingProvider.select((s) => s.value?.profile?.status));
    if (hasRole && status == DriverStatus.approved) return const WorkScreen();
    return const OnboardingScreen();
  }
}

/// Work mode (online switch, offers, active ride) — stage 2, point 6.
class WorkScreen extends ConsumerWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Podwózka Kierowca'),
      actions: [
        IconButton(
          tooltip: 'Wyloguj',
          icon: const Icon(Icons.logout),
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      ],
    ),
    body: const Center(child: Text('Konto kierowcy aktywne.')),
  );
}
