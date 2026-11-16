//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'region_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegionCreate {
  /// Returns a new [RegionCreate] instance.
  RegionCreate({
    required this.name,

    this.teryt,

    required this.area,

    this.active = true,
  });

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'teryt', required: false, includeIfNull: false)
  final String? teryt;

  /// GeoJSON Polygon lub MultiPolygon (EPSG:4326)
  @JsonKey(name: r'area', required: true, includeIfNull: false)
  final Map<String, Object> area;

  @JsonKey(
    defaultValue: true,
    name: r'active',
    required: false,
    includeIfNull: false,
  )
  final bool? active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionCreate &&
          other.name == name &&
          other.teryt == teryt &&
          other.area == area &&
          other.active == active;

  @override
  int get hashCode =>
      name.hashCode +
      (teryt == null ? 0 : teryt.hashCode) +
      area.hashCode +
      active.hashCode;

  factory RegionCreate.fromJson(Map<String, dynamic> json) =>
      _$RegionCreateFromJson(json);

  Map<String, dynamic> toJson() => _$RegionCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
