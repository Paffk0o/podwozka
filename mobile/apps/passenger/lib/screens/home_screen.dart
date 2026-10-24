import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Day-1 placeholder: proves login + authenticated API call work end to end.
/// TODO(agent-mobile): replace with the map + "Dokąd jedziemy?" ordering flow.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podwózka'),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: profile.when(
          data: (p) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cześć, ${p.fullName ?? p.email ?? 'pasażerze'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Role: ${p.roles.join(', ')}'),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nie udało się pobrać profilu z API.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(myProfileProvider),
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
