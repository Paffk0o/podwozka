import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Reservations board, earnings and ride history. Behind an interface for tests.
abstract interface class DriverRecordsRepository {
  /// Unclaimed reservations in my region, soonest first.
  Future<List<Ride>> board();
  Future<Ride> claim(String rideId);

  /// Gives a claimed reservation back (> 30 min before pickup it returns to the board).
  Future<Ride> giveBack(String rideId, {required String reason});
  Future<EarningsSummary> earnings({required DateTime from, required DateTime to});

  /// `active: true` = my claimed reservations / current ride, `false` = finished rides.
  Future<RidePage> rides({required bool active, int offset = 0, int limit = 20});
}

class ApiDriverRecordsRepository implements DriverRecordsRepository {
  ApiDriverRecordsRepository(this._api);

  final PodwozkaApi _api;

  DriverApi get _driver => _api.getDriverApi();

  @override
  Future<List<Ride>> board() async => (await _driver.listScheduledBoard()).data ?? const [];

  @override
  Future<Ride> claim(String rideId) async =>
      (await _driver.claimScheduledRide(rideId: rideId)).data!;

  @override
  Future<Ride> giveBack(String rideId, {required String reason}) async =>
      (await _driver.cancelDriverRide(
        rideId: rideId,
        cancelRequest: CancelRequest(reason: reason),
      )).data!;

  @override
  Future<EarningsSummary> earnings({required DateTime from, required DateTime to}) async =>
      // `date` parameters: only the calendar day matters.
      (await _driver.getDriverEarnings(
        dateFrom: DateTime(from.year, from.month, from.day),
        dateTo: DateTime(to.year, to.month, to.day),
      )).data!;

  @override
  Future<RidePage> rides({required bool active, int offset = 0, int limit = 20}) async =>
      (await _driver.listDriverRides(active: active, offset: offset, limit: limit)).data!;
}

final driverRecordsRepositoryProvider = Provider<DriverRecordsRepository>(
  (ref) => ApiDriverRecordsRepository(ref.watch(podwozkaApiProvider)),
);
