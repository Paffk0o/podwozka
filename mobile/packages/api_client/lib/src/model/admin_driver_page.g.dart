// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_driver_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminDriverPageCWProxy {
  AdminDriverPage items(List<AdminDriver> items);

  AdminDriverPage total(int total);

  AdminDriverPage limit(int limit);

  AdminDriverPage offset(int offset);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AdminDriverPage(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AdminDriverPage(...).copyWith(id: 12, name: "My name")
  /// ```
  AdminDriverPage call({
    List<AdminDriver> items,
    int total,
    int limit,
    int offset,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAdminDriverPage.copyWith(...)` or call `instanceOfAdminDriverPage.copyWith.fieldName(value)` for a single field.
class _$AdminDriverPageCWProxyImpl implements _$AdminDriverPageCWProxy {
  const _$AdminDriverPageCWProxyImpl(this._value);

  final AdminDriverPage _value;

  @override
  AdminDriverPage items(List<AdminDriver> items) => call(items: items);

  @override
  AdminDriverPage total(int total) => call(total: total);

  @override
  AdminDriverPage limit(int limit) => call(limit: limit);

  @override
  AdminDriverPage offset(int offset) => call(offset: offset);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AdminDriverPage(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AdminDriverPage(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AdminDriverPage call({
    Object? items = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? limit = const $CopyWithPlaceholder(),
    Object? offset = const $CopyWithPlaceholder(),
  }) {
    return AdminDriverPage(
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<AdminDriver>,
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

extension $AdminDriverPageCopyWith on AdminDriverPage {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAdminDriverPage.copyWith(...)` or `instanceOfAdminDriverPage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminDriverPageCWProxy get copyWith => _$AdminDriverPageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDriverPage _$AdminDriverPageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdminDriverPage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['items', 'total', 'limit', 'offset'],
      );
      final val = AdminDriverPage(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => AdminDriver.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        limit: $checkedConvert('limit', (v) => (v as num).toInt()),
        offset: $checkedConvert('offset', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AdminDriverPageToJson(AdminDriverPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'limit': instance.limit,
      'offset': instance.offset,
    };
