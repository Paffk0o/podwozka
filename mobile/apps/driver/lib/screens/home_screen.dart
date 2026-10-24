import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Day-1 placeholder.
/// TODO(agent-mobile): approved driver -> online/offline switch, offers, active ride;
/// no `driver` role -> driver application flow (vehicle, documents, submit).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final isDriver = ref.watch(
      authControllerProvider.select((auth) => auth.value?.hasRole('driver') ?? false),
    );
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: profile.when(
            data: (p) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cześć, ${p.fullName ?? p.email ?? 'kierowco'}!',
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  isDriver
                      ? 'Konto kierowcy aktywne. Tu pojawi się przełącznik „Jestem dostępny”.'
                      : 'Nie jesteś jeszcze kierowcą. Tu pojawi się wniosek: pojazd i dokumenty.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => OutlinedButton(
              onPressed: () => ref.invalidate(myProfileProvider),
              child: const Text('Nie udało się pobrać profilu — spróbuj ponownie'),
            ),
          ),
        ),
      ),
    );
  }
}
