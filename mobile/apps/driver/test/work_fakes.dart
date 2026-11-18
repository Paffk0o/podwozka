import 'dart:async';
import 'dart:convert';

import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_driver/features/work/data/location_publisher.dart';
import 'package:podwozka_driver/features/work/data/work_repository.dart';

final pickup = Place(
  location: GeoPoint(lat: 49.9837, lng: 20.0553),
  address: 'Rynek Górny 1, Wieliczka',
);
final destination = Place(
  location: GeoPoint(lat: 50.0617, lng: 19.9373),
  address: 'Rynek Główny, Kraków',
);
final anna = RidePassengerInfo(
  id: 'p1',
  fullName: 'Anna Pasażerka',
  phone: '+48600100200',
  ratingAvg: 5,
);

Ride aRide({
  String id = 'r1',
  RideStatus status = RideStatus.accepted,
  PaymentStatus payment = PaymentStatus.cashDue,
}) => Ride(
  id: id,
  status: status,
  regionId: 'reg',
  pickup: pickup,
  destination: destination,
  scheduledAt: null,
  requestedAt: DateTime.utc(2026, 11, 18, 10),
  acceptedAt: null,
  startedAt: null,
  completedAt: null,
  cancelledAt: null,
  cancelReason: null,
  price: 8035,
  paymentMethod: PaymentMethod.cash,
  paymentStatus: payment,
  distanceM: 15700,
  durationS: 1440,
  routePolyline: null,
  passengerNote: 'Czekam przy fontannie',
  driver: null,
  passenger: anna,
);

DriverProfile profile({bool online = false}) => DriverProfile(
  userId: 'd1',
  status: DriverStatus.approved,
  regionId: 'reg',
  vehicle: Vehicle(make: 'Opel', model: 'Astra', color: 'czerwony', plate: 'KWI7A8B9'),
  documents: const [],
  rejectionReason: null,
  ratingAvg: 4.8,
  online: online,
  approvedAt: DateTime.utc(2026, 11, 18),
);

RideOffer anOffer({DateTime? expiresAt}) => RideOffer(
  id: 'o1',
  ride: aRide(status: RideStatus.dispatching),
  pickupDistanceM: 979,
  pickupEtaS: 105,
  expiresAt: expiresAt ?? DateTime.now().toUtc().add(const Duration(seconds: 20)),
);

/// In-memory backend for the driver's work loop; follows the backend state machine.
class FakeWorkRepository implements WorkRepository {
  bool online = false;
  RideOffer? offer;
  Ride? active;
  final calls = <String>[];

  @override
  Future<DriverCurrentState> current() async => DriverCurrentState(
    profile: profile(online: online),
    pendingOffer: offer,
    activeRide: active,
    nextScheduledRide: null,
  );

  @override
  Future<DriverProfile> setOnline(bool value) async {
    calls.add('online:$value');
    online = value;
    return profile(online: value);
  }

  @override
  Future<Ride> acceptOffer(String offerId) async {
    calls.add('accept:$offerId');
    offer = null;
    return active = aRide();
  }

  @override
  Future<void> declineOffer(String offerId) async {
    calls.add('decline:$offerId');
    offer = null;
  }

  @override
  Future<Ride> action(String rideId, DriverRideAction action) async {
    calls.add('action:${action.value}');
    final next = switch (action) {
      DriverRideAction.depart => RideStatus.driverArriving,
      DriverRideAction.arrived => RideStatus.arrived,
      DriverRideAction.start => RideStatus.inProgress,
      DriverRideAction.complete => RideStatus.completed,
    };
    final ride = aRide(status: next);
    // A completed ride is no longer "current" in the API.
    active = next == RideStatus.completed ? null : ride;
    return ride;
  }

  @override
  Future<Ride> cashCollected(String rideId) async {
    calls.add('cash');
    return aRide(status: RideStatus.completed, payment: PaymentStatus.cashCollected);
  }

  @override
  Future<Ride> cancel(String rideId, {required String reason}) async {
    calls.add('cancel:$reason');
    active = null;
    return aRide(status: RideStatus.cancelledByDriver);
  }

  @override
  Future<void> ratePassenger(String rideId, {required int stars, String? comment}) async {
    calls.add('rate:$stars');
  }
}

class FakeLocation implements LocationService {
  LocationAccess access = LocationAccess.granted;
  // Lives as long as the test.
  // ignore: close_sinks
  final fixes = StreamController<LocationFix>.broadcast();
  int watchers = 0;
  bool? lastDriverOnline;

  @override
  Future<LocationAccess> ensureAccess() async => access;

  @override
  Future<LocationFix?> currentPosition() async => null;

  @override
  Stream<LocationFix> watch({bool driverOnline = false}) {
    watchers++;
    lastDriverOnline = driverOnline;
    return fixes.stream;
  }

  @override
  Future<void> openSettings() async {}
}

class FakeNotificationPermission implements NotificationPermission {
  int asked = 0;

  @override
  Future<bool> ensure() async {
    asked++;
    return true;
  }
}

class FakeTransport implements WsTransport {
  final sent = <Map<String, Object?>>[];
  final _incoming = StreamController<Object?>();

  @override
  Future<void> get ready => Future.value();

  @override
  Stream<Object?> get messages => _incoming.stream;

  @override
  void send(String text) => sent.add(jsonDecode(text) as Map<String, Object?>);

  @override
  Future<void> close() async {
    if (!_incoming.isClosed) unawaited(_incoming.close());
  }

  void server(Map<String, Object?> frame) => _incoming.add(jsonEncode(frame));

  void drop() => unawaited(_incoming.close());

  List<Map<String, Object?>> ofType(String type) => sent.where((m) => m['type'] == type).toList();
}

/// A real PodwozkaSocket on fake transports; [connect] authenticates the current one.
class SocketHarness {
  final transports = <FakeTransport>[];
  late final socket = PodwozkaSocket(
    url: Uri.parse('ws://test/ws'),
    tokenProvider: ({bool forceRefresh = false}) async => 'token',
    connect: (_) {
      final t = FakeTransport();
      transports.add(t);
      return t;
    },
    backoff: const [Duration.zero],
  );

  FakeTransport get server => transports.last;

  Future<void> connect() async {
    await pumpQueue();
    server.server({
      'type': 'auth_ok',
      'user_id': 'd1',
      'roles': ['driver'],
    });
    await pumpQueue();
  }
}

Future<void> pumpQueue() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
