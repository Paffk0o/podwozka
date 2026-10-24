//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Health {
  /// Returns a new [Health] instance.
  Health({this.status = 'ok', required this.environment});

  @JsonKey(
    defaultValue: 'ok',
    name: r'status',
    required: false,
    includeIfNull: false,
  )
  final String? status;

  @JsonKey(name: r'environment', required: true, includeIfNull: false)
  final String environment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Health &&
          other.status == status &&
          other.environment == environment;

  @override
  int get hashCode => status.hashCode + environment.hashCode;

  factory Health.fromJson(Map<String, dynamic> json) => _$HealthFromJson(json);

  Map<String, dynamic> toJson() => _$HealthToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
