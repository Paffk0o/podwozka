import 'package:podwozka_api/podwozka_api.dart';

/// What the passenger's ride screen shows — derived from the ride status only,
/// so it is the same after a restart (REST) and after live updates (WebSocket).
enum PassengerStage {
  /// Looking for a driver (requested / dispatching).
  searching,

  /// Reservation waiting for its time (with or without a driver yet).
  scheduled,

  /// A driver accepted; is about to set off (accepted).
  driverAssigned,

  /// Driver on the way to the pickup (driver_arriving).
  driverArriving,

  /// Driver waiting at the pickup (arrived).
  driverArrived,
  inProgress,
  completed,
  cancelledByPassenger,
  cancelledByDriver,
  noDriver,
}

PassengerStage stageOf(RideStatus status) => switch (status) {
  RideStatus.requested || RideStatus.dispatching => PassengerStage.searching,
  RideStatus.scheduled => PassengerStage.scheduled,
  RideStatus.accepted => PassengerStage.driverAssigned,
  RideStatus.driverArriving => PassengerStage.driverArriving,
  RideStatus.arrived => PassengerStage.driverArrived,
  RideStatus.inProgress => PassengerStage.inProgress,
  RideStatus.completed => PassengerStage.completed,
  RideStatus.cancelledByPassenger => PassengerStage.cancelledByPassenger,
  RideStatus.cancelledByDriver => PassengerStage.cancelledByDriver,
  RideStatus.noDriver => PassengerStage.noDriver,
};

extension PassengerStageX on PassengerStage {
  /// Mirrors the backend state machine: everything before the ride starts.
  bool get canCancel => switch (this) {
    PassengerStage.searching ||
    PassengerStage.scheduled ||
    PassengerStage.driverAssigned ||
    PassengerStage.driverArriving ||
    PassengerStage.driverArrived => true,
    _ => false,
  };

  bool get isFinished => switch (this) {
    PassengerStage.completed ||
    PassengerStage.cancelledByPassenger ||
    PassengerStage.cancelledByDriver ||
    PassengerStage.noDriver => true,
    _ => false,
  };

  /// Whether the driver's live position is worth showing.
  bool get showsDriver => switch (this) {
    PassengerStage.driverAssigned ||
    PassengerStage.driverArriving ||
    PassengerStage.driverArrived ||
    PassengerStage.inProgress => true,
    _ => false,
  };

  String get title => switch (this) {
    PassengerStage.searching => 'Szukamy kierowcy…',
    PassengerStage.scheduled => 'Rezerwacja przyjęta',
    PassengerStage.driverAssigned => 'Kierowca przyjął kurs',
    PassengerStage.driverArriving => 'Kierowca jedzie po Ciebie',
    PassengerStage.driverArrived => 'Kierowca czeka na miejscu',
    PassengerStage.inProgress => 'Jesteś w drodze',
    PassengerStage.completed => 'Dojechaliśmy!',
    PassengerStage.cancelledByPassenger => 'Kurs anulowany',
    PassengerStage.cancelledByDriver => 'Kierowca anulował kurs',
    PassengerStage.noDriver => 'Brak wolnych kierowców',
  };
}

/// A claimed reservation is `accepted` long before the trip — until shortly before pickup
/// it is still shown as a reservation, not as a ride in progress.
const reservationLeadTime = Duration(minutes: 60);

PassengerStage passengerStage(Ride ride, {DateTime? now}) {
  final stage = stageOf(ride.status);
  final scheduledAt = ride.scheduledAt;
  if (stage == PassengerStage.driverAssigned &&
      scheduledAt != null &&
      scheduledAt.isAfter((now ?? DateTime.now()).add(reservationLeadTime))) {
    return PassengerStage.scheduled;
  }
  return stage;
}

/// Rides "now" that take over the home screen. Reservations stay listed on the order screen
/// until shortly before pickup.
bool isOngoing(Ride ride, {DateTime? now}) => switch (passengerStage(ride, now: now)) {
  PassengerStage.searching ||
  PassengerStage.driverAssigned ||
  PassengerStage.driverArriving ||
  PassengerStage.driverArrived ||
  PassengerStage.inProgress => true,
  _ => false,
};
