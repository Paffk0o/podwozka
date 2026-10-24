// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_in.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeviceTokenInCWProxy {
  DeviceTokenIn token(String token);

  DeviceTokenIn platform(DevicePlatform platform);

  DeviceTokenIn app(String app);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DeviceTokenIn(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DeviceTokenIn(...).copyWith(id: 12, name: "My name")
  /// ```
  DeviceTokenIn call({String token, DevicePlatform platform, String app});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDeviceTokenIn.copyWith(...)` or call `instanceOfDeviceTokenIn.copyWith.fieldName(value)` for a single field.
class _$DeviceTokenInCWProxyImpl implements _$DeviceTokenInCWProxy {
  const _$DeviceTokenInCWProxyImpl(this._value);

  final DeviceTokenIn _value;

  @override
  DeviceTokenIn token(String token) => call(token: token);

  @override
  DeviceTokenIn platform(DevicePlatform platform) => call(platform: platform);

  @override
  DeviceTokenIn app(String app) => call(app: app);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DeviceTokenIn(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DeviceTokenIn(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DeviceTokenIn call({
    Object? token = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? app = const $CopyWithPlaceholder(),
  }) {
    return DeviceTokenIn(
      token: token == const $CopyWithPlaceholder() || token == null
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
      platform: platform == const $CopyWithPlaceholder() || platform == null
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as DevicePlatform,
      app: app == const $CopyWithPlaceholder() || app == null
          ? _value.app
          // ignore: cast_nullable_to_non_nullable
          : app as String,
    );
  }
}

extension $DeviceTokenInCopyWith on DeviceTokenIn {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDeviceTokenIn.copyWith(...)` or `instanceOfDeviceTokenIn.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeviceTokenInCWProxy get copyWith => _$DeviceTokenInCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTokenIn _$DeviceTokenInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeviceTokenIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['token', 'platform', 'app']);
      final val = DeviceTokenIn(
        token: $checkedConvert('token', (v) => v as String),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$DevicePlatformEnumMap, v),
        ),
        app: $checkedConvert('app', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DeviceTokenInToJson(DeviceTokenIn instance) =>
    <String, dynamic>{
      'token': instance.token,
      'platform': _$DevicePlatformEnumMap[instance.platform]!,
      'app': instance.app,
    };

const _$DevicePlatformEnumMap = {
  DevicePlatform.android: 'android',
  DevicePlatform.ios: 'ios',
  DevicePlatform.web: 'web',
};
