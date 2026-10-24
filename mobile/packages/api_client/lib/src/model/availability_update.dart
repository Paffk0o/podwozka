//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'availability_update.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AvailabilityUpdate {
  /// Returns a new [AvailabilityUpdate] instance.
  AvailabilityUpdate({required this.online});

  @JsonKey(name: r'online', required: true, includeIfNull: false)
  final bool online;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailabilityUpdate && other.online == online;

  @override
  int get hashCode => online.hashCode;

  factory AvailabilityUpdate.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
