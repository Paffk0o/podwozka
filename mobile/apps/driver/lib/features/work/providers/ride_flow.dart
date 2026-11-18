import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// What the driver's ride panel shows.
enum DriverStage {
  /// Accepted, not yet on the way.
  accepted,

  /// On the way to the pickup.
  toPickup,

  /// Waiting at the pickup.
  atPickup,
  inProgress,

  /// Ride completed, cash not yet confirmed.
  collectCash,

  /// Paid — rate the passenger.
  ratePassenger,
  cancelled,
}

DriverStage driverStage(Ride ride) => switch (ride.status) {
  RideStatus.driverArriving => DriverStage.toPickup,
  RideStatus.arrived => DriverStage.atPickup,
  RideStatus.inProgress => DriverStage.inProgress,
  RideStatus.completed when ride.paymentStatus == PaymentStatus.cashDue => DriverStage.collectCash,
  RideStatus.completed => DriverStage.ratePassenger,
  RideStatus.cancelledByPassenger ||
  RideStatus.cancelledByDriver ||
  RideStatus.noDriver => DriverStage.cancelled,
  _ => DriverStage.accepted,
};

/// The one big button of the ride panel.
({DriverRideAction action, String label})? nextAction(Ride ride) => switch (ride.status) {
  RideStatus.accepted => (action: DriverRideAction.depart, label: 'Jadę po pasażera'),
  RideStatus.driverArriving => (action: DriverRideAction.arrived, label: 'Jestem na miejscu'),
  RideStatus.arrived => (action: DriverRideAction.start, label: 'Pasażer wsiadł — ruszamy'),
  RideStatus.inProgress => (action: DriverRideAction.complete, label: 'Zakończ kurs'),
  _ => null,
};

String driverStageTitle(DriverStage stage) => switch (stage) {
  DriverStage.accepted => 'Kurs przyjęty',
  DriverStage.toPickup => 'Jedziesz po pasażera',
  DriverStage.atPickup => 'Czekasz na pasażera',
  DriverStage.inProgress => 'Kurs w trakcie',
  DriverStage.collectCash => 'Pobierz zapłatę',
  DriverStage.ratePassenger => 'Kurs zakończony',
  DriverStage.cancelled => 'Kurs anulowany',
};

/// Before the passenger is on board the driver may still cancel (backend state machine).
bool driverCanCancel(Ride ride) => switch (ride.status) {
  RideStatus.accepted || RideStatus.driverArriving || RideStatus.arrived => true,
  _ => false,
};

/// Where „Nawiguj” leads: the pickup until the passenger is on board, then the destination.
Place navigationTarget(Ride ride) =>
    ride.status == RideStatus.inProgress ? ride.destination : ride.pickup;

enum NavigationApp { googleMaps, waze }

/// Turn-by-turn navigation is handed over to Google Maps / Waze (zarys 3.1, #8).
/// The first URI opens the app directly; the second is the web fallback.
List<Uri> navigationUris(LatLng target, NavigationApp app) {
  final lat = target.latitude;
  final lng = target.longitude;
  return switch (app) {
    NavigationApp.googleMaps => [
      Uri.parse('google.navigation:q=$lat,$lng&mode=d'),
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$lat,$lng',
        'travelmode': 'driving',
      }),
    ],
    NavigationApp.waze => [
      Uri.https('waze.com', '/ul', {'ll': '$lat,$lng', 'navigate': 'yes'}),
    ],
  };
}

/// Seconds left to accept an offer (the server decides; this is only the countdown).
int offerSecondsLeft(DateTime expiresAt, {DateTime? now}) {
  final left = expiresAt.difference((now ?? DateTime.now()).toUtc()).inMilliseconds;
  return left <= 0 ? 0 : (left / 1000).ceil();
}
