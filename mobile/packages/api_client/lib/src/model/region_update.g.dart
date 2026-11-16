// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegionUpdateCWProxy {
  RegionUpdate name(String? name);

  RegionUpdate area(Map<String, Object>? area);

  RegionUpdate active(bool? active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionUpdate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionUpdate(...).copyWith(id: 12, name: "My name")
  /// ```
  RegionUpdate call({String? name, Map<String, Object>? area, bool? active});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRegionUpdate.copyWith(...)` or call `instanceOfRegionUpdate.copyWith.fieldName(value)` for a single field.
class _$RegionUpdateCWProxyImpl implements _$RegionUpdateCWProxy {
  const _$RegionUpdateCWProxyImpl(this._value);

  final RegionUpdate _value;

  @override
  RegionUpdate name(String? name) => call(name: name);

  @override
  RegionUpdate area(Map<String, Object>? area) => call(area: area);

  @override
  RegionUpdate active(bool? active) => call(active: active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionUpdate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionUpdate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RegionUpdate call({
    Object? name = const $CopyWithPlaceholder(),
    Object? area = const $CopyWithPlaceholder(),
    Object? active = const $CopyWithPlaceholder(),
  }) {
    return RegionUpdate(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      area: area == const $CopyWithPlaceholder()
          ? _value.area
          // ignore: cast_nullable_to_non_nullable
          : area as Map<String, Object>?,
      active: active == const $CopyWithPlaceholder()
          ? _value.active
          // ignore: cast_nullable_to_non_nullable
          : active as bool?,
    );
  }
}

extension $RegionUpdateCopyWith on RegionUpdate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRegionUpdate.copyWith(...)` or `instanceOfRegionUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegionUpdateCWProxy get copyWith => _$RegionUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionUpdate _$RegionUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegionUpdate', json, ($checkedConvert) {
      final val = RegionUpdate(
        name: $checkedConvert('name', (v) => v as String?),
        area: $checkedConvert(
          'area',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        active: $checkedConvert('active', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$RegionUpdateToJson(RegionUpdate instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'area': ?instance.area,
      'active': ?instance.active,
    };
