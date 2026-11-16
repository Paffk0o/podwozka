// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_upsert.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeUpsertCWProxy {
  MeUpsert fullName(String? fullName);

  MeUpsert phone(String? phone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MeUpsert(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MeUpsert(...).copyWith(id: 12, name: "My name")
  /// ```
  MeUpsert call({String? fullName, String? phone});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMeUpsert.copyWith(...)` or call `instanceOfMeUpsert.copyWith.fieldName(value)` for a single field.
class _$MeUpsertCWProxyImpl implements _$MeUpsertCWProxy {
  const _$MeUpsertCWProxyImpl(this._value);

  final MeUpsert _value;

  @override
  MeUpsert fullName(String? fullName) => call(fullName: fullName);

  @override
  MeUpsert phone(String? phone) => call(phone: phone);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MeUpsert(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MeUpsert(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MeUpsert call({
    Object? fullName = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
  }) {
    return MeUpsert(
      fullName: fullName == const $CopyWithPlaceholder()
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
    );
  }
}

extension $MeUpsertCopyWith on MeUpsert {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMeUpsert.copyWith(...)` or `instanceOfMeUpsert.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeUpsertCWProxy get copyWith => _$MeUpsertCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeUpsert _$MeUpsertFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeUpsert', json, ($checkedConvert) {
      final val = MeUpsert(
        fullName: $checkedConvert('full_name', (v) => v as String?),
        phone: $checkedConvert('phone', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'fullName': 'full_name'});

Map<String, dynamic> _$MeUpsertToJson(MeUpsert instance) => <String, dynamic>{
  'full_name': ?instance.fullName,
  'phone': ?instance.phone,
};
