// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RegionCWProxy {
  Region id(String id);

  Region name(String name);

  Region teryt(String? teryt);

  Region timezone(String? timezone);

  Region active(bool active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Region(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Region(...).copyWith(id: 12, name: "My name")
  /// ```
  Region call({
    String id,
    String name,
    String? teryt,
    String? timezone,
    bool active,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRegion.copyWith(...)` or call `instanceOfRegion.copyWith.fieldName(value)` for a single field.
class _$RegionCWProxyImpl implements _$RegionCWProxy {
  const _$RegionCWProxyImpl(this._value);

  final Region _value;

  @override
  Region id(String id) => call(id: id);

  @override
  Region name(String name) => call(name: name);

  @override
  Region teryt(String? teryt) => call(teryt: teryt);

  @override
  Region timezone(String? timezone) => call(timezone: timezone);

  @override
  Region active(bool active) => call(active: active);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Region(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Region(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Region call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? teryt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? active = const $CopyWithPlaceholder(),
  }) {
    return Region(
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
    );
  }
}

extension $RegionCopyWith on Region {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRegion.copyWith(...)` or `instanceOfRegion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RegionCWProxy get copyWith => _$RegionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Region', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'teryt', 'active']);
      final val = Region(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        teryt: $checkedConvert('teryt', (v) => v as String?),
        timezone: $checkedConvert(
          'timezone',
          (v) => v as String? ?? 'Europe/Warsaw',
        ),
        active: $checkedConvert('active', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'teryt': instance.teryt,
  'timezone': ?instance.timezone,
  'active': instance.active,
};
