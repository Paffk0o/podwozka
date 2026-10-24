//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'region_update.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegionUpdate {
  /// Returns a new [RegionUpdate] instance.
  RegionUpdate({this.name, this.area, this.active});

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'area', required: false, includeIfNull: false)
  final Map<String, Object>? area;

  @JsonKey(name: r'active', required: false, includeIfNull: false)
  final bool? active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionUpdate &&
          other.name == name &&
          other.area == area &&
          other.active == active;

  @override
  int get hashCode =>
      (name == null ? 0 : name.hashCode) +
      (area == null ? 0 : area.hashCode) +
      (active == null ? 0 : active.hashCode);

  factory RegionUpdate.fromJson(Map<String, dynamic> json) =>
      _$RegionUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$RegionUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
