//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/ride.dart';
import 'package:podwozka_api/src/model/driver_profile.dart';
import 'package:podwozka_api/src/model/ride_offer.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_current_state.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DriverCurrentState {
  /// Returns a new [DriverCurrentState] instance.
  DriverCurrentState({
    required this.profile,

    required this.pendingOffer,

    required this.activeRide,

    required this.nextScheduledRide,
  });

  @JsonKey(name: r'profile', required: true, includeIfNull: false)
  final DriverProfile profile;

  @JsonKey(name: r'pending_offer', required: true, includeIfNull: true)
  final RideOffer? pendingOffer;

  @JsonKey(name: r'active_ride', required: true, includeIfNull: true)
  final Ride? activeRide;

  @JsonKey(name: r'next_scheduled_ride', required: true, includeIfNull: true)
  final Ride? nextScheduledRide;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverCurrentState &&
          other.profile == profile &&
          other.pendingOffer == pendingOffer &&
          other.activeRide == activeRide &&
          other.nextScheduledRide == nextScheduledRide;

  @override
  int get hashCode =>
      profile.hashCode +
      (pendingOffer == null ? 0 : pendingOffer.hashCode) +
      (activeRide == null ? 0 : activeRide.hashCode) +
      (nextScheduledRide == null ? 0 : nextScheduledRide.hashCode);

  factory DriverCurrentState.fromJson(Map<String, dynamic> json) =>
      _$DriverCurrentStateFromJson(json);

  Map<String, dynamic> toJson() => _$DriverCurrentStateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
