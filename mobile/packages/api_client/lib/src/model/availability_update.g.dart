// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AvailabilityUpdateCWProxy {
  AvailabilityUpdate online(bool online);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AvailabilityUpdate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AvailabilityUpdate(...).copyWith(id: 12, name: "My name")
  /// ```
  AvailabilityUpdate call({bool online});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAvailabilityUpdate.copyWith(...)` or call `instanceOfAvailabilityUpdate.copyWith.fieldName(value)` for a single field.
class _$AvailabilityUpdateCWProxyImpl implements _$AvailabilityUpdateCWProxy {
  const _$AvailabilityUpdateCWProxyImpl(this._value);

  final AvailabilityUpdate _value;

  @override
  AvailabilityUpdate online(bool online) => call(online: online);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AvailabilityUpdate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AvailabilityUpdate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AvailabilityUpdate call({Object? online = const $CopyWithPlaceholder()}) {
    return AvailabilityUpdate(
      online: online == const $CopyWithPlaceholder() || online == null
          ? _value.online
          // ignore: cast_nullable_to_non_nullable
          : online as bool,
    );
  }
}

extension $AvailabilityUpdateCopyWith on AvailabilityUpdate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAvailabilityUpdate.copyWith(...)` or `instanceOfAvailabilityUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AvailabilityUpdateCWProxy get copyWith =>
      _$AvailabilityUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityUpdate _$AvailabilityUpdateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AvailabilityUpdate', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['online']);
      final val = AvailabilityUpdate(
        online: $checkedConvert('online', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$AvailabilityUpdateToJson(AvailabilityUpdate instance) =>
    <String, dynamic>{'online': instance.online};
