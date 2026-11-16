//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/device_platform.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'device_token_in.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeviceTokenIn {
  /// Returns a new [DeviceTokenIn] instance.
  DeviceTokenIn({
    required this.token,

    required this.platform,

    required this.app,
  });

  /// Token FCM
  @JsonKey(name: r'token', required: true, includeIfNull: false)
  final String token;

  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final DevicePlatform platform;

  /// Która aplikacja
  @JsonKey(name: r'app', required: true, includeIfNull: false)
  final String app;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceTokenIn &&
          other.token == token &&
          other.platform == platform &&
          other.app == app;

  @override
  int get hashCode => token.hashCode + platform.hashCode + app.hashCode;

  factory DeviceTokenIn.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenInFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTokenInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
