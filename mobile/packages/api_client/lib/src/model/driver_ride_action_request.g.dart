// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_ride_action_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DriverRideActionRequestCWProxy {
  DriverRideActionRequest action(DriverRideAction action);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverRideActionRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverRideActionRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  DriverRideActionRequest call({DriverRideAction action});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDriverRideActionRequest.copyWith(...)` or call `instanceOfDriverRideActionRequest.copyWith.fieldName(value)` for a single field.
class _$DriverRideActionRequestCWProxyImpl
    implements _$DriverRideActionRequestCWProxy {
  const _$DriverRideActionRequestCWProxyImpl(this._value);

  final DriverRideActionRequest _value;

  @override
  DriverRideActionRequest action(DriverRideAction action) =>
      call(action: action);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverRideActionRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverRideActionRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DriverRideActionRequest call({
    Object? action = const $CopyWithPlaceholder(),
  }) {
    return DriverRideActionRequest(
      action: action == const $CopyWithPlaceholder() || action == null
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as DriverRideAction,
    );
  }
}

extension $DriverRideActionRequestCopyWith on DriverRideActionRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDriverRideActionRequest.copyWith(...)` or `instanceOfDriverRideActionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DriverRideActionRequestCWProxy get copyWith =>
      _$DriverRideActionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverRideActionRequest _$DriverRideActionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DriverRideActionRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['action']);
  final val = DriverRideActionRequest(
    action: $checkedConvert(
      'action',
      (v) => $enumDecode(_$DriverRideActionEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$DriverRideActionRequestToJson(
  DriverRideActionRequest instance,
) => <String, dynamic>{'action': _$DriverRideActionEnumMap[instance.action]!};

const _$DriverRideActionEnumMap = {
  DriverRideAction.depart: 'depart',
  DriverRideAction.arrived: 'arrived',
  DriverRideAction.start: 'start',
  DriverRideAction.complete: 'complete',
};
