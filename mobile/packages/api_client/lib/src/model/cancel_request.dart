//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cancel_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CancelRequest {
  /// Returns a new [CancelRequest] instance.
  CancelRequest({this.reason});

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancelRequest && other.reason == reason;

  @override
  int get hashCode => (reason == null ? 0 : reason.hashCode);

  factory CancelRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
