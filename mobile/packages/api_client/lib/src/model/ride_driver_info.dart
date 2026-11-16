//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/vehicle.dart';
import 'package:podwozka_api/src/model/geo_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_driver_info.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RideDriverInfo {
  /// Returns a new [RideDriverInfo] instance.
  RideDriverInfo({
    required this.id,

    required this.fullName,

    required this.phone,

    required this.ratingAvg,

    required this.vehicle,

    required this.location,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'full_name', required: true, includeIfNull: false)
  final String fullName;

  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @JsonKey(name: r'rating_avg', required: true, includeIfNull: true)
  final num? ratingAvg;

  @JsonKey(name: r'vehicle', required: true, includeIfNull: false)
  final Vehicle vehicle;

  /// Ostatnia znana pozycja (dalej przez WebSocket)
  @JsonKey(name: r'location', required: true, includeIfNull: true)
  final GeoPoint? location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideDriverInfo &&
          other.id == id &&
          other.fullName == fullName &&
          other.phone == phone &&
          other.ratingAvg == ratingAvg &&
          other.vehicle == vehicle &&
          other.location == location;

  @override
  int get hashCode =>
      id.hashCode +
      fullName.hashCode +
      (phone == null ? 0 : phone.hashCode) +
      (ratingAvg == null ? 0 : ratingAvg.hashCode) +
      vehicle.hashCode +
      (location == null ? 0 : location.hashCode);

  factory RideDriverInfo.fromJson(Map<String, dynamic> json) =>
      _$RideDriverInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RideDriverInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
