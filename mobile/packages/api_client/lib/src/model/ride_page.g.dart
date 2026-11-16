// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RidePageCWProxy {
  RidePage items(List<Ride> items);

  RidePage total(int total);

  RidePage limit(int limit);

  RidePage offset(int offset);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RidePage(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RidePage(...).copyWith(id: 12, name: "My name")
  /// ```
  RidePage call({List<Ride> items, int total, int limit, int offset});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRidePage.copyWith(...)` or call `instanceOfRidePage.copyWith.fieldName(value)` for a single field.
class _$RidePageCWProxyImpl implements _$RidePageCWProxy {
  const _$RidePageCWProxyImpl(this._value);

  final RidePage _value;

  @override
  RidePage items(List<Ride> items) => call(items: items);

  @override
  RidePage total(int total) => call(total: total);

  @override
  RidePage limit(int limit) => call(limit: limit);

  @override
  RidePage offset(int offset) => call(offset: offset);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RidePage(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RidePage(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RidePage call({
    Object? items = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
    Object? offset = const $CopyWithPlaceholder(),
  }) {
    return RidePage(
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Ride>,
      total: total == const $CopyWithPlaceholder() || total == null
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      limit: limit == const $CopyWithPlaceholder() || limit == null
          ? _value.limit
          // ignore: cast_nullable_to_non_nullable
          : limit as int,
      offset: offset == const $CopyWithPlaceholder() || offset == null
          ? _value.offset
          // ignore: cast_nullable_to_non_nullable
          : offset as int,
    );
  }
}

extension $RidePageCopyWith on RidePage {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRidePage.copyWith(...)` or `instanceOfRidePage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RidePageCWProxy get copyWith => _$RidePageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RidePage _$RidePageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RidePage',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['items', 'total', 'limit', 'offset']);
    final val = RidePage(
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      total: $checkedConvert('total', (v) => (v as num).toInt()),
      limit: $checkedConvert('limit', (v) => (v as num).toInt()),
      offset: $checkedConvert('offset', (v) => (v as num).toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$RidePageToJson(RidePage instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
};
