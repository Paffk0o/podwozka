import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Everything the driver does at work. Behind an interface so controllers and screens
/// are tested with an in-memory fake.
abstract interface class WorkRepository {
  /// Profile (incl. `online`), pending offer, active ride and the next reservation.
  Future<DriverCurrentState> current();
  Future<DriverProfile> setOnline(bool online);
  Future<Ride> acceptOffer(String offerId);
  Future<void> declineOffer(String offerId);
  Future<Ride> action(String rideId, DriverRideAction action);
  Future<Ride> cashCollected(String rideId);
  Future<Ride> cancel(String rideId, {required String reason});
  Future<void> ratePassenger(String rideId, {required int stars, String? comment});
}

class ApiWorkRepository implements WorkRepository {
  ApiWorkRepository(this._api);

  final PodwozkaApi _api;

  DriverApi get _driver => _api.getDriverApi();

  @override
  Future<DriverCurrentState> current() async => (await _driver.getDriverCurrentState()).data!;

  @override
  Future<DriverProfile> setOnline(bool online) async =>
      (await _driver.setDriverAvailability(availabilityUpdate: AvailabilityUpdate(online: online)))
          .data!;

  @override
  Future<Ride> acceptOffer(String offerId) async =>
      (await _driver.acceptOffer(offerId: offerId)).data!;

  @override
  Future<void> declineOffer(String offerId) async {
    await _driver.declineOffer(offerId: offerId);
  }

  @override
  Future<Ride> action(String rideId, DriverRideAction action) async =>
      (await _driver.performRideAction(
        rideId: rideId,
        driverRideActionRequest: DriverRideActionRequest(action: action),
      )).data!;

  @override
  Future<Ride> cashCollected(String rideId) async =>
      (await _driver.confirmCashCollected(rideId: rideId)).data!;

  @override
  Future<Ride> cancel(String rideId, {required String reason}) async =>
      (await _driver.cancelDriverRide(
        rideId: rideId,
        cancelRequest: CancelRequest(reason: reason),
      )).data!;

  @override
  Future<void> ratePassenger(String rideId, {required int stars, String? comment}) async {
    await _driver.ratePassenger(
      rideId: rideId,
      ratingCreate: RatingCreate(stars: stars, comment: comment),
    );
  }
}

final workRepositoryProvider = Provider<WorkRepository>(
  (ref) => ApiWorkRepository(ref.watch(podwozkaApiProvider)),
);
