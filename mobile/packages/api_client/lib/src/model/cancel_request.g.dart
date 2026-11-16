// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CancelRequestCWProxy {
  CancelRequest reason(String? reason);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `CancelRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CancelRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  CancelRequest call({String? reason});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCancelRequest.copyWith(...)` or call `instanceOfCancelRequest.copyWith.fieldName(value)` for a single field.
class _$CancelRequestCWProxyImpl implements _$CancelRequestCWProxy {
  const _$CancelRequestCWProxyImpl(this._value);

  final CancelRequest _value;

  @override
  CancelRequest reason(String? reason) => call(reason: reason);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `CancelRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CancelRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  CancelRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return CancelRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
    );
  }
}

extension $CancelRequestCopyWith on CancelRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCancelRequest.copyWith(...)` or `instanceOfCancelRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CancelRequestCWProxy get copyWith => _$CancelRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelRequest _$CancelRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CancelRequest', json, ($checkedConvert) {
      final val = CancelRequest(
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CancelRequestToJson(CancelRequest instance) =>
    <String, dynamic>{'reason': ?instance.reason};
