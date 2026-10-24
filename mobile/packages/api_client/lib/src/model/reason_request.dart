//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reason_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReasonRequest {
  /// Returns a new [ReasonRequest] instance.
  ReasonRequest({required this.reason});

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasonRequest && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  factory ReasonRequest.fromJson(Map<String, dynamic> json) =>
      _$ReasonRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReasonRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
