import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/ride_flow.dart';
import '../providers/work_controller.dart';

/// Map + online switch + the panel for the current situation (offer / ride / idle).
class WorkPanelScreen extends ConsumerWidget {
  const WorkPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final work = ref.watch(workProvider);
    return switch (work) {
      AsyncData(:final value) => _Work(state: value),
      AsyncError(:final error) when !work.isLoading => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(apiErrorMessage(error), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(workProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
      _ when work.value != null => _Work(state: work.value!),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Runs a controller action and shows API errors as a Polish snackbar.
Future<void> runAction(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } on GoOnlineException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on Object catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
  }
}

class _Work extends ConsumerWidget {
  const _Work({required this.state});

  final WorkState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(myFixProvider).value;
    final ride = state.ride;
    final offer = state.offer;
    final shown = offer?.ride ?? ride;
    final stage = ride == null ? null : driverStage(ride);
    final pins = <MapPin>[
      if (me != null) MapPin(me.toLatLng(), MapPinKind.driver),
      if (shown != null && stage != DriverStage.inProgress)
        MapPin(shown.pickup.toLatLng(), MapPinKind.pickup),
      if (shown != null) MapPin(shown.destination.toLatLng(), MapPinKind.destination),
    ];
    final route = shown == null ? const <LatLng>[] : decodePolyline(shown.routePolyline);
    return Column(
      children: [
        Expanded(
          child: PodwozkaMap(
            center: me?.toLatLng(),
            pins: pins,
            route: shown == null
                ? const []
                : route.isNotEmpty
                ? route
                : [shown.pickup.toLatLng(), shown.destination.toLatLng()],
            padding: const EdgeInsets.all(56),
            attributionAlignment: Alignment.topRight,
          ),
        ),
        Material(
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: switch (state) {
                  WorkState(offer: final o?) => OfferCard(offer: o, busy: state.busy),
                  WorkState(ride: final r?) => RidePanel(ride: r, busy: state.busy),
                  _ => _IdlePanel(state: state),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdlePanel extends ConsumerWidget {
  const _IdlePanel({required this.state});

  final WorkState state;

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool online) async {
    final controller = ref.read(workProvider.notifier);
    if (!online) return runAction(context, controller.goOffline);
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Przejść w tryb online?'),
        content: const Text(
          'Gdy jesteś online, Podwózka korzysta z Twojej lokalizacji — także wtedy, gdy aplikacja '
          'działa w tle — żeby przydzielać Ci najbliższe kursy i pokazywać pasażerowi, gdzie jesteś. '
          'Przez cały ten czas zobaczysz powiadomienie „Jesteś online”. Po przejściu w tryb offline '
          'lokalizacja przestaje być wysyłana.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nie teraz'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rozumiem, włącz'),
          ),
        ],
      ),
    );
    if (agreed == true && context.mounted) await runAction(context, controller.goOnline);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final next = state.current.nextScheduledRide;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            state.online ? 'Jesteś online' : 'Jesteś offline',
            style: theme.textTheme.titleLarge,
          ),
          subtitle: Text(
            state.online
                ? 'Czekasz na zlecenia w swojej gminie…'
                : 'Włącz, aby otrzymywać zlecenia.',
          ),
          value: state.online,
          onChanged: state.busy ? null : (value) => _toggle(context, ref, value),
        ),
        if (state.online) const LinearProgressIndicator(),
        if (state.locationProblem case final problem?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_off, color: theme.colorScheme.error),
            title: Text(problem),
          ),
        if (next != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(
              'Najbliższa rezerwacja: ${formatDateTime(next.scheduledAt ?? next.requestedAt)}',
            ),
            subtitle: Text(
              '${next.pickup.address} → ${next.destination.address}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// New offer with a 20 s countdown (the server decides when it expires).
class OfferCard extends ConsumerStatefulWidget {
  const OfferCard({required this.offer, required this.busy, super.key});

  final RideOffer offer;
  final bool busy;

  @override
  ConsumerState<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends ConsumerState<OfferCard> {
  static const _offerSeconds = 20;
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offer = widget.offer;
    final ride = offer.ride;
    final left = offerSecondsLeft(offer.expiresAt).clamp(0, _offerSeconds);
    final controller = ref.read(workProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox.square(
              dimension: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(value: left / _offerSeconds, strokeWidth: 5),
                  Text('$left', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nowe zlecenie', style: theme.textTheme.titleLarge),
                  Text(
                    'Odbiór za ok. ${formatDuration(offer.pickupEtaS)} · ${formatDistance(offer.pickupDistanceM)} od Ciebie',
                  ),
                ],
              ),
            ),
            Text(formatMoney(ride.price), style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 12),
        _Addresses(ride: ride),
        Text(
          '${formatDistance(ride.distanceM)} · ${formatDuration(ride.durationS)} · ${paymentLabel(ride.paymentMethod)}',
          style: theme.textTheme.bodySmall,
        ),
        if (ride.passengerNote != null) Text('Uwagi: ${ride.passengerNote}'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.busy ? null : () => runAction(context, controller.declineOffer),
                child: const Text('Odrzuć'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: widget.busy ? null : () => runAction(context, controller.acceptOffer),
                child: const Text('Przyjmij'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Active ride: passenger, „Nawiguj”, the next step, cancellation; then cash and rating.
class RidePanel extends ConsumerWidget {
  const RidePanel({required this.ride, required this.busy, super.key});

  final Ride ride;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stage = driverStage(ride);
    final controller = ref.read(workProvider.notifier);
    final passenger = ride.passenger;
    final step = nextAction(ride);

    if (stage == DriverStage.collectCash) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(driverStageTitle(stage), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Pobierz od pasażera gotówką:', style: theme.textTheme.bodyLarge),
          Text(formatMoney(ride.price), style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : () => runAction(context, controller.confirmCash),
            icon: const Icon(Icons.payments),
            label: const Text('Potwierdzam odbiór gotówki'),
          ),
        ],
      );
    }
    if (stage == DriverStage.ratePassenger) return _RatePassenger(ride: ride, busy: busy);
    if (stage == DriverStage.cancelled) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ride.status == RideStatus.cancelledByPassenger
                ? 'Pasażer anulował kurs'
                : driverStageTitle(stage),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: controller.dismissFinished, child: const Text('Wróć do zleceń')),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(driverStageTitle(stage), style: theme.textTheme.titleLarge)),
            Text(formatMoney(ride.price), style: theme.textTheme.titleMedium),
          ],
        ),
        if (passenger != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(passenger.fullName),
            subtitle: Text(
              passenger.ratingAvg == null
                  ? 'Nowy pasażer'
                  : '★ ${passenger.ratingAvg!.toStringAsFixed(1).replaceAll('.', ',')}',
            ),
            trailing: passenger.phone == null
                ? null
                : IconButton(
                    tooltip: 'Zadzwoń do pasażera',
                    icon: const Icon(Icons.phone),
                    onPressed: () => launchUrl(Uri(scheme: 'tel', path: passenger.phone)),
                  ),
          ),
        _Addresses(ride: ride, highlightDestination: stage == DriverStage.inProgress),
        if (ride.passengerNote != null) Text('Uwagi: ${ride.passengerNote}'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: NavigateButton(target: navigationTarget(ride).toLatLng())),
            if (driverCanCancel(ride)) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Anuluj kurs',
                icon: const Icon(Icons.cancel_outlined),
                onPressed: busy ? null : () => _cancel(context, ref),
              ),
            ],
          ],
        ),
        if (step != null) ...[
          const SizedBox(height: 8),
          FilledButton(
            onPressed: busy ? null : () => runAction(context, controller.advance),
            child: Text(step.label),
          ),
        ],
      ],
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    const reasons = ['Awaria auta', 'Nie mogę dojechać', 'Pasażer nie przyszedł', 'Inny powód'];
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Anulować kurs?'),
        children: [
          for (final r in reasons)
            SimpleDialogOption(onPressed: () => Navigator.pop(context, r), child: Text(r)),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nie anuluj',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
    if (reason != null && context.mounted) {
      await runAction(context, () => ref.read(workProvider.notifier).cancelRide(reason));
    }
  }
}

/// Opens Google Maps or Waze with the route to [target].
class NavigateButton extends StatelessWidget {
  const NavigateButton({required this.target, super.key});

  final LatLng target;

  Future<void> _open(BuildContext context, NavigationApp app) async {
    for (final uri in navigationUris(target, app)) {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nie udało się otworzyć nawigacji.')));
    }
  }

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: [
      MenuItemButton(
        onPressed: () => _open(context, NavigationApp.googleMaps),
        child: const Text('Google Maps'),
      ),
      MenuItemButton(
        onPressed: () => _open(context, NavigationApp.waze),
        child: const Text('Waze'),
      ),
    ],
    builder: (context, controller, _) => OutlinedButton.icon(
      onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      icon: const Icon(Icons.navigation),
      label: const Text('Nawiguj'),
    ),
  );
}

class _RatePassenger extends ConsumerStatefulWidget {
  const _RatePassenger({required this.ride, required this.busy});

  final Ride ride;
  final bool busy;

  @override
  ConsumerState<_RatePassenger> createState() => _RatePassengerState();
}

class _RatePassengerState extends ConsumerState<_RatePassenger> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.read(workProvider.notifier);
    final name = widget.ride.passenger?.fullName;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kurs zakończony · ${formatMoney(widget.ride.price)}',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(name == null ? 'Oceń pasażera' : 'Oceń pasażera: $name', textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                tooltip: '$star/5',
                iconSize: 40,
                color: Colors.amber.shade700,
                icon: Icon(star <= _stars ? Icons.star_rounded : Icons.star_outline_rounded),
                onPressed: () => setState(() => _stars = star),
              ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(onPressed: controller.dismissFinished, child: const Text('Pomiń')),
            ),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _stars == 0 || widget.busy
                    ? null
                    : () => runAction(context, () => controller.ratePassenger(stars: _stars)),
                child: const Text('Wyślij ocenę'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Addresses extends StatelessWidget {
  const _Addresses({required this.ride, this.highlightDestination = false});

  final Ride ride;
  final bool highlightDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget line(IconData icon, Color color, String text, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        line(
          Icons.trip_origin,
          theme.colorScheme.primary,
          ride.pickup.address,
          bold: !highlightDestination,
        ),
        line(
          Icons.place,
          theme.colorScheme.error,
          ride.destination.address,
          bold: highlightDestination,
        ),
      ],
    );
  }
}

String paymentLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'gotówka',
  PaymentMethod.card => 'karta',
  PaymentMethod.blik => 'BLIK',
};
