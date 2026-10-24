// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_url.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SignedUrlCWProxy {
  SignedUrl url(String url);

  SignedUrl expiresAt(DateTime expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SignedUrl(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SignedUrl(...).copyWith(id: 12, name: "My name")
  /// ```
  SignedUrl call({String url, DateTime expiresAt});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSignedUrl.copyWith(...)` or call `instanceOfSignedUrl.copyWith.fieldName(value)` for a single field.
class _$SignedUrlCWProxyImpl implements _$SignedUrlCWProxy {
  const _$SignedUrlCWProxyImpl(this._value);

  final SignedUrl _value;

  @override
  SignedUrl url(String url) => call(url: url);

  @override
  SignedUrl expiresAt(DateTime expiresAt) => call(expiresAt: expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SignedUrl(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SignedUrl(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  SignedUrl call({
    Object? url = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return SignedUrl(
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $SignedUrlCopyWith on SignedUrl {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSignedUrl.copyWith(...)` or `instanceOfSignedUrl.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SignedUrlCWProxy get copyWith => _$SignedUrlCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignedUrl _$SignedUrlFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SignedUrl', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['url', 'expires_at']);
      final val = SignedUrl(
        url: $checkedConvert('url', (v) => v as String),
        expiresAt: $checkedConvert(
          'expires_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'expiresAt': 'expires_at'});

Map<String, dynamic> _$SignedUrlToJson(SignedUrl instance) => <String, dynamic>{
  'url': instance.url,
  'expires_at': instance.expiresAt.toIso8601String(),
};
