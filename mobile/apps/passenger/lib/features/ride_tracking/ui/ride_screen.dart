import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../providers/active_ride_controller.dart';
import '../providers/ride_stage.dart';
import 'ride_widgets.dart';

/// Ride in progress: waiting for a driver → tracking with ETA → summary and rating.
class RideScreen extends ConsumerWidget {
  const RideScreen({required this.tracked, super.key});

  final TrackedRide tracked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = tracked.ride;
    final stage = tracked.stage;
    final pickup = ride.pickup.toLatLng();
    final destination = ride.destination.toLatLng();
    final route = decodePolyline(ride.routePolyline);
    final driverLocation = stage.showsDriver ? tracked.driverLocation : null;
    final connection = ref.watch(wsConnectionStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(stage.title),
        automaticallyImplyLeading: false,
        bottom: connection == WsConnectionState.waitingToReconnect
            ? const PreferredSize(
                preferredSize: Size.fromHeight(24),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('Łączenie z serwerem…'),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: PodwozkaMap(
              pins: [
                if (stage != PassengerStage.inProgress) MapPin(pickup, MapPinKind.pickup),
                MapPin(destination, MapPinKind.destination),
                if (driverLocation != null) MapPin(driverLocation, MapPinKind.driver),
              ],
              route: route.isNotEmpty ? route : [pickup, destination],
              padding: const EdgeInsets.all(56),
              attributionAlignment: Alignment.topRight,
            ),
          ),
          Material(
            elevation: 8,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: stage.isFinished
                    ? _Finished(tracked: tracked)
                    : _InProgress(tracked: tracked),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InProgress extends ConsumerStatefulWidget {
  const _InProgress({required this.tracked});

  final TrackedRide tracked;

  @override
  ConsumerState<_InProgress> createState() => _InProgressState();
}

class _InProgressState extends ConsumerState<_InProgress> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final reason = await confirmCancel(context);
    if (reason == null || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await ref.read(activeRideProvider.notifier).cancel(reason: reason);
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracked = widget.tracked;
    final ride = tracked.ride;
    final stage = tracked.stage;
    final driver = ride.driver;
    final eta = tracked.etaSeconds;
    final etaText = switch (stage) {
      PassengerStage.driverAssigned || PassengerStage.driverArriving when eta != null =>
        'Kierowca będzie za ok. ${formatDuration(eta)}',
      PassengerStage.inProgress when eta != null => 'Do celu ok. ${formatDuration(eta)}',
      PassengerStage.driverArrived => 'Wyjdź do kierowcy — czeka w miejscu odbioru.',
      PassengerStage.searching => 'Wysłaliśmy zlecenie do najbliższych kierowców.',
      _ => null,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stage == PassengerStage.searching) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        if (etaText != null) Text(etaText, style: theme.textTheme.titleMedium),
        if (driver != null) DriverCard(driver: driver),
        const SizedBox(height: 4),
        RideRouteSummary(ride: ride),
        if (ride.paymentMethod == PaymentMethod.cash)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Zapłać kierowcy gotówką po dojechaniu na miejsce.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (stage.canCancel) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _cancelling ? null : _cancel,
            icon: const Icon(Icons.close),
            label: const Text('Anuluj przejazd'),
          ),
        ],
      ],
    );
  }
}

class _Finished extends ConsumerStatefulWidget {
  const _Finished({required this.tracked});

  final TrackedRide tracked;

  @override
  ConsumerState<_Finished> createState() => _FinishedState();
}

class _FinishedState extends ConsumerState<_Finished> {
  int _stars = 0;
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _rate() async {
    setState(() => _sending = true);
    try {
      await ref
          .read(activeRideProvider.notifier)
          .rateDriver(
            stars: _stars,
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracked = widget.tracked;
    final ride = tracked.ride;
    final stage = tracked.stage;
    final done = FilledButton(
      onPressed: () => ref.read(activeRideProvider.notifier).dismiss(),
      child: Text(stage == PassengerStage.completed ? 'Gotowe' : 'Zamów ponownie'),
    );

    if (stage != PassengerStage.completed) {
      final message = switch (stage) {
        PassengerStage.noDriver => 'Nikt z kierowców nie mógł teraz przyjąć kursu. Spróbuj za chwilę albo zarezerwuj przejazd na później.',
        PassengerStage.cancelledByDriver =>
          'Przepraszamy — kierowca musiał anulować przejazd. Zamów ponownie, znajdziemy innego.',
        _ => 'Przejazd został anulowany.',
      };
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          done,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Do zapłaty: ${formatMoney(ride.price)}', style: theme.textTheme.headlineSmall),
        Text(
          '${formatDistance(ride.distanceM)} · ${formatDuration(ride.durationS)} · '
          '${paymentLabel(ride.paymentMethod)}',
        ),
        const SizedBox(height: 12),
        if (tracked.rated)
          const Text('Dziękujemy za ocenę!', textAlign: TextAlign.center)
        else ...[
          Text(
            ride.driver == null
                ? 'Jak oceniasz przejazd?'
                : 'Jak oceniasz kierowcę ${ride.driver!.fullName}?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          StarRating(value: _stars, onChanged: (v) => setState(() => _stars = v)),
          if (_stars > 0) ...[
            TextField(
              controller: _comment,
              decoration: const InputDecoration(labelText: 'Komentarz (opcjonalnie)'),
              maxLength: 500,
              maxLines: 2,
            ),
            FilledButton.tonal(
              onPressed: _sending ? null : _rate,
              child: const Text('Wyślij ocenę'),
            ),
          ],
        ],
        const SizedBox(height: 8),
        done,
      ],
    );
  }
}
