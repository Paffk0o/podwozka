import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'features/ordering/ui/order_screen.dart';
import 'features/ride_tracking/providers/active_ride_controller.dart';
import 'features/ride_tracking/ui/ride_screen.dart';

/// Ride in progress (also after an app restart) → ride screen; otherwise ordering.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeRideProvider);
    return switch (active) {
      AsyncData(:final value?) => RideScreen(tracked: value),
      AsyncData() => const OrderScreen(),
      AsyncError(:final error) when !active.isLoading => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(error), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(activeRideProvider),
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      ),
      // Keep showing the previous screen while reloading after a reconnect.
      _ when active.value != null => RideScreen(tracked: active.value!),
      _ when active.hasValue => const OrderScreen(),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}
