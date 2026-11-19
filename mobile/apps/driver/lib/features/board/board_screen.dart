import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../work/ui/work_screen.dart' show paymentLabel, runAction;
import 'board_repository.dart';

/// Reservations board of my region; reloads on `board.updated` and after reconnects.
class BoardController extends AsyncNotifier<List<Ride>> {
  @override
  Future<List<Ride>> build() async {
    final socket = ref.watch(podwozkaSocketProvider);
    final events = socket.events.listen((event) {
      if (event is BoardUpdated) ref.invalidateSelf();
    });
    final states = socket.states.listen((s) {
      if (s == WsConnectionState.connected) ref.invalidateSelf();
    });
    ref.onDispose(() {
      unawaited(events.cancel());
      unawaited(states.cancel());
    });
    final rides = await ref.watch(driverRecordsRepositoryProvider).board();
    return [...rides]..sort(byPickupTime);
  }

  Future<void> claim(String rideId) async {
    await ref.read(driverRecordsRepositoryProvider).claim(rideId);
    ref
      ..invalidateSelf()
      ..invalidate(myReservationsProvider);
  }
}

int byPickupTime(Ride a, Ride b) =>
    (a.scheduledAt ?? a.requestedAt).compareTo(b.scheduledAt ?? b.requestedAt);

final boardProvider = AsyncNotifierProvider<BoardController, List<Ride>>(BoardController.new);

/// Reservations I claimed (still ahead), soonest first.
final myReservationsProvider = FutureProvider<List<Ride>>((ref) async {
  final page = await ref.watch(driverRecordsRepositoryProvider).rides(active: true, limit: 50);
  final mine = page.items
      .where((r) => r.scheduledAt != null && r.status == RideStatus.accepted)
      .toList();
  return mine..sort(byPickupTime);
});

/// The app theme makes buttons full-width (`Size.fromHeight`) — not allowed inside a Row.
final _compact = ButtonStyle(minimumSize: WidgetStateProperty.all(const Size(88, 40)));

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  Future<void> _claim(BuildContext context, WidgetRef ref, Ride ride) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Przyjąć rezerwację?'),
        content: Text(
          'Odbiór ${formatDateTime(ride.scheduledAt!)} z adresu ${ride.pickup.address}. '
          'Przypomnimy Ci o kursie godzinę wcześniej. Jeśli nie możesz jechać, oddaj rezerwację '
          'najpóźniej 30 minut przed odbiorem — wróci na giełdę.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Przyjmuję'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await runAction(context, () => ref.read(boardProvider.notifier).claim(ride.id));
    }
  }

  Future<void> _giveBack(BuildContext context, WidgetRef ref, Ride ride) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oddać rezerwację?'),
        content: const Text('Rezerwacja wróci na giełdę i przejmie ją inny kierowca.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Nie')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oddaj')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await runAction(context, () async {
      await ref
          .read(driverRecordsRepositoryProvider)
          .giveBack(ride.id, reason: 'Kierowca oddał rezerwację');
      ref
        ..invalidate(myReservationsProvider)
        ..invalidate(boardProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);
    final mine = ref.watch(myReservationsProvider).value ?? const <Ride>[];
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(myReservationsProvider);
        return ref.refresh(boardProvider.future);
      },
      child: ListView(
        // Pull-to-refresh also when the list is short.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (mine.isNotEmpty) ...[
            Text('Twoje rezerwacje', style: theme.textTheme.titleMedium),
            for (final ride in mine)
              _ReservationTile(
                ride: ride,
                trailing: TextButton(
                  onPressed: () => _giveBack(context, ref, ride),
                  child: const Text('Oddaj'),
                ),
              ),
            const Divider(height: 32),
          ],
          Text('Giełda rezerwacji', style: theme.textTheme.titleMedium),
          Text(
            'Kursy zamówione z wyprzedzeniem w Twojej gminie. Jeśli nikt ich nie przyjmie, 30 minut przed '
            'odbiorem trafią do zwykłego przydziału.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          switch (board) {
            AsyncData(:final value) when value.isEmpty => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Na giełdzie nie ma teraz rezerwacji.', textAlign: TextAlign.center),
            ),
            AsyncData(:final value) => Column(
              children: [
                for (final ride in value)
                  _ReservationTile(
                    ride: ride,
                    trailing: FilledButton.tonal(
                      style: _compact,
                      onPressed: () => _claim(context, ref, ride),
                      child: const Text('Przyjmij'),
                    ),
                  ),
              ],
            ),
            AsyncError(:final error) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(apiErrorMessage(error), textAlign: TextAlign.center),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ],
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({required this.ride, required this.trailing});

  final Ride ride;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Card.outlined(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatDayShort(ride.scheduledAt!)}, ${formatTime(ride.scheduledAt!)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(ride.pickup.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('→ ${ride.destination.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  '${formatMoney(ride.price)} · ${formatDistance(ride.distanceM)} · ${paymentLabel(ride.paymentMethod)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    ),
  );
}
