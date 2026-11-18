import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../../data/passenger_repository.dart';
import '../../routes.dart';
import '../ride_tracking/providers/active_ride_controller.dart';
import '../ride_tracking/providers/ride_stage.dart';
import '../ride_tracking/ui/ride_widgets.dart';

class HistoryState {
  const HistoryState({this.items = const [], this.total, this.loadingMore = false});

  final List<Ride> items;
  final int? total;
  final bool loadingMore;

  bool get hasMore => total == null || items.length < total!;
}

/// Finished rides, newest first, loaded page by page.
class HistoryController extends AsyncNotifier<HistoryState> {
  static const pageSize = 20;

  @override
  Future<HistoryState> build() async {
    final page = await ref.watch(passengerRepositoryProvider).history(limit: pageSize);
    return HistoryState(items: page.items, total: page.total);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(HistoryState(items: current.items, total: current.total, loadingMore: true));
    try {
      final page = await ref
          .read(passengerRepositoryProvider)
          .history(offset: current.items.length, limit: pageSize);
      state = AsyncData(HistoryState(items: [...current.items, ...page.items], total: page.total));
    } on Object {
      state = AsyncData(current);
    }
  }
}

final historyProvider = AsyncNotifierProvider.autoDispose<HistoryController, HistoryState>(
  HistoryController.new,
);

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historia przejazdów')),
      body: switch (history) {
        AsyncData(:final value) when value.items.isEmpty => const Center(
          child: Text('Nie masz jeszcze zakończonych przejazdów.'),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(historyProvider.future),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300) ref.read(historyProvider.notifier).loadMore();
              return false;
            },
            child: ListView.separated(
              itemCount: value.items.length + (value.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= value.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final ride = value.items[index];
                return ListTile(
                  title: Text(
                    ride.destination.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${formatDateTime(ride.scheduledAt ?? ride.requestedAt)} · ${rideStatusLabel(ride.status)}',
                  ),
                  trailing: Text(formatMoney(ride.price)),
                  onTap: () => context.push(Routes.rideDetails(ride.id)),
                );
              },
            ),
          ),
        ),
        AsyncError(:final error) => _Retry(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(historyProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

final rideDetailsProvider = FutureProvider.autoDispose.family<Ride, String>(
  (ref, rideId) => ref.watch(passengerRepositoryProvider).ride(rideId),
);

/// One ride from the history or a reservation (which can be cancelled here).
class RideDetailsScreen extends ConsumerWidget {
  const RideDetailsScreen({required this.rideId, super.key});

  final String rideId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reason = await confirmCancel(context);
    if (reason == null) return;
    try {
      await ref.read(passengerRepositoryProvider).cancel(rideId, reason: reason);
      ref
        ..invalidate(rideDetailsProvider(rideId))
        ..invalidate(reservationsProvider);
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(rideDetailsProvider(rideId));
    return Scaffold(
      appBar: AppBar(title: const Text('Przejazd')),
      body: switch (ride) {
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PodwozkaMap(
                  pins: [
                    MapPin(value.pickup.toLatLng(), MapPinKind.pickup),
                    MapPin(value.destination.toLatLng(), MapPinKind.destination),
                  ],
                  route: decodePolyline(value.routePolyline).isNotEmpty
                      ? decodePolyline(value.routePolyline)
                      : [value.pickup.toLatLng(), value.destination.toLatLng()],
                  padding: const EdgeInsets.all(32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(rideStatusLabel(value.status), style: Theme.of(context).textTheme.titleLarge),
            Text(
              value.scheduledAt != null
                  ? 'Odbiór: ${formatDateTime(value.scheduledAt!)}'
                  : 'Zamówiony: ${formatDateTime(value.requestedAt)}',
            ),
            const SizedBox(height: 12),
            RideRouteSummary(ride: value),
            if (value.driver != null) ...[
              const SizedBox(height: 8),
              DriverCard(driver: value.driver!),
            ],
            if (value.cancelReason != null) ...[
              const SizedBox(height: 8),
              Text('Powód anulowania: ${value.cancelReason}'),
            ],
            if (stageOf(value.status).canCancel) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _cancel(context, ref),
                icon: const Icon(Icons.close),
                label: Text(value.scheduledAt != null ? 'Anuluj rezerwację' : 'Anuluj przejazd'),
              ),
            ],
          ],
        ),
        AsyncError(:final error) => _Retry(
          message: apiErrorMessage(error),
          onRetry: () => ref.invalidate(rideDetailsProvider(rideId)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Spróbuj ponownie')),
        ],
      ),
    ),
  );
}
