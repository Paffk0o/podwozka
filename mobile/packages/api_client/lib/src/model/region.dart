//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Region {
  /// Returns a new [Region] instance.
  Region({
    required this.id,

    required this.name,

    required this.teryt,

    this.timezone = 'Europe/Warsaw',

    required this.active,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Region &&
          other.id == id &&
          other.name == name &&
          other.teryt == teryt &&
          other.timezone == timezone &&
          other.active == active;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      (teryt == null ? 0 : teryt.hashCode) +
      timezone.hashCode +
      active.hashCode;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);

  Map<String, dynamic> toJson() => _$RegionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
