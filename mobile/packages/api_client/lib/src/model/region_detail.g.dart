// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegionDetailCWProxy {
  RegionDetail id(String id);

  RegionDetail name(String name);

  RegionDetail teryt(String? teryt);

  RegionDetail timezone(String? timezone);

  RegionDetail active(bool active);

  RegionDetail area(Map<String, Object> area);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionDetail(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionDetail(...).copyWith(id: 12, name: "My name")
  /// ```
  RegionDetail call({
    String id,
    String name,
    String? teryt,
    String? timezone,
    bool active,
    Map<String, Object> area,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRegionDetail.copyWith(...)` or call `instanceOfRegionDetail.copyWith.fieldName(value)` for a single field.
class _$RegionDetailCWProxyImpl implements _$RegionDetailCWProxy {
  const _$RegionDetailCWProxyImpl(this._value);

  final RegionDetail _value;

  @override
  RegionDetail id(String id) => call(id: id);

  @override
  RegionDetail name(String name) => call(name: name);

  @override
  RegionDetail teryt(String? teryt) => call(teryt: teryt);

  @override
  RegionDetail timezone(String? timezone) => call(timezone: timezone);

  @override
  RegionDetail active(bool active) => call(active: active);

  @override
  RegionDetail area(Map<String, Object> area) => call(area: area);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RegionDetail(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RegionDetail(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RegionDetail call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? teryt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? active = const $CopyWithPlaceholder(),
    Object? area = const $CopyWithPlaceholder(),
  }) {
    return RegionDetail(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      teryt: teryt == const $CopyWithPlaceholder()
          ? _value.teryt
          // ignore: cast_nullable_to_non_nullable
          : teryt as String?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      active: active == const $CopyWithPlaceholder() || active == null
          ? _value.active
          // ignore: cast_nullable_to_non_nullable
          : active as bool,
      area: area == const $CopyWithPlaceholder() || area == null
          ? _value.area
          // ignore: cast_nullable_to_non_nullable
          : area as Map<String, Object>,
    );
  }
}

extension $RegionDetailCopyWith on RegionDetail {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRegionDetail.copyWith(...)` or `instanceOfRegionDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegionDetailCWProxy get copyWith => _$RegionDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionDetail _$RegionDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegionDetail', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'teryt', 'active', 'area'],
      );
      final val = RegionDetail(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        teryt: $checkedConvert('teryt', (v) => v as String?),
        timezone: $checkedConvert(
          'timezone',
          (v) => v as String? ?? 'Europe/Warsaw',
        ),
        active: $checkedConvert('active', (v) => v as bool),
        area: $checkedConvert(
          'area',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RegionDetailToJson(RegionDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teryt': instance.teryt,
      'timezone': ?instance.timezone,
      'active': instance.active,
      'area': instance.area,
    };
