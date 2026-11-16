//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/vehicle.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_application_upsert.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DriverApplicationUpsert {
  /// Returns a new [DriverApplicationUpsert] instance.
  DriverApplicationUpsert({required this.regionId, required this.vehicle});

  @JsonKey(name: r'region_id', required: true, includeIfNull: false)
  final String regionId;

  @JsonKey(name: r'vehicle', required: true, includeIfNull: false)
  final Vehicle vehicle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverApplicationUpsert &&
          other.regionId == regionId &&
          other.vehicle == vehicle;

  @override
  int get hashCode => regionId.hashCode + vehicle.hashCode;

  factory DriverApplicationUpsert.fromJson(Map<String, dynamic> json) =>
      _$DriverApplicationUpsertFromJson(json);

  Map<String, dynamic> toJson() => _$DriverApplicationUpsertToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
