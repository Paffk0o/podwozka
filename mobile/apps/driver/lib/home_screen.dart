import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'features/onboarding/providers/onboarding_controller.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/board/board_screen.dart';
import 'features/earnings/earnings_screen.dart';
import 'features/history/history_screen.dart';
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

/// Work mode: Praca (online, offers, ride) · Giełda · Zarobki · Historia.
class WorkScreen extends ConsumerStatefulWidget {
  const WorkScreen({super.key});

  @override
  ConsumerState<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends ConsumerState<WorkScreen> {
  int _tab = 0;

  static const _titles = ['Podwózka Kierowca', 'Giełda rezerwacji', 'Zarobki', 'Historia kursów'];

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(wsConnectionStateProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
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
      // The work tab stays alive (map, offer countdown) while other tabs are open.
      body: IndexedStack(
        index: _tab,
        children: [
          const WorkPanelScreen(),
          if (_tab == 1) const BoardScreen() else const SizedBox.shrink(),
          if (_tab == 2) const EarningsScreen() else const SizedBox.shrink(),
          if (_tab == 3) const DriverHistoryScreen() else const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_taxi), label: 'Praca'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Giełda'),
          NavigationDestination(icon: Icon(Icons.payments), label: 'Zarobki'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historia'),
        ],
      ),
    );
  }
}
