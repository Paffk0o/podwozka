//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/driver_ride_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_ride_action_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DriverRideActionRequest {
  /// Returns a new [DriverRideActionRequest] instance.
  DriverRideActionRequest({required this.action});

  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final DriverRideAction action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverRideActionRequest && other.action == action;

  @override
  int get hashCode => action.hashCode;

  factory DriverRideActionRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverRideActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DriverRideActionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
