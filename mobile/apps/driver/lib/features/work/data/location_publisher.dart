import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Streams the driver's position to `/ws` while online (docs/ws-protocol.md §4):
/// at most every [minInterval] while moving; the last fix is repeated every [heartbeat]
/// while parked, so the backend's 120 s presence TTL never lapses.
class LocationPublisher {
  LocationPublisher({
    required LocationService location,
    required PodwozkaSocket socket,
    this.minInterval = const Duration(seconds: 3),
    this.heartbeat = const Duration(seconds: 20),
    DateTime Function()? clock,
  }) : _location = location,
       _socket = socket,
       _clock = clock ?? DateTime.now;

  final LocationService _location;
  final PodwozkaSocket _socket;
  final Duration minInterval;
  final Duration heartbeat;
  final DateTime Function() _clock;

  StreamSubscription<LocationFix>? _sub;
  StreamSubscription<WsConnectionState>? _states;
  Timer? _heartbeat;
  LocationFix? _last;
  DateTime? _lastSentAt;
  final _fixes = StreamController<LocationFix>.broadcast();
  final _failures = StreamController<Object>.broadcast();

  bool get isRunning => _sub != null;

  /// Every fix (for the driver's own position on the map).
  Stream<LocationFix> get fixes => _fixes.stream;
  LocationFix? get lastFix => _last;

  /// The position stream failed (GPS off, permission withdrawn) — publishing has stopped.
  Stream<Object> get failures => _failures.stream;

  /// Starts the Android foreground service (notification „Jesteś online”).
  void start() {
    if (_sub != null) return;
    _sub = _location.watch(driverOnline: true).listen(_onFix, onError: _onError);
    _heartbeat = Timer.periodic(heartbeat, (_) => _resend());
    // After a reconnect the server has no fresh position — send the last one at once.
    _states = _socket.states.listen((s) {
      if (s == WsConnectionState.connected) _resend();
    });
  }

  Future<void> stop() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await _states?.cancel();
    _states = null;
    await _sub?.cancel(); // stops the foreground service
    _sub = null;
  }

  Future<void> dispose() async {
    await stop();
    await _fixes.close();
    await _failures.close();
  }

  void _onError(Object error) {
    // Without positions the backend would soon drop the presence anyway; stop the
    // foreground service at once instead of showing „Jesteś online” for nothing.
    unawaited(stop());
    _failures.add(error);
  }

  void _onFix(LocationFix fix) {
    _last = fix;
    _fixes.add(fix);
    final now = _clock();
    final lastSentAt = _lastSentAt;
    if (lastSentAt != null && now.difference(lastSentAt) < minInterval) return;
    _send(fix, now);
  }

  void _resend() {
    final fix = _last;
    if (fix != null) _send(fix, _clock());
  }

  void _send(LocationFix fix, DateTime now) {
    final sent = _socket.send(
      LocationFix(
        lat: fix.lat,
        lng: fix.lng,
        heading: fix.heading,
        speedMps: fix.speedMps,
        accuracyM: fix.accuracyM,
        at: now.toUtc(),
      ).toDriverLocationMessage(),
    );
    if (sent) _lastSentAt = now;
  }
}

final locationPublisherProvider = Provider<LocationPublisher>((ref) {
  final publisher = LocationPublisher(
    location: ref.watch(locationServiceProvider),
    socket: ref.watch(podwozkaSocketProvider),
  );
  ref.onDispose(publisher.dispose);
  return publisher;
});

/// Android 13+: the „Jesteś online” notification of the foreground service is only shown
/// with the notification permission. Behind an interface for tests.
abstract interface class NotificationPermission {
  /// True when granted (or not needed on this platform/version).
  Future<bool> ensure();
}

/// Android: `MainActivity` asks for POST_NOTIFICATIONS (13+). Elsewhere nothing to ask.
class PlatformNotificationPermission implements NotificationPermission {
  const PlatformNotificationPermission();

  static const _channel = MethodChannel('pl.podwozka.driver/permissions');

  @override
  Future<bool> ensure() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      return await _channel.invokeMethod<bool>('requestNotifications') ?? false;
    } on PlatformException {
      return false;
    }
  }
}

final notificationPermissionProvider = Provider<NotificationPermission>(
  (ref) => const PlatformNotificationPermission(),
);
