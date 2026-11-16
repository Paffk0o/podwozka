//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_passenger_info.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RidePassengerInfo {
  /// Returns a new [RidePassengerInfo] instance.
  RidePassengerInfo({
    required this.id,

    required this.fullName,

    required this.phone,

    required this.ratingAvg,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'full_name', required: true, includeIfNull: false)
  final String fullName;

  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @JsonKey(name: r'rating_avg', required: true, includeIfNull: true)
  final num? ratingAvg;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RidePassengerInfo &&
          other.id == id &&
          other.fullName == fullName &&
          other.phone == phone &&
          other.ratingAvg == ratingAvg;

  @override
  int get hashCode =>
      id.hashCode +
      fullName.hashCode +
      (phone == null ? 0 : phone.hashCode) +
      (ratingAvg == null ? 0 : ratingAvg.hashCode);

  factory RidePassengerInfo.fromJson(Map<String, dynamic> json) =>
      _$RidePassengerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RidePassengerInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
