import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Everything the passenger app asks the API for. An interface so screens and
/// controllers are tested with an in-memory fake instead of HTTP.
abstract interface class PassengerRepository {
  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    required String sessionToken,
    LatLng? near,
  });
  Future<Place> placeDetails(String placeId, {required String sessionToken});
  Future<Place> reverseGeocode(LatLng point);
  Future<Quote> quote({required Place pickup, required Place destination, DateTime? scheduledAt});
  Future<Ride> orderRide({required String quoteId, required PaymentMethod method, String? note});

  /// Active rides (ongoing and reservations), newest first.
  Future<List<Ride>> activeRides();
  Future<RidePage> history({int offset = 0, int limit = 20});
  Future<Ride> ride(String rideId);
  Future<Ride> cancel(String rideId, {String? reason});
  Future<void> rateDriver(String rideId, {required int stars, String? comment});
}

class ApiPassengerRepository implements PassengerRepository {
  ApiPassengerRepository(this._api);

  final PodwozkaApi _api;

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    required String sessionToken,
    LatLng? near,
  }) async {
    final response = await _api.getPlacesApi().autocompletePlaces(
      input: input,
      sessionToken: sessionToken,
      lat: near?.latitude,
      lng: near?.longitude,
    );
    return response.data ?? const [];
  }

  @override
  Future<Place> placeDetails(String placeId, {required String sessionToken}) async =>
      (await _api.getPlacesApi().getPlace(placeId: placeId, sessionToken: sessionToken)).data!;

  @override
  Future<Place> reverseGeocode(LatLng point) async =>
      (await _api.getPlacesApi().reverseGeocode(lat: point.latitude, lng: point.longitude)).data!;

  @override
  Future<Quote> quote({
    required Place pickup,
    required Place destination,
    DateTime? scheduledAt,
  }) async {
    final response = await _api.getQuotesApi().createQuote(
      quoteRequest: QuoteRequest(
        pickup: pickup,
        destination: destination,
        // The API rejects dates without a timezone — always send UTC.
        scheduledAt: scheduledAt?.toUtc(),
      ),
    );
    return response.data!;
  }

  @override
  Future<Ride> orderRide({
    required String quoteId,
    required PaymentMethod method,
    String? note,
  }) async {
    final response = await _api.getRidesApi().createRide(
      rideCreate: RideCreate(quoteId: quoteId, paymentMethod: method, passengerNote: note),
    );
    return response.data!.ride;
  }

  @override
  Future<List<Ride>> activeRides() async =>
      (await _api.getRidesApi().listMyRides(active: true, limit: 20)).data?.items ?? const [];

  @override
  Future<RidePage> history({int offset = 0, int limit = 20}) async =>
      (await _api.getRidesApi().listMyRides(active: false, limit: limit, offset: offset)).data!;

  @override
  Future<Ride> ride(String rideId) async =>
      (await _api.getRidesApi().getMyRide(rideId: rideId)).data!;

  @override
  Future<Ride> cancel(String rideId, {String? reason}) async =>
      (await _api.getRidesApi().cancelMyRide(
        rideId: rideId,
        cancelRequest: CancelRequest(reason: reason),
      )).data!;

  @override
  Future<void> rateDriver(String rideId, {required int stars, String? comment}) async {
    await _api.getRidesApi().rateDriver(
      rideId: rideId,
      ratingCreate: RatingCreate(stars: stars, comment: comment),
    );
  }
}

final passengerRepositoryProvider = Provider<PassengerRepository>(
  (ref) => ApiPassengerRepository(ref.watch(podwozkaApiProvider)),
);
