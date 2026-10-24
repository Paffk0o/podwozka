// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PhoneVerificationRequestCWProxy {
  PhoneVerificationRequest phone(String phone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PhoneVerificationRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PhoneVerificationRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  PhoneVerificationRequest call({String phone});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPhoneVerificationRequest.copyWith(...)` or call `instanceOfPhoneVerificationRequest.copyWith.fieldName(value)` for a single field.
class _$PhoneVerificationRequestCWProxyImpl
    implements _$PhoneVerificationRequestCWProxy {
  const _$PhoneVerificationRequestCWProxyImpl(this._value);

  final PhoneVerificationRequest _value;

  @override
  PhoneVerificationRequest phone(String phone) => call(phone: phone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PhoneVerificationRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PhoneVerificationRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  PhoneVerificationRequest call({
    Object? phone = const $CopyWithPlaceholder(),
  }) {
    return PhoneVerificationRequest(
      phone: phone == const $CopyWithPlaceholder() || phone == null
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
    );
  }
}

extension $PhoneVerificationRequestCopyWith on PhoneVerificationRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPhoneVerificationRequest.copyWith(...)` or `instanceOfPhoneVerificationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PhoneVerificationRequestCWProxy get copyWith =>
      _$PhoneVerificationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneVerificationRequest _$PhoneVerificationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PhoneVerificationRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['phone']);
  final val = PhoneVerificationRequest(
    phone: $checkedConvert('phone', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PhoneVerificationRequestToJson(
  PhoneVerificationRequest instance,
) => <String, dynamic>{'phone': instance.phone};
