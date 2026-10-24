// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaceCWProxy {
  Place location(GeoPoint location);

  Place address(String address);

  Place placeId(String? placeId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Place(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Place(...).copyWith(id: 12, name: "My name")
  /// ```
  Place call({GeoPoint location, String address, String? placeId});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPlace.copyWith(...)` or call `instanceOfPlace.copyWith.fieldName(value)` for a single field.
class _$PlaceCWProxyImpl implements _$PlaceCWProxy {
  const _$PlaceCWProxyImpl(this._value);

  final Place _value;

  @override
  Place location(GeoPoint location) => call(location: location);

  @override
  Place address(String address) => call(address: address);

  @override
  Place placeId(String? placeId) => call(placeId: placeId);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Place(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Place(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Place call({
    Object? location = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? placeId = const $CopyWithPlaceholder(),
  }) {
    return Place(
      location: location == const $CopyWithPlaceholder() || location == null
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as GeoPoint,
      address: address == const $CopyWithPlaceholder() || address == null
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String,
      placeId: placeId == const $CopyWithPlaceholder()
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String?,
    );
  }
}

extension $PlaceCopyWith on Place {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPlace.copyWith(...)` or `instanceOfPlace.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaceCWProxy get copyWith => _$PlaceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Place', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['location', 'address']);
      final val = Place(
        location: $checkedConvert(
          'location',
          (v) => GeoPoint.fromJson(v as Map<String, dynamic>),
        ),
        address: $checkedConvert('address', (v) => v as String),
        placeId: $checkedConvert('place_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'placeId': 'place_id'});

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
  'location': instance.location.toJson(),
  'address': instance.address,
  'place_id': ?instance.placeId,
};
