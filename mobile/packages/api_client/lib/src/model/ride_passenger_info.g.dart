// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_passenger_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RidePassengerInfoCWProxy {
  RidePassengerInfo id(String id);

  RidePassengerInfo fullName(String fullName);

  RidePassengerInfo phone(String? phone);

  RidePassengerInfo ratingAvg(num? ratingAvg);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RidePassengerInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RidePassengerInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  RidePassengerInfo call({
    String id,
    String fullName,
    String? phone,
    num? ratingAvg,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRidePassengerInfo.copyWith(...)` or call `instanceOfRidePassengerInfo.copyWith.fieldName(value)` for a single field.
class _$RidePassengerInfoCWProxyImpl implements _$RidePassengerInfoCWProxy {
  const _$RidePassengerInfoCWProxyImpl(this._value);

  final RidePassengerInfo _value;

  @override
  RidePassengerInfo id(String id) => call(id: id);

  @override
  RidePassengerInfo fullName(String fullName) => call(fullName: fullName);

  @override
  RidePassengerInfo phone(String? phone) => call(phone: phone);

  @override
  RidePassengerInfo ratingAvg(num? ratingAvg) => call(ratingAvg: ratingAvg);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RidePassengerInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RidePassengerInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RidePassengerInfo call({
    Object? id = const $CopyWithPlaceholder(),
    Object? fullName = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? ratingAvg = const $CopyWithPlaceholder(),
  }) {
    return RidePassengerInfo(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      fullName: fullName == const $CopyWithPlaceholder() || fullName == null
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      ratingAvg: ratingAvg == const $CopyWithPlaceholder()
          ? _value.ratingAvg
          // ignore: cast_nullable_to_non_nullable
          : ratingAvg as num?,
    );
  }
}

extension $RidePassengerInfoCopyWith on RidePassengerInfo {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRidePassengerInfo.copyWith(...)` or `instanceOfRidePassengerInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RidePassengerInfoCWProxy get copyWith =>
      _$RidePassengerInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RidePassengerInfo _$RidePassengerInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RidePassengerInfo', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'full_name', 'phone', 'rating_avg'],
      );
      final val = RidePassengerInfo(
        id: $checkedConvert('id', (v) => v as String),
        fullName: $checkedConvert('full_name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String?),
        ratingAvg: $checkedConvert('rating_avg', (v) => v as num?),
      );
      return val;
    }, fieldKeyMap: const {'fullName': 'full_name', 'ratingAvg': 'rating_avg'});

Map<String, dynamic> _$RidePassengerInfoToJson(RidePassengerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'rating_avg': instance.ratingAvg,
    };
