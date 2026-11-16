// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeCWProxy {
  Me id(String id);

  Me email(String? email);

  Me fullName(String? fullName);

  Me phone(String? phone);

  Me phoneVerified(bool phoneVerified);

  Me roles(List<String> roles);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Me(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ```
  Me call({
    String id,
    String? email,
    String? fullName,
    String? phone,
    bool phoneVerified,
    List<String> roles,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMe.copyWith(...)` or call `instanceOfMe.copyWith.fieldName(value)` for a single field.
class _$MeCWProxyImpl implements _$MeCWProxy {
  const _$MeCWProxyImpl(this._value);

  final Me _value;

  @override
  Me id(String id) => call(id: id);

  @override
  Me email(String? email) => call(email: email);

  @override
  Me fullName(String? fullName) => call(fullName: fullName);

  @override
  Me phone(String? phone) => call(phone: phone);

  @override
  Me phoneVerified(bool phoneVerified) => call(phoneVerified: phoneVerified);

  @override
  Me roles(List<String> roles) => call(roles: roles);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Me(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Me(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Me call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? fullName = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? phoneVerified = const $CopyWithPlaceholder(),
    Object? roles = const $CopyWithPlaceholder(),
  }) {
    return Me(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      fullName: fullName == const $CopyWithPlaceholder()
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      phoneVerified:
          phoneVerified == const $CopyWithPlaceholder() || phoneVerified == null
          ? _value.phoneVerified
          // ignore: cast_nullable_to_non_nullable
          : phoneVerified as bool,
      roles: roles == const $CopyWithPlaceholder() || roles == null
          ? _value.roles
          // ignore: cast_nullable_to_non_nullable
          : roles as List<String>,
    );
  }
}

extension $MeCopyWith on Me {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMe.copyWith(...)` or `instanceOfMe.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeCWProxy get copyWith => _$MeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Me _$MeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Me',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'email',
        'full_name',
        'phone',
        'phone_verified',
        'roles',
      ],
    );
    final val = Me(
      id: $checkedConvert('id', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String?),
      fullName: $checkedConvert('full_name', (v) => v as String?),
      phone: $checkedConvert('phone', (v) => v as String?),
      phoneVerified: $checkedConvert('phone_verified', (v) => v as bool),
      roles: $checkedConvert(
        'roles',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'fullName': 'full_name',
    'phoneVerified': 'phone_verified',
  },
);

Map<String, dynamic> _$MeToJson(Me instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'phone_verified': instance.phoneVerified,
  'roles': instance.roles,
};
