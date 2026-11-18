import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../../../data/passenger_repository.dart';
import 'ride_stage.dart';

/// The ride shown on the home screen plus live data from the WebSocket.
class TrackedRide {
  const TrackedRide({required this.ride, this.driverLocation, this.etaSeconds, this.rated = false});

  final Ride ride;
  final LatLng? driverLocation;

  /// Driver's ETA to the pickup (before pickup) — from `ride.driver_location`.
  final int? etaSeconds;
  final bool rated;

  PassengerStage get stage => passengerStage(ride);

  TrackedRide copyWith({Ride? ride, LatLng? driverLocation, int? etaSeconds, bool? rated}) =>
      TrackedRide(
        ride: ride ?? this.ride,
        driverLocation: driverLocation ?? this.driverLocation,
        etaSeconds: etaSeconds ?? this.etaSeconds,
        rated: rated ?? this.rated,
      );
}

/// Ride "now" in progress, or null (→ order screen).
///
/// Start: REST (`GET /rides?active=true`) — so the app returns to the ride after a restart.
/// Live: every active ride (also reservations) is subscribed on the WebSocket; a status change
/// re-reads the ride via REST (REST is the source of truth), a position event updates the map.
/// After every reconnect the state is reloaded from REST.
class ActiveRideController extends AsyncNotifier<TrackedRide?> {
  @override
  Future<TrackedRide?> build() async {
    final repo = ref.watch(passengerRepositoryProvider);
    final socket = ref.watch(podwozkaSocketProvider);

    final events = socket.events.listen(_onEvent);
    var wasConnected = socket.isConnected;
    final states = socket.states.listen((s) {
      final connected = s == WsConnectionState.connected;
      if (connected && !wasConnected) unawaited(_reload());
      wasConnected = connected;
    });
    ref.onDispose(() {
      unawaited(events.cancel());
      unawaited(states.cancel());
    });

    final rides = await repo.activeRides();
    for (final ride in rides) {
      socket.subscribeRide(ride.id);
    }
    final ongoing = rides.where((r) => isOngoing(r)).firstOrNull;
    final keepFinished = state.value;
    if (ongoing == null) {
      // A finished ride waiting for the summary/rating survives reloads.
      return keepFinished != null && keepFinished.stage.isFinished ? keepFinished : null;
    }
    return TrackedRide(ride: ongoing, driverLocation: ongoing.driver?.location?.toLatLng());
  }

  /// After ordering: show the ride immediately and follow it.
  void track(Ride ride) {
    ref.read(podwozkaSocketProvider).subscribeRide(ride.id);
    state = AsyncData(TrackedRide(ride: ride));
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    final ride = await ref.read(passengerRepositoryProvider).ride(current.ride.id);
    _apply(current.copyWith(ride: ride, driverLocation: ride.driver?.location?.toLatLng()));
  }

  Future<void> cancel({String? reason}) async {
    final current = state.value;
    if (current == null) return;
    final ride = await ref
        .read(passengerRepositoryProvider)
        .cancel(current.ride.id, reason: reason);
    _apply(current.copyWith(ride: ride));
  }

  Future<void> rateDriver({required int stars, String? comment}) async {
    final current = state.value;
    if (current == null) return;
    await ref
        .read(passengerRepositoryProvider)
        .rateDriver(current.ride.id, stars: stars, comment: comment);
    state = AsyncData(current.copyWith(rated: true));
  }

  /// Leaves the summary screen → back to ordering.
  void dismiss() {
    final current = state.value;
    if (current != null) ref.read(podwozkaSocketProvider).unsubscribeRide(current.ride.id);
    state = const AsyncData(null);
  }

  void _apply(TrackedRide next) {
    if (next.stage.isFinished) {
      ref.read(podwozkaSocketProvider).unsubscribeRide(next.ride.id);
    }
    state = AsyncData(next);
  }

  Future<void> _reload() async {
    if (state.value?.stage.isFinished ?? false) return;
    ref.invalidateSelf();
  }

  void _onEvent(WsEvent event) {
    final current = state.value;
    switch (event) {
      case DriverLocationChanged(:final rideId, :final lat, :final lng, :final etaSeconds)
          when current != null && current.ride.id == rideId:
        state = AsyncData(
          current.copyWith(driverLocation: LatLng(lat, lng), etaSeconds: etaSeconds),
        );
      case RideStatusChanged(:final rideId) || DriverAssigned(:final rideId)
          when current != null && current.ride.id == rideId:
        unawaited(refresh().catchError((Object _) {}));
      case RideStatusChanged() || DriverAssigned():
        // Another active ride (e.g. a reservation that is now being served).
        unawaited(_reload());
      case NotificationReceived(:final data) when data['ride_id'] != null:
        unawaited(_reload());
      default:
        break;
    }
  }
}

final activeRideProvider = AsyncNotifierProvider<ActiveRideController, TrackedRide?>(
  ActiveRideController.new,
);

/// Reservations (scheduled, also already claimed by a driver) for the order screen.
final reservationsProvider = FutureProvider<List<Ride>>((ref) async {
  // Reload whenever the ongoing ride changes (e.g. after ordering or finishing).
  ref.watch(activeRideProvider.select((s) => s.value?.ride.id));
  final rides = await ref.watch(passengerRepositoryProvider).activeRides();
  return rides.where((r) => passengerStage(r) == PassengerStage.scheduled).toList();
});
