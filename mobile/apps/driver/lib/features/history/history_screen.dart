import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../board/board_repository.dart';

class DriverHistory {
  const DriverHistory({this.items = const [], this.total, this.loadingMore = false});

  final List<Ride> items;
  final int? total;
  final bool loadingMore;

  bool get hasMore => total == null || items.length < total!;
}

/// Finished rides, newest first, page by page.
class DriverHistoryController extends AsyncNotifier<DriverHistory> {
  static const pageSize = 20;

  @override
  Future<DriverHistory> build() async {
    final page = await ref
        .watch(driverRecordsRepositoryProvider)
        .rides(active: false, limit: pageSize);
    return DriverHistory(items: page.items, total: page.total);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(DriverHistory(items: current.items, total: current.total, loadingMore: true));
    try {
      final page = await ref
          .read(driverRecordsRepositoryProvider)
          .rides(active: false, offset: current.items.length, limit: pageSize);
      state = AsyncData(DriverHistory(items: [...current.items, ...page.items], total: page.total));
    } on Object {
      state = AsyncData(current);
    }
  }
}

final driverHistoryProvider =
    AsyncNotifierProvider.autoDispose<DriverHistoryController, DriverHistory>(
      DriverHistoryController.new,
    );

String driverRideStatusLabel(RideStatus status) => switch (status) {
  RideStatus.completed => 'Zakończony',
  RideStatus.cancelledByPassenger => 'Anulowany przez pasażera',
  RideStatus.cancelledByDriver => 'Anulowany przez Ciebie',
  RideStatus.noDriver => 'Bez kierowcy',
  _ => 'W toku',
};

class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(driverHistoryProvider);
    return switch (history) {
      AsyncData(:final value) when value.items.isEmpty => const Center(
        child: Text('Nie masz jeszcze kursów.'),
      ),
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: () => ref.refresh(driverHistoryProvider.future),
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (n) {
            if (n.metrics.extentAfter < 300) ref.read(driverHistoryProvider.notifier).loadMore();
            return false;
          },
          child: ListView.separated(
            itemCount: value.items.length + (value.loadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i >= value.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final ride = value.items[i];
              return ListTile(
                title: Text(
                  '${ride.pickup.address} → ${ride.destination.address}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${formatDateTime(ride.completedAt ?? ride.scheduledAt ?? ride.requestedAt)} · '
                  '${driverRideStatusLabel(ride.status)}',
                ),
                trailing: Text(formatMoney(ride.price)),
              );
            },
          ),
        ),
      ),
      AsyncError(:final error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(apiErrorMessage(error)),
            TextButton(
              onPressed: () => ref.invalidate(driverHistoryProvider),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
