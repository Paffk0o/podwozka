// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuoteRequestCWProxy {
  QuoteRequest pickup(Place pickup);

  QuoteRequest destination(Place destination);

  QuoteRequest scheduledAt(DateTime? scheduledAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `QuoteRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// QuoteRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  QuoteRequest call({Place pickup, Place destination, DateTime? scheduledAt});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfQuoteRequest.copyWith(...)` or call `instanceOfQuoteRequest.copyWith.fieldName(value)` for a single field.
class _$QuoteRequestCWProxyImpl implements _$QuoteRequestCWProxy {
  const _$QuoteRequestCWProxyImpl(this._value);

  final QuoteRequest _value;

  @override
  QuoteRequest pickup(Place pickup) => call(pickup: pickup);

  @override
  QuoteRequest destination(Place destination) => call(destination: destination);

  @override
  QuoteRequest scheduledAt(DateTime? scheduledAt) =>
      call(scheduledAt: scheduledAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `QuoteRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// QuoteRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  QuoteRequest call({
    Object? pickup = const $CopyWithPlaceholder(),
    Object? destination = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
  }) {
    return QuoteRequest(
      pickup: pickup == const $CopyWithPlaceholder() || pickup == null
          ? _value.pickup
          // ignore: cast_nullable_to_non_nullable
          : pickup as Place,
      destination:
          destination == const $CopyWithPlaceholder() || destination == null
          ? _value.destination
          // ignore: cast_nullable_to_non_nullable
          : destination as Place,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime?,
    );
  }
}

extension $QuoteRequestCopyWith on QuoteRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfQuoteRequest.copyWith(...)` or `instanceOfQuoteRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuoteRequestCWProxy get copyWith => _$QuoteRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteRequest _$QuoteRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QuoteRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['pickup', 'destination']);
      final val = QuoteRequest(
        pickup: $checkedConvert(
          'pickup',
          (v) => Place.fromJson(v as Map<String, dynamic>),
        ),
        destination: $checkedConvert(
          'destination',
          (v) => Place.fromJson(v as Map<String, dynamic>),
        ),
        scheduledAt: $checkedConvert(
          'scheduled_at',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'scheduledAt': 'scheduled_at'});

Map<String, dynamic> _$QuoteRequestToJson(QuoteRequest instance) =>
    <String, dynamic>{
      'pickup': instance.pickup.toJson(),
      'destination': instance.destination.toJson(),
      'scheduled_at': ?instance.scheduledAt?.toIso8601String(),
    };
