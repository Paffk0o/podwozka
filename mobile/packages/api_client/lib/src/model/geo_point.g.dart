// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeoPointCWProxy {
  GeoPoint lat(num lat);

  GeoPoint lng(num lng);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `GeoPoint(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GeoPoint(...).copyWith(id: 12, name: "My name")
  /// ```
  GeoPoint call({num lat, num lng});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGeoPoint.copyWith(...)` or call `instanceOfGeoPoint.copyWith.fieldName(value)` for a single field.
class _$GeoPointCWProxyImpl implements _$GeoPointCWProxy {
  const _$GeoPointCWProxyImpl(this._value);

  final GeoPoint _value;

  @override
  GeoPoint lat(num lat) => call(lat: lat);

  @override
  GeoPoint lng(num lng) => call(lng: lng);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `GeoPoint(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GeoPoint(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  GeoPoint call({
    Object? lat = const $CopyWithPlaceholder(),
    Object? lng = const $CopyWithPlaceholder(),
  }) {
    return GeoPoint(
      lat: lat == const $CopyWithPlaceholder() || lat == null
          ? _value.lat
          // ignore: cast_nullable_to_non_nullable
          : lat as num,
      lng: lng == const $CopyWithPlaceholder() || lng == null
          ? _value.lng
          // ignore: cast_nullable_to_non_nullable
          : lng as num,
    );
  }
}

extension $GeoPointCopyWith on GeoPoint {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGeoPoint.copyWith(...)` or `instanceOfGeoPoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeoPointCWProxy get copyWith => _$GeoPointCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GeoPoint', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['lat', 'lng']);
      final val = GeoPoint(
        lat: $checkedConvert('lat', (v) => v as num),
        lng: $checkedConvert('lng', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$GeoPointToJson(GeoPoint instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};
