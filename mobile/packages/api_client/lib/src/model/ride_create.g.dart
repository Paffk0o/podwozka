// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RideCreateCWProxy {
  RideCreate quoteId(String quoteId);

  RideCreate paymentMethod(PaymentMethod paymentMethod);

  RideCreate passengerNote(String? passengerNote);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  RideCreate call({
    String quoteId,
    PaymentMethod paymentMethod,
    String? passengerNote,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRideCreate.copyWith(...)` or call `instanceOfRideCreate.copyWith.fieldName(value)` for a single field.
class _$RideCreateCWProxyImpl implements _$RideCreateCWProxy {
  const _$RideCreateCWProxyImpl(this._value);

  final RideCreate _value;

  @override
  RideCreate quoteId(String quoteId) => call(quoteId: quoteId);

  @override
  RideCreate paymentMethod(PaymentMethod paymentMethod) =>
      call(paymentMethod: paymentMethod);

  @override
  RideCreate passengerNote(String? passengerNote) =>
      call(passengerNote: passengerNote);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RideCreate call({
    Object? quoteId = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? passengerNote = const $CopyWithPlaceholder(),
  }) {
    return RideCreate(
      quoteId: quoteId == const $CopyWithPlaceholder() || quoteId == null
          ? _value.quoteId
          // ignore: cast_nullable_to_non_nullable
          : quoteId as String,
      paymentMethod:
          paymentMethod == const $CopyWithPlaceholder() || paymentMethod == null
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as PaymentMethod,
      passengerNote: passengerNote == const $CopyWithPlaceholder()
          ? _value.passengerNote
          // ignore: cast_nullable_to_non_nullable
          : passengerNote as String?,
    );
  }
}

extension $RideCreateCopyWith on RideCreate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRideCreate.copyWith(...)` or `instanceOfRideCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RideCreateCWProxy get copyWith => _$RideCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideCreate _$RideCreateFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RideCreate',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['quote_id', 'payment_method']);
    final val = RideCreate(
      quoteId: $checkedConvert('quote_id', (v) => v as String),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) => $enumDecode(_$PaymentMethodEnumMap, v),
      ),
      passengerNote: $checkedConvert('passenger_note', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'quoteId': 'quote_id',
    'paymentMethod': 'payment_method',
    'passengerNote': 'passenger_note',
  },
);

Map<String, dynamic> _$RideCreateToJson(RideCreate instance) =>
    <String, dynamic>{
      'quote_id': instance.quoteId,
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'passenger_note': ?instance.passengerNote,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.card: 'card',
  PaymentMethod.blik: 'blik',
  PaymentMethod.cash: 'cash',
};
