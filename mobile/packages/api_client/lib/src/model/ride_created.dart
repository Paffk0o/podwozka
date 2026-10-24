//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/stripe_payment_init.dart';
import 'package:podwozka_api/src/model/ride.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_created.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RideCreated {
  /// Returns a new [RideCreated] instance.
  RideCreated({required this.ride, required this.payment});

  @JsonKey(name: r'ride', required: true, includeIfNull: false)
  final Ride ride;

  /// Brak dla gotówki
  @JsonKey(name: r'payment', required: true, includeIfNull: true)
  final StripePaymentInit? payment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideCreated && other.ride == ride && other.payment == payment;

  @override
  int get hashCode => ride.hashCode + (payment == null ? 0 : payment.hashCode);

  factory RideCreated.fromJson(Map<String, dynamic> json) =>
      _$RideCreatedFromJson(json);

  Map<String, dynamic> toJson() => _$RideCreatedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
