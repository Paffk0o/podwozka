import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_passenger/data/passenger_repository.dart';

final wieliczka = Place(
  location: GeoPoint(lat: 49.9837, lng: 20.0553),
  address: 'Rynek Górny 1, Wieliczka',
);
final krakow = Place(
  location: GeoPoint(lat: 50.0617, lng: 19.9373),
  address: 'Rynek Główny, Kraków',
);

final jan = RideDriverInfo(
  id: 'd1',
  fullName: 'Jan Kierowca',
  phone: '+48600200300',
  ratingAvg: 4.9,
  vehicle: Vehicle(make: 'Skoda', model: 'Octavia', color: 'szary', plate: 'KWI12345'),
  location: GeoPoint(lat: 49.99, lng: 20.06),
);

Ride aRide({
  String id = 'r1',
  RideStatus status = RideStatus.requested,
  DateTime? scheduledAt,
  RideDriverInfo? driver,
}) => Ride(
  id: id,
  status: status,
  regionId: 'reg',
  pickup: wieliczka,
  destination: krakow,
  scheduledAt: scheduledAt,
  requestedAt: DateTime.utc(2026, 11, 18, 10),
  acceptedAt: null,
  startedAt: null,
  completedAt: null,
  cancelledAt: null,
  cancelReason: null,
  price: 6693,
  paymentMethod: PaymentMethod.cash,
  paymentStatus: PaymentStatus.cashDue,
  distanceM: 15700,
  durationS: 1440,
  routePolyline: null,
  passengerNote: null,
  driver: driver,
  passenger: null,
);

Quote aQuote({String id = 'q1', int price = 6693, DateTime? expiresAt, DateTime? scheduledAt}) =>
    Quote(
      id: id,
      regionId: 'reg',
      regionName: 'Gmina Wieliczka',
      pickup: wieliczka,
      destination: krakow,
      scheduledAt: scheduledAt,
      distanceM: 15700,
      durationS: 1440,
      price: price,
      tariffId: 't1',
      routePolyline: null,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 5)),
    );

DioException apiError(int status, Object? data) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

/// In-memory backend for the passenger app.
class FakePassengerRepository implements PassengerRepository {
  final quoteCalls = <({Place pickup, Place destination, DateTime? scheduledAt})>[];
  final orders = <String>[];
  final cancels = <(String, String?)>[];
  final ratings = <(String, int, String?)>[];
  final autocompleteCalls = <(String, String)>[];

  /// Next results; a function lets a test hold a response (Completer) or throw.
  Future<Quote> Function()? onQuote;
  Future<Ride> Function()? onOrder;
  List<Ride> active = [];
  Map<String, Ride> rides = {};
  Object? reverseError;
  List<PlaceSuggestion> suggestions = [];

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    required String sessionToken,
    LatLng? near,
  }) async {
    autocompleteCalls.add((input, sessionToken));
    return suggestions;
  }

  @override
  Future<Place> placeDetails(String placeId, {required String sessionToken}) async => krakow;

  @override
  Future<Place> reverseGeocode(LatLng point) async {
    final error = reverseError;
    if (error != null) throw error;
    return Place(
      location: point.toGeoPoint(),
      address: 'Ulica przy ${point.latitude.toStringAsFixed(3)}',
    );
  }

  @override
  Future<Quote> quote({required Place pickup, required Place destination, DateTime? scheduledAt}) {
    quoteCalls.add((pickup: pickup, destination: destination, scheduledAt: scheduledAt));
    return onQuote?.call() ?? Future.value(aQuote());
  }

  @override
  Future<Ride> orderRide({required String quoteId, required PaymentMethod method, String? note}) {
    orders.add('$quoteId/${method.value}');
    return onOrder?.call() ?? Future.value(aRide());
  }

  @override
  Future<List<Ride>> activeRides() async => active;

  @override
  Future<RidePage> history({int offset = 0, int limit = 20}) async =>
      RidePage(items: const [], total: 0, limit: limit, offset: offset);

  @override
  Future<Ride> ride(String rideId) async =>
      rides[rideId] ?? active.firstWhere((r) => r.id == rideId);

  @override
  Future<Ride> cancel(String rideId, {String? reason}) async {
    cancels.add((rideId, reason));
    return aRide(id: rideId, status: RideStatus.cancelledByPassenger);
  }

  @override
  Future<void> rateDriver(String rideId, {required int stars, String? comment}) async {
    ratings.add((rideId, stars, comment));
  }
}

class FakeLocationService implements LocationService {
  LocationAccess access = LocationAccess.granted;
  LocationFix? fix = const LocationFix(lat: 49.9837, lng: 20.0553);

  @override
  Future<LocationAccess> ensureAccess() async => access;

  @override
  Future<LocationFix?> currentPosition() async => fix;

  @override
  Stream<LocationFix> watch({bool driverOnline = false}) => const Stream.empty();

  @override
  Future<void> openSettings() async {}
}

/// Socket transport the test can drive (server frames in, app frames recorded).
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

  Iterable<String?> subscribedRides() =>
      sent.where((m) => m['type'] == 'subscribe').map((m) => m['ride_id'] as String?);
}
