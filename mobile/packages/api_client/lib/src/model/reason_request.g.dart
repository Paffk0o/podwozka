// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reason_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReasonRequestCWProxy {
  ReasonRequest reason(String reason);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReasonRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReasonRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  ReasonRequest call({String reason});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfReasonRequest.copyWith(...)` or call `instanceOfReasonRequest.copyWith.fieldName(value)` for a single field.
class _$ReasonRequestCWProxyImpl implements _$ReasonRequestCWProxy {
  const _$ReasonRequestCWProxyImpl(this._value);

  final ReasonRequest _value;

  @override
  ReasonRequest reason(String reason) => call(reason: reason);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ReasonRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ReasonRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ReasonRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return ReasonRequest(
      reason: reason == const $CopyWithPlaceholder() || reason == null
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $ReasonRequestCopyWith on ReasonRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfReasonRequest.copyWith(...)` or `instanceOfReasonRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReasonRequestCWProxy get copyWith => _$ReasonRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReasonRequest _$ReasonRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReasonRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reason']);
      final val = ReasonRequest(
        reason: $checkedConvert('reason', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReasonRequestToJson(ReasonRequest instance) =>
    <String, dynamic>{'reason': instance.reason};
