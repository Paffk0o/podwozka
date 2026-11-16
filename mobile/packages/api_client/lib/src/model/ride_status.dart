//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Ride state machine — transitions only via the `rides` service (zarys §6).
enum RideStatus {
  @JsonValue(r'requested')
  requested(r'requested'),
  @JsonValue(r'scheduled')
  scheduled(r'scheduled'),
  @JsonValue(r'dispatching')
  dispatching(r'dispatching'),
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'driver_arriving')
  driverArriving(r'driver_arriving'),
  @JsonValue(r'arrived')
  arrived(r'arrived'),
  @JsonValue(r'in_progress')
  inProgress(r'in_progress'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'cancelled_by_passenger')
  cancelledByPassenger(r'cancelled_by_passenger'),
  @JsonValue(r'cancelled_by_driver')
  cancelledByDriver(r'cancelled_by_driver'),
  @JsonValue(r'no_driver')
  noDriver(r'no_driver');

  const RideStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
