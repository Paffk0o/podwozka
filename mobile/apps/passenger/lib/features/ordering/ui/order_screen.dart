import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../../../routes.dart';
import '../../ride_tracking/providers/active_ride_controller.dart';
import '../providers/order_controller.dart';
import 'place_search_screen.dart';

/// Home when there is no ride in progress: map + „Skąd / Dokąd / Kiedy” + quote + order.
class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Centre on the user and propose their position as the pickup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(orderControllerProvider).myLocation == null) {
        ref.read(orderControllerProvider.notifier).locateMe();
      }
    });
  }

  Future<void> _search({required bool pickup}) async {
    final controller = ref.read(orderControllerProvider.notifier);
    final place = await Navigator.of(context).push<Place>(
      MaterialPageRoute(
        builder: (_) => PlaceSearchScreen(
          title: pickup ? 'Skąd? Wpisz adres' : 'Dokąd jedziesz?',
          onUseMyLocation: pickup ? controller.locateMe : null,
        ),
      ),
    );
    if (place == null) return;
    pickup ? controller.setPickup(place) : controller.setDestination(place);
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final earliest = now.add(scheduleMinAhead + const Duration(minutes: 5));
    final current = ref.read(orderControllerProvider).scheduledAt ?? earliest;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(scheduleMaxAhead),
      helpText: 'Dzień przejazdu',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Godzina odbioru',
    );
    if (time == null) return;
    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final error = ref.read(orderControllerProvider.notifier).setSchedule(at);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _order() async {
    final ride = await ref.read(orderControllerProvider.notifier).submit();
    if (ride == null || !mounted) return;
    // Ready for the next order: propose my position as the pickup again.
    unawaited(ref.read(orderControllerProvider.notifier).locateMe());
    if (ride.scheduledAt != null) {
      ref.invalidate(reservationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zarezerwowano przejazd na ${formatDateTime(ride.scheduledAt!)}.')),
      );
    } else {
      ref.read(activeRideProvider.notifier).track(ride);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderControllerProvider);
    final quote = order.quote;
    final pickup = order.pickup;
    final destination = order.destination;
    final route = decodePolyline(quote?.routePolyline);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Podwózka'),
        actions: [
          IconButton(
            tooltip: 'Historia przejazdów',
            icon: const Icon(Icons.history),
            onPressed: () => context.push(Routes.history),
          ),
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PodwozkaMap(
                  center: order.myLocation,
                  pins: [
                    if (order.myLocation != null && order.pickupSource != PickupSource.myLocation)
                      MapPin(order.myLocation!, MapPinKind.me),
                    if (pickup != null) MapPin(pickup.toLatLng(), MapPinKind.pickup),
                    if (destination != null) MapPin(destination.toLatLng(), MapPinKind.destination),
                  ],
                  route: route.isNotEmpty
                      ? route
                      : [
                          if (pickup != null && destination != null) ...[
                            pickup.toLatLng(),
                            destination.toLatLng(),
                          ],
                        ],
                  padding: const EdgeInsets.all(48),
                  attributionAlignment: Alignment.topRight,
                  onLongPress: (point) =>
                      ref.read(orderControllerProvider.notifier).setPickupFromPin(point),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'locate',
                    tooltip: 'Moja lokalizacja',
                    onPressed: order.locating
                        ? null
                        : () => ref.read(orderControllerProvider.notifier).locateMe(),
                    child: order.locating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.55),
            child: Material(
              elevation: 8,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        children: [
                          _AddressTile(
                            icon: Icons.trip_origin,
                            label: 'Skąd',
                            value: pickup?.address,
                            placeholder: order.locating
                                ? 'Ustalamy Twoją lokalizację…'
                                : 'Wybierz miejsce odbioru',
                            onTap: () => _search(pickup: true),
                          ),
                          _AddressTile(
                            icon: Icons.place,
                            label: 'Dokąd',
                            value: destination?.address,
                            placeholder: 'Dokąd jedziesz?',
                            onTap: () => _search(pickup: false),
                          ),
                          if (destination == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(
                                'Wskazówka: przytrzymaj palec na mapie, aby ustawić miejsce odbioru.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          if (pickup != null && destination != null) ...[
                            const SizedBox(height: 12),
                            _WhenSelector(
                              scheduledAt: order.scheduledAt,
                              onNow: () =>
                                  ref.read(orderControllerProvider.notifier).setSchedule(null),
                              onLater: _pickSchedule,
                            ),
                            const SizedBox(height: 12),
                            _QuoteSummary(quote: quote, loading: order.quoting),
                            const SizedBox(height: 12),
                            const _PaymentMethods(),
                          ],
                          if (order.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              order.error!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const _Reservations(),
                        ],
                      ),
                    ),
                    // Pinned below the scrolling content — always visible.
                    if (pickup != null && destination != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: FilledButton(
                          onPressed: order.canOrder ? _order : null,
                          child: order.submitting
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  order.isReservation
                                      ? 'Zarezerwuj na ${formatDateTime(order.scheduledAt!)}'
                                      : 'Zamów przejazd',
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(
        icon,
        color: label == 'Dokąd' ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(label, style: theme.textTheme.labelMedium),
      subtitle: Text(
        value ?? placeholder,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: value == null
            ? theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)
            : theme.textTheme.bodyLarge,
      ),
      trailing: const Icon(Icons.search),
      onTap: onTap,
    );
  }
}

class _WhenSelector extends StatelessWidget {
  const _WhenSelector({required this.scheduledAt, required this.onNow, required this.onLater});

  final DateTime? scheduledAt;
  final VoidCallback onNow;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    segments: [
      const ButtonSegment(value: false, icon: Icon(Icons.bolt), label: Text('Teraz')),
      ButtonSegment(
        value: true,
        icon: const Icon(Icons.event),
        label: Text(scheduledAt == null ? 'Na później' : formatDateTime(scheduledAt!)),
      ),
    ],
    selected: {scheduledAt != null},
    showSelectedIcon: false,
    onSelectionChanged: (selection) => selection.first ? onLater() : onNow(),
  );
}

class _QuoteSummary extends StatelessWidget {
  const _QuoteSummary({required this.quote, required this.loading});

  final Quote? quote;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Liczymy cenę…'),
          ],
        ),
      );
    }
    final q = quote;
    if (q == null) return const SizedBox.shrink();
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatMoney(q.price), style: theme.textTheme.headlineSmall),
                  Text(
                    '${formatDuration(q.durationS)} · ${formatDistance(q.distanceM)} · ${q.regionName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text('Cena stała', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods();

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      ChoiceChip(
        avatar: const Icon(Icons.payments_outlined),
        label: const Text('Gotówka'),
        selected: true,
        onSelected: (_) {},
      ),
      // Online payments arrive in stage 3 (Stripe) — visible, but not selectable yet.
      const ChoiceChip(
        avatar: Icon(Icons.credit_card),
        label: Text('Karta — wkrótce'),
        selected: false,
        onSelected: null,
      ),
      const ChoiceChip(
        avatar: Icon(Icons.phone_iphone),
        label: Text('BLIK — wkrótce'),
        selected: false,
        onSelected: null,
      ),
    ],
  );
}

class _Reservations extends ConsumerWidget {
  const _Reservations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationsProvider).value ?? const <Ride>[];
    if (reservations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Twoje rezerwacje', style: Theme.of(context).textTheme.titleMedium),
        for (final ride in reservations)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(ride.driver == null ? Icons.schedule : Icons.event_available),
            title: Text(formatDateTime(ride.scheduledAt ?? ride.requestedAt)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ride.destination.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  ride.driver == null
                      ? 'Czekamy na kierowcę'
                      : 'Kierowca: ${ride.driver!.fullName}',
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () => context.push(Routes.rideDetails(ride.id)),
          ),
      ],
    );
  }
}
