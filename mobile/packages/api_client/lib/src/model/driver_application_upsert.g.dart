// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_application_upsert.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DriverApplicationUpsertCWProxy {
  DriverApplicationUpsert regionId(String regionId);

  DriverApplicationUpsert vehicle(Vehicle vehicle);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverApplicationUpsert(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverApplicationUpsert(...).copyWith(id: 12, name: "My name")
  /// ```
  DriverApplicationUpsert call({String regionId, Vehicle vehicle});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDriverApplicationUpsert.copyWith(...)` or call `instanceOfDriverApplicationUpsert.copyWith.fieldName(value)` for a single field.
class _$DriverApplicationUpsertCWProxyImpl
    implements _$DriverApplicationUpsertCWProxy {
  const _$DriverApplicationUpsertCWProxyImpl(this._value);

  final DriverApplicationUpsert _value;

  @override
  DriverApplicationUpsert regionId(String regionId) => call(regionId: regionId);

  @override
  DriverApplicationUpsert vehicle(Vehicle vehicle) => call(vehicle: vehicle);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverApplicationUpsert(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverApplicationUpsert(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DriverApplicationUpsert call({
    Object? regionId = const $CopyWithPlaceholder(),
    Object? vehicle = const $CopyWithPlaceholder(),
  }) {
    return DriverApplicationUpsert(
      regionId: regionId == const $CopyWithPlaceholder() || regionId == null
          ? _value.regionId
          // ignore: cast_nullable_to_non_nullable
          : regionId as String,
      vehicle: vehicle == const $CopyWithPlaceholder() || vehicle == null
          ? _value.vehicle
          // ignore: cast_nullable_to_non_nullable
          : vehicle as Vehicle,
    );
  }
}

extension $DriverApplicationUpsertCopyWith on DriverApplicationUpsert {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDriverApplicationUpsert.copyWith(...)` or `instanceOfDriverApplicationUpsert.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DriverApplicationUpsertCWProxy get copyWith =>
      _$DriverApplicationUpsertCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverApplicationUpsert _$DriverApplicationUpsertFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DriverApplicationUpsert', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['region_id', 'vehicle']);
  final val = DriverApplicationUpsert(
    regionId: $checkedConvert('region_id', (v) => v as String),
    vehicle: $checkedConvert(
      'vehicle',
      (v) => Vehicle.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'regionId': 'region_id'});

Map<String, dynamic> _$DriverApplicationUpsertToJson(
  DriverApplicationUpsert instance,
) => <String, dynamic>{
  'region_id': instance.regionId,
  'vehicle': instance.vehicle.toJson(),
};
