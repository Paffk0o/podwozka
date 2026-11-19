import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../data/location_publisher.dart';
import '../data/work_repository.dart';
import 'ride_flow.dart';

/// Thrown when going online is not possible (permission, GPS) — message is Polish.
class GoOnlineException implements Exception {
  const GoOnlineException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WorkState {
  const WorkState({
    required this.current,
    this.finishedRide,
    this.busy = false,
    this.locationProblem,
  });

  final DriverCurrentState current;

  /// A completed/cancelled ride kept on screen for cash confirmation and the rating,
  /// after the API no longer reports it as active.
  final Ride? finishedRide;
  final bool busy;

  /// Why the app went offline by itself (GPS switched off…), Polish; cleared on going online.
  final String? locationProblem;

  bool get online => current.profile.online;
  RideOffer? get offer => current.pendingOffer;

  /// The ride the panel is about (active one, or the one being wrapped up).
  Ride? get ride => current.activeRide ?? finishedRide;

  WorkState copyWith({
    DriverCurrentState? current,
    Ride? Function()? finishedRide,
    bool? busy,
    String? Function()? locationProblem,
  }) => WorkState(
    current: current ?? this.current,
    finishedRide: finishedRide != null ? finishedRide() : this.finishedRide,
    busy: busy ?? this.busy,
    locationProblem: locationProblem != null ? locationProblem() : this.locationProblem,
  );
}

/// Driver's work loop. Start: REST (`GET /drivers/me/current`) — after a restart the app
/// is back online / in the active ride. Live: offers and ride changes from the WebSocket,
/// each followed by a REST read. After every reconnect the state is reloaded.
class WorkController extends AsyncNotifier<WorkState> {
  WorkRepository get _repo => ref.read(workRepositoryProvider);
  PodwozkaSocket get _socket => ref.read(podwozkaSocketProvider);
  String? _subscribedRide;

  @override
  Future<WorkState> build() async {
    final repo = ref.watch(workRepositoryProvider);
    final socket = ref.watch(podwozkaSocketProvider);
    final events = socket.events.listen(_onEvent);
    var wasConnected = socket.isConnected;
    final states = socket.states.listen((s) {
      final connected = s == WsConnectionState.connected;
      if (connected && !wasConnected) unawaited(refresh().catchError((Object _) {}));
      wasConnected = connected;
    });
    final failures = ref
        .watch(locationPublisherProvider)
        .failures
        .listen((e) => unawaited(_onLocationFailure(e).catchError((Object _) {})));
    ref.onDispose(() {
      unawaited(events.cancel());
      unawaited(states.cancel());
      unawaited(failures.cancel());
    });

    final current = await repo.current();
    _follow(current.activeRide);
    if (current.profile.online) {
      // Back online after a restart: resume streaming the position (permission is kept).
      ref.read(locationPublisherProvider).start();
    }
    return WorkState(
      current: current,
      finishedRide: state.value?.finishedRide,
      locationProblem: state.value?.locationProblem,
    );
  }

  WorkState get _state => state.requireValue;

  Future<void> refresh() async {
    final current = await _repo.current();
    final previous = state.value;
    var finished = previous?.finishedRide;
    final active = previous?.current.activeRide;
    if (active != null && current.activeRide == null && finished == null) {
      // Ended outside this app's own actions — after acceptance only the passenger can do
      // that (backend state machine), so show it as cancelled by the passenger.
      finished = active.copyWith(status: RideStatus.cancelledByPassenger);
    }
    _follow(current.activeRide);
    state = AsyncData(
      WorkState(
        current: current,
        finishedRide: finished,
        locationProblem: previous?.locationProblem,
      ),
    );
  }

  /// Location permission + notification permission + `PUT availability` + position stream.
  Future<void> goOnline() async {
    final access = await ref.read(locationServiceProvider).ensureAccess();
    if (access != LocationAccess.granted) throw GoOnlineException(locationAccessMessage(access));
    // Without it the service still works, only the notification is hidden — not blocking.
    await ref.read(notificationPermissionProvider).ensure();
    state = AsyncData(_state.copyWith(locationProblem: () => null));
    await _busy(() async {
      await _repo.setOnline(true);
      ref.read(locationPublisherProvider).start();
      await refresh();
    });
  }

  /// The position stream died while online: no longer pretend to be available for offers.
  /// During a ride the driver stays online (the ride goes on; the passenger just loses the
  /// live position) — the message tells them to turn the GPS back on.
  Future<void> _onLocationFailure(Object error) async {
    final message = error is LocationUnavailableException
        ? error.message
        : 'Nie udało się odczytać lokalizacji telefonu.';
    state = AsyncData(_state.copyWith(locationProblem: () => message));
    if (_state.current.activeRide == null && _state.online) {
      await _repo.setOnline(false);
    }
    await refresh();
  }

  Future<void> goOffline() => _busy(() async {
    await ref.read(locationPublisherProvider).stop();
    await _repo.setOnline(false);
    await refresh();
  });

  Future<void> acceptOffer() => _busy(() async {
    final offer = _state.offer;
    if (offer == null) return;
    await _repo.acceptOffer(offer.id);
    await refresh();
  });

  Future<void> declineOffer() => _busy(() async {
    final offer = _state.offer;
    if (offer == null) return;
    await _repo.declineOffer(offer.id);
    await refresh();
  });

  /// The big button: depart → arrived → start → complete.
  Future<void> advance() => _busy(() async {
    final ride = _state.current.activeRide;
    if (ride == null) return;
    final step = nextAction(ride);
    if (step == null) return;
    final updated = await _repo.action(ride.id, step.action);
    if (updated.status == RideStatus.completed) {
      state = AsyncData(_state.copyWith(finishedRide: () => updated));
    }
    await refresh();
  });

  Future<void> confirmCash() => _busy(() async {
    final ride = _state.ride;
    if (ride == null) return;
    final paid = await _repo.cashCollected(ride.id);
    state = AsyncData(_state.copyWith(finishedRide: () => paid));
  });

  Future<void> cancelRide(String reason) => _busy(() async {
    final ride = _state.current.activeRide;
    if (ride == null) return;
    final cancelled = await _repo.cancel(ride.id, reason: reason);
    state = AsyncData(_state.copyWith(finishedRide: () => cancelled));
    await refresh();
  });

  Future<void> ratePassenger({required int stars, String? comment}) => _busy(() async {
    final ride = _state.ride;
    if (ride == null) return;
    await _repo.ratePassenger(ride.id, stars: stars, comment: comment);
    dismissFinished();
  });

  /// Back to waiting for offers.
  void dismissFinished() {
    state = AsyncData(_state.copyWith(finishedRide: () => null));
  }

  /// Subscribe the active ride: the backend refreshes the ETA target on status events and
  /// passenger-side changes (cancellation) arrive on the ride channel.
  void _follow(Ride? ride) {
    final id = ride?.id;
    if (id == _subscribedRide) return;
    final previous = _subscribedRide;
    if (previous != null) _socket.unsubscribeRide(previous);
    if (id != null) _socket.subscribeRide(id);
    _subscribedRide = id;
  }

  Future<void> _busy(Future<void> Function() action) async {
    state = AsyncData(_state.copyWith(busy: true));
    try {
      await action();
    } finally {
      final current = state.value;
      if (current != null) state = AsyncData(current.copyWith(busy: false));
    }
  }

  void _onEvent(WsEvent event) {
    switch (event) {
      case OfferReceived() || OfferExpired() || DriverAssigned() || RideStatusChanged():
        unawaited(refresh().catchError((Object _) {}));
      default:
        break;
    }
  }
}

final workProvider = AsyncNotifierProvider<WorkController, WorkState>(WorkController.new);

/// The driver's own position for the map.
final myFixProvider = StreamProvider<LocationFix>((ref) {
  final publisher = ref.watch(locationPublisherProvider);
  final last = publisher.lastFix;
  return last == null ? publisher.fixes : Stream.value(last).followedBy(publisher.fixes);
});

extension<T> on Stream<T> {
  Stream<T> followedBy(Stream<T> next) async* {
    yield* this;
    yield* next;
  }
}
