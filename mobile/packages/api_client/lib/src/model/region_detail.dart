//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'region_detail.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegionDetail {
  /// Returns a new [RegionDetail] instance.
  RegionDetail({
    required this.id,

    required this.name,

    required this.teryt,

    this.timezone = 'Europe/Warsaw',

    required this.active,

    required this.area,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  /// Kod TERYT gminy (7 cyfr)
  @JsonKey(name: r'teryt', required: true, includeIfNull: true)
  final String? teryt;

  @JsonKey(
    defaultValue: 'Europe/Warsaw',
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )
  final String? timezone;

  @JsonKey(name: r'active', required: true, includeIfNull: false)
  final bool active;

  /// Granica gminy jako GeoJSON (Polygon lub MultiPolygon, WGS84 / EPSG:4326)
  @JsonKey(name: r'area', required: true, includeIfNull: false)
  final Map<String, Object> area;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionDetail &&
          other.id == id &&
          other.name == name &&
          other.teryt == teryt &&
          other.timezone == timezone &&
          other.active == active &&
          other.area == area;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      (teryt == null ? 0 : teryt.hashCode) +
      timezone.hashCode +
      active.hashCode +
      area.hashCode;

  factory RegionDetail.fromJson(Map<String, dynamic> json) =>
      _$RegionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$RegionDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
