import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'features/onboarding/providers/onboarding_controller.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/work/ui/work_screen.dart';

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

/// Work mode: online switch, offers, active ride (board, earnings, history: next PR).
class WorkScreen extends ConsumerWidget {
  const WorkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(wsConnectionStateProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podwózka Kierowca'),
        bottom: connection == WsConnectionState.waitingToReconnect
            ? const PreferredSize(
                preferredSize: Size.fromHeight(24),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('Łączenie z serwerem…'),
                ),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: const WorkPanelScreen(),
    );
  }
}
