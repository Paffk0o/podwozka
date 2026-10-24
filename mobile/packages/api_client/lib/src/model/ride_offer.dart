//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/ride.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_offer.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RideOffer {
  /// Returns a new [RideOffer] instance.
  RideOffer({
    required this.id,

    required this.ride,

    required this.pickupDistanceM,

    required this.pickupEtaS,

    required this.expiresAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'ride', required: true, includeIfNull: false)
  final Ride ride;

  @JsonKey(name: r'pickup_distance_m', required: true, includeIfNull: false)
  final int pickupDistanceM;

  @JsonKey(name: r'pickup_eta_s', required: true, includeIfNull: false)
  final int pickupEtaS;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideOffer &&
          other.id == id &&
          other.ride == ride &&
          other.pickupDistanceM == pickupDistanceM &&
          other.pickupEtaS == pickupEtaS &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      id.hashCode +
      ride.hashCode +
      pickupDistanceM.hashCode +
      pickupEtaS.hashCode +
      expiresAt.hashCode;

  factory RideOffer.fromJson(Map<String, dynamic> json) =>
      _$RideOfferFromJson(json);

  Map<String, dynamic> toJson() => _$RideOfferToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
