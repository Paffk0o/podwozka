// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_driver_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RideDriverInfoCWProxy {
  RideDriverInfo id(String id);

  RideDriverInfo fullName(String fullName);

  RideDriverInfo phone(String? phone);

  RideDriverInfo ratingAvg(num? ratingAvg);

  RideDriverInfo vehicle(Vehicle vehicle);

  RideDriverInfo location(GeoPoint? location);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideDriverInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideDriverInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  RideDriverInfo call({
    String id,
    String fullName,
    String? phone,
    num? ratingAvg,
    Vehicle vehicle,
    GeoPoint? location,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRideDriverInfo.copyWith(...)` or call `instanceOfRideDriverInfo.copyWith.fieldName(value)` for a single field.
class _$RideDriverInfoCWProxyImpl implements _$RideDriverInfoCWProxy {
  const _$RideDriverInfoCWProxyImpl(this._value);

  final RideDriverInfo _value;

  @override
  RideDriverInfo id(String id) => call(id: id);

  @override
  RideDriverInfo fullName(String fullName) => call(fullName: fullName);

  @override
  RideDriverInfo phone(String? phone) => call(phone: phone);

  @override
  RideDriverInfo ratingAvg(num? ratingAvg) => call(ratingAvg: ratingAvg);

  @override
  RideDriverInfo vehicle(Vehicle vehicle) => call(vehicle: vehicle);

  @override
  RideDriverInfo location(GeoPoint? location) => call(location: location);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideDriverInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideDriverInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RideDriverInfo call({
    Object? id = const $CopyWithPlaceholder(),
    Object? fullName = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? ratingAvg = const $CopyWithPlaceholder(),
    Object? vehicle = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
  }) {
    return RideDriverInfo(
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
      vehicle: vehicle == const $CopyWithPlaceholder() || vehicle == null
          ? _value.vehicle
          // ignore: cast_nullable_to_non_nullable
          : vehicle as Vehicle,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as GeoPoint?,
    );
  }
}

extension $RideDriverInfoCopyWith on RideDriverInfo {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRideDriverInfo.copyWith(...)` or `instanceOfRideDriverInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RideDriverInfoCWProxy get copyWith => _$RideDriverInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideDriverInfo _$RideDriverInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RideDriverInfo', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'full_name',
          'phone',
          'rating_avg',
          'vehicle',
          'location',
        ],
      );
      final val = RideDriverInfo(
        id: $checkedConvert('id', (v) => v as String),
        fullName: $checkedConvert('full_name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String?),
        ratingAvg: $checkedConvert('rating_avg', (v) => v as num?),
        vehicle: $checkedConvert(
          'vehicle',
          (v) => Vehicle.fromJson(v as Map<String, dynamic>),
        ),
        location: $checkedConvert(
          'location',
          (v) =>
              v == null ? null : GeoPoint.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'fullName': 'full_name', 'ratingAvg': 'rating_avg'});

Map<String, dynamic> _$RideDriverInfoToJson(RideDriverInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'rating_avg': instance.ratingAvg,
      'vehicle': instance.vehicle.toJson(),
      'location': instance.location?.toJson(),
    };
