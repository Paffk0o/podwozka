//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/payment_method.dart';
import 'package:podwozka_api/src/model/payment_status.dart';
import 'package:podwozka_api/src/model/ride_driver_info.dart';
import 'package:podwozka_api/src/model/ride_status.dart';
import 'package:podwozka_api/src/model/place.dart';
import 'package:podwozka_api/src/model/ride_passenger_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Ride {
  /// Returns a new [Ride] instance.
  Ride({
    required this.id,

    required this.status,

    required this.regionId,

    required this.pickup,

    required this.destination,

    required this.scheduledAt,

    required this.requestedAt,

    required this.acceptedAt,

    required this.startedAt,

    required this.completedAt,

    required this.cancelledAt,

    required this.cancelReason,

    required this.price,

    this.currency = 'PLN',

    required this.paymentMethod,

    required this.paymentStatus,

    required this.distanceM,

    required this.durationS,

    required this.routePolyline,

    required this.passengerNote,

    required this.driver,

    required this.passenger,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final RideStatus status;

  @JsonKey(name: r'region_id', required: true, includeIfNull: false)
  final String regionId;

  @JsonKey(name: r'pickup', required: true, includeIfNull: false)
  final Place pickup;

  @JsonKey(name: r'destination', required: true, includeIfNull: false)
  final Place destination;

  /// Rezerwacja; brak = kurs teraz
  @JsonKey(name: r'scheduled_at', required: true, includeIfNull: true)
  final DateTime? scheduledAt;

  @JsonKey(name: r'requested_at', required: true, includeIfNull: false)
  final DateTime requestedAt;

  @JsonKey(name: r'accepted_at', required: true, includeIfNull: true)
  final DateTime? acceptedAt;

  @JsonKey(name: r'started_at', required: true, includeIfNull: true)
  final DateTime? startedAt;

  @JsonKey(name: r'completed_at', required: true, includeIfNull: true)
  final DateTime? completedAt;

  @JsonKey(name: r'cancelled_at', required: true, includeIfNull: true)
  final DateTime? cancelledAt;

  @JsonKey(name: r'cancel_reason', required: true, includeIfNull: true)
  final String? cancelReason;

  /// Kwota w groszach (1 PLN = 100)
  // minimum: 0
  @JsonKey(name: r'price', required: true, includeIfNull: false)
  final int price;

  @JsonKey(
    defaultValue: 'PLN',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )
  final String? currency;

  @JsonKey(name: r'payment_method', required: true, includeIfNull: false)
  final PaymentMethod paymentMethod;

  @JsonKey(name: r'payment_status', required: true, includeIfNull: false)
  final PaymentStatus paymentStatus;

  @JsonKey(name: r'distance_m', required: true, includeIfNull: false)
  final int distanceM;

  @JsonKey(name: r'duration_s', required: true, includeIfNull: false)
  final int durationS;

  @JsonKey(name: r'route_polyline', required: true, includeIfNull: true)
  final String? routePolyline;

  @JsonKey(name: r'passenger_note', required: true, includeIfNull: true)
  final String? passengerNote;

  @JsonKey(name: r'driver', required: true, includeIfNull: true)
  final RideDriverInfo? driver;

  /// Wypełniane tylko w widoku kierowcy/admina
  @JsonKey(name: r'passenger', required: true, includeIfNull: true)
  final RidePassengerInfo? passenger;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ride &&
          other.id == id &&
          other.status == status &&
          other.regionId == regionId &&
          other.pickup == pickup &&
          other.destination == destination &&
          other.scheduledAt == scheduledAt &&
          other.requestedAt == requestedAt &&
          other.acceptedAt == acceptedAt &&
          other.startedAt == startedAt &&
          other.completedAt == completedAt &&
          other.cancelledAt == cancelledAt &&
          other.cancelReason == cancelReason &&
          other.price == price &&
          other.currency == currency &&
          other.paymentMethod == paymentMethod &&
          other.paymentStatus == paymentStatus &&
          other.distanceM == distanceM &&
          other.durationS == durationS &&
          other.routePolyline == routePolyline &&
          other.passengerNote == passengerNote &&
          other.driver == driver &&
          other.passenger == passenger;

  @override
  int get hashCode =>
      id.hashCode +
      status.hashCode +
      regionId.hashCode +
      pickup.hashCode +
      destination.hashCode +
      (scheduledAt == null ? 0 : scheduledAt.hashCode) +
      requestedAt.hashCode +
      (acceptedAt == null ? 0 : acceptedAt.hashCode) +
      (startedAt == null ? 0 : startedAt.hashCode) +
      (completedAt == null ? 0 : completedAt.hashCode) +
      (cancelledAt == null ? 0 : cancelledAt.hashCode) +
      (cancelReason == null ? 0 : cancelReason.hashCode) +
      price.hashCode +
      currency.hashCode +
      paymentMethod.hashCode +
      paymentStatus.hashCode +
      distanceM.hashCode +
      durationS.hashCode +
      (routePolyline == null ? 0 : routePolyline.hashCode) +
      (passengerNote == null ? 0 : passengerNote.hashCode) +
      (driver == null ? 0 : driver.hashCode) +
      (passenger == null ? 0 : passenger.hashCode);

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);

  Map<String, dynamic> toJson() => _$RideToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
