import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// A position fix, independent of the plugin (tests use plain values).
@immutable
class LocationFix {
  const LocationFix({
    required this.lat,
    required this.lng,
    this.heading,
    this.speedMps,
    this.accuracyM,
    DateTime? at,
  }) : _at = at;

  final double lat;
  final double lng;
  final double? heading;
  final double? speedMps;
  final double? accuracyM;
  final DateTime? _at;

  DateTime get at => _at ?? DateTime.now().toUtc();

  /// `driver.location` message for the WebSocket (docs/ws-protocol.md §4).
  Map<String, Object?> toDriverLocationMessage() => {
    'type': 'driver.location',
    'location': {'lat': lat, 'lng': lng},
    if (heading != null && heading! >= 0) 'heading': heading,
    if (speedMps != null && speedMps! >= 0) 'speed_mps': speedMps,
    if (accuracyM != null) 'accuracy_m': accuracyM,
    'at': at.toUtc().toIso8601String(),
  };
}

enum LocationAccess {
  granted,

  /// User said no (can ask again).
  denied,

  /// „Nie pytaj ponownie” — only the system settings can change it.
  deniedForever,

  /// GPS / location services switched off on the phone.
  serviceDisabled,
}

/// Polish explanation for the UI.
String locationAccessMessage(LocationAccess access) => switch (access) {
  LocationAccess.granted => 'Lokalizacja włączona.',
  LocationAccess.denied =>
    'Potrzebujemy dostępu do lokalizacji, żeby pokazać Cię na mapie i znaleźć kierowcę w pobliżu.',
  LocationAccess.deniedForever => 'Dostęp do lokalizacji jest zablokowany. Włącz go w ustawieniach telefonu: Aplikacje → Podwózka → Uprawnienia.',
  LocationAccess.serviceDisabled =>
    'Lokalizacja w telefonie jest wyłączona. Włącz GPS i spróbuj ponownie.',
};

/// Location behind an interface so widgets and logic can be tested with a fake.
abstract interface class LocationService {
  /// Checks and, if needed, asks for permission (while the app is in use).
  Future<LocationAccess> ensureAccess();

  /// One fix, or null if unavailable (no permission, timeout).
  Future<LocationFix?> currentPosition();

  /// Continuous updates. With [driverOnline] on Android a foreground service with a
  /// visible notification keeps updates flowing when the app is in the background —
  /// only use it while the driver is „online”.
  Stream<LocationFix> watch({bool driverOnline = false});

  /// Opens the system settings (after [LocationAccess.deniedForever]).
  Future<void> openSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationAccess> ensureAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceDisabled;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.denied,
    };
  }

  @override
  Future<LocationFix?> currentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return _fix(position);
    } on Object {
      final last = await Geolocator.getLastKnownPosition();
      return last == null ? null : _fix(last);
    }
  }

  @override
  Stream<LocationFix> watch({bool driverOnline = false}) =>
      Geolocator.getPositionStream(locationSettings: _settings(driverOnline)).map(_fix);

  @override
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  LocationSettings _settings(bool driverOnline) {
    const distanceFilter = 10; // metres — fewer updates while parked (ws-protocol §4)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 4),
        foregroundNotificationConfig: driverOnline
            ? const ForegroundNotificationConfig(
                notificationTitle: 'Jesteś online',
                notificationText:
                    'Podwózka udostępnia Twoją lokalizację, żeby przydzielać Ci kursy.',
                notificationChannelName: 'Praca kierowcy',
                enableWakeLock: true,
                setOngoing: true,
              )
            : null,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: driverOnline,
        showBackgroundLocationIndicator: driverOnline,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilter);
  }

  static LocationFix _fix(Position p) => LocationFix(
    lat: p.latitude,
    lng: p.longitude,
    heading: p.heading,
    speedMps: p.speed,
    accuracyM: p.accuracy,
    at: p.timestamp.toUtc(),
  );
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => const GeolocatorLocationService(),
);
