// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicConfigCWProxy {
  PublicConfig oidcIssuer(String oidcIssuer);

  PublicConfig stripePublishableKey(String? stripePublishableKey);

  PublicConfig minAppVersion(String? minAppVersion);

  PublicConfig supportPhone(String? supportPhone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PublicConfig(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PublicConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  PublicConfig call({
    String oidcIssuer,
    String? stripePublishableKey,
    String? minAppVersion,
    String? supportPhone,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPublicConfig.copyWith(...)` or call `instanceOfPublicConfig.copyWith.fieldName(value)` for a single field.
class _$PublicConfigCWProxyImpl implements _$PublicConfigCWProxy {
  const _$PublicConfigCWProxyImpl(this._value);

  final PublicConfig _value;

  @override
  PublicConfig oidcIssuer(String oidcIssuer) => call(oidcIssuer: oidcIssuer);

  @override
  PublicConfig stripePublishableKey(String? stripePublishableKey) =>
      call(stripePublishableKey: stripePublishableKey);

  @override
  PublicConfig minAppVersion(String? minAppVersion) =>
      call(minAppVersion: minAppVersion);

  @override
  PublicConfig supportPhone(String? supportPhone) =>
      call(supportPhone: supportPhone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PublicConfig(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PublicConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  PublicConfig call({
    Object? oidcIssuer = const $CopyWithPlaceholder(),
    Object? stripePublishableKey = const $CopyWithPlaceholder(),
    Object? minAppVersion = const $CopyWithPlaceholder(),
    Object? supportPhone = const $CopyWithPlaceholder(),
  }) {
    return PublicConfig(
      oidcIssuer:
          oidcIssuer == const $CopyWithPlaceholder() || oidcIssuer == null
          ? _value.oidcIssuer
          // ignore: cast_nullable_to_non_nullable
          : oidcIssuer as String,
      stripePublishableKey: stripePublishableKey == const $CopyWithPlaceholder()
          ? _value.stripePublishableKey
          // ignore: cast_nullable_to_non_nullable
          : stripePublishableKey as String?,
      minAppVersion: minAppVersion == const $CopyWithPlaceholder()
          ? _value.minAppVersion
          // ignore: cast_nullable_to_non_nullable
          : minAppVersion as String?,
      supportPhone: supportPhone == const $CopyWithPlaceholder()
          ? _value.supportPhone
          // ignore: cast_nullable_to_non_nullable
          : supportPhone as String?,
    );
  }
}

extension $PublicConfigCopyWith on PublicConfig {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPublicConfig.copyWith(...)` or `instanceOfPublicConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicConfigCWProxy get copyWith => _$PublicConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicConfig _$PublicConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PublicConfig',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['oidc_issuer', 'stripe_publishable_key'],
        );
        final val = PublicConfig(
          oidcIssuer: $checkedConvert('oidc_issuer', (v) => v as String),
          stripePublishableKey: $checkedConvert(
            'stripe_publishable_key',
            (v) => v as String?,
          ),
          minAppVersion: $checkedConvert(
            'min_app_version',
            (v) => v as String? ?? '0.1.0',
          ),
          supportPhone: $checkedConvert('support_phone', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'oidcIssuer': 'oidc_issuer',
        'stripePublishableKey': 'stripe_publishable_key',
        'minAppVersion': 'min_app_version',
        'supportPhone': 'support_phone',
      },
    );

Map<String, dynamic> _$PublicConfigToJson(PublicConfig instance) =>
    <String, dynamic>{
      'oidc_issuer': instance.oidcIssuer,
      'stripe_publishable_key': instance.stripePublishableKey,
      'min_app_version': ?instance.minAppVersion,
      'support_phone': ?instance.supportPhone,
    };
