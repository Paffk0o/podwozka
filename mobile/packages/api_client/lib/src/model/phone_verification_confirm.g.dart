// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_confirm.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PhoneVerificationConfirmCWProxy {
  PhoneVerificationConfirm code(String code);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PhoneVerificationConfirm(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PhoneVerificationConfirm(...).copyWith(id: 12, name: "My name")
  /// ```
  PhoneVerificationConfirm call({String code});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPhoneVerificationConfirm.copyWith(...)` or call `instanceOfPhoneVerificationConfirm.copyWith.fieldName(value)` for a single field.
class _$PhoneVerificationConfirmCWProxyImpl
    implements _$PhoneVerificationConfirmCWProxy {
  const _$PhoneVerificationConfirmCWProxyImpl(this._value);

  final PhoneVerificationConfirm _value;

  @override
  PhoneVerificationConfirm code(String code) => call(code: code);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PhoneVerificationConfirm(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PhoneVerificationConfirm(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  PhoneVerificationConfirm call({Object? code = const $CopyWithPlaceholder()}) {
    return PhoneVerificationConfirm(
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
    );
  }
}

extension $PhoneVerificationConfirmCopyWith on PhoneVerificationConfirm {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPhoneVerificationConfirm.copyWith(...)` or `instanceOfPhoneVerificationConfirm.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PhoneVerificationConfirmCWProxy get copyWith =>
      _$PhoneVerificationConfirmCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneVerificationConfirm _$PhoneVerificationConfirmFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PhoneVerificationConfirm', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code']);
  final val = PhoneVerificationConfirm(
    code: $checkedConvert('code', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PhoneVerificationConfirmToJson(
  PhoneVerificationConfirm instance,
) => <String, dynamic>{'code': instance.code};
