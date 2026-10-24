// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegionCreateCWProxy {
  RegionCreate name(String name);

  RegionCreate teryt(String? teryt);

  RegionCreate area(Map<String, Object> area);

  RegionCreate active(bool? active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  RegionCreate call({
    String name,
    String? teryt,
    Map<String, Object> area,
    bool? active,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRegionCreate.copyWith(...)` or call `instanceOfRegionCreate.copyWith.fieldName(value)` for a single field.
class _$RegionCreateCWProxyImpl implements _$RegionCreateCWProxy {
  const _$RegionCreateCWProxyImpl(this._value);

  final RegionCreate _value;

  @override
  RegionCreate name(String name) => call(name: name);

  @override
  RegionCreate teryt(String? teryt) => call(teryt: teryt);

  @override
  RegionCreate area(Map<String, Object> area) => call(area: area);

  @override
  RegionCreate active(bool? active) => call(active: active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RegionCreate call({
    Object? name = const $CopyWithPlaceholder(),
    Object? teryt = const $CopyWithPlaceholder(),
    Object? area = const $CopyWithPlaceholder(),
    Object? active = const $CopyWithPlaceholder(),
  }) {
    return RegionCreate(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      teryt: teryt == const $CopyWithPlaceholder()
          ? _value.teryt
          // ignore: cast_nullable_to_non_nullable
          : teryt as String?,
      area: area == const $CopyWithPlaceholder() || area == null
          ? _value.area
          // ignore: cast_nullable_to_non_nullable
          : area as Map<String, Object>,
      active: active == const $CopyWithPlaceholder()
          ? _value.active
          // ignore: cast_nullable_to_non_nullable
          : active as bool?,
    );
  }
}

extension $RegionCreateCopyWith on RegionCreate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRegionCreate.copyWith(...)` or `instanceOfRegionCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegionCreateCWProxy get copyWith => _$RegionCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionCreate _$RegionCreateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegionCreate', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'area']);
      final val = RegionCreate(
        name: $checkedConvert('name', (v) => v as String),
        teryt: $checkedConvert('teryt', (v) => v as String?),
        area: $checkedConvert(
          'area',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
        active: $checkedConvert('active', (v) => v as bool? ?? true),
      );
      return val;
    });

Map<String, dynamic> _$RegionCreateToJson(RegionCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'teryt': ?instance.teryt,
      'area': instance.area,
      'active': ?instance.active,
    };
