// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stripe_payment_init.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StripePaymentInitCWProxy {
  StripePaymentInit paymentIntentId(String paymentIntentId);

  StripePaymentInit clientSecret(String clientSecret);

  StripePaymentInit customerId(String? customerId);

  StripePaymentInit ephemeralKeySecret(String? ephemeralKeySecret);

  StripePaymentInit publishableKey(String publishableKey);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `StripePaymentInit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StripePaymentInit(...).copyWith(id: 12, name: "My name")
  /// ```
  StripePaymentInit call({
    String paymentIntentId,
    String clientSecret,
    String? customerId,
    String? ephemeralKeySecret,
    String publishableKey,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStripePaymentInit.copyWith(...)` or call `instanceOfStripePaymentInit.copyWith.fieldName(value)` for a single field.
class _$StripePaymentInitCWProxyImpl implements _$StripePaymentInitCWProxy {
  const _$StripePaymentInitCWProxyImpl(this._value);

  final StripePaymentInit _value;

  @override
  StripePaymentInit paymentIntentId(String paymentIntentId) =>
      call(paymentIntentId: paymentIntentId);

  @override
  StripePaymentInit clientSecret(String clientSecret) =>
      call(clientSecret: clientSecret);

  @override
  StripePaymentInit customerId(String? customerId) =>
      call(customerId: customerId);

  @override
  StripePaymentInit ephemeralKeySecret(String? ephemeralKeySecret) =>
      call(ephemeralKeySecret: ephemeralKeySecret);

  @override
  StripePaymentInit publishableKey(String publishableKey) =>
      call(publishableKey: publishableKey);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `StripePaymentInit(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StripePaymentInit(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  StripePaymentInit call({
    Object? paymentIntentId = const $CopyWithPlaceholder(),
    Object? clientSecret = const $CopyWithPlaceholder(),
    Object? customerId = const $CopyWithPlaceholder(),
    Object? ephemeralKeySecret = const $CopyWithPlaceholder(),
    Object? publishableKey = const $CopyWithPlaceholder(),
  }) {
    return StripePaymentInit(
      paymentIntentId:
          paymentIntentId == const $CopyWithPlaceholder() ||
              paymentIntentId == null
          ? _value.paymentIntentId
          // ignore: cast_nullable_to_non_nullable
          : paymentIntentId as String,
      clientSecret:
          clientSecret == const $CopyWithPlaceholder() || clientSecret == null
          ? _value.clientSecret
          // ignore: cast_nullable_to_non_nullable
          : clientSecret as String,
      customerId: customerId == const $CopyWithPlaceholder()
          ? _value.customerId
          // ignore: cast_nullable_to_non_nullable
          : customerId as String?,
      ephemeralKeySecret: ephemeralKeySecret == const $CopyWithPlaceholder()
          ? _value.ephemeralKeySecret
          // ignore: cast_nullable_to_non_nullable
          : ephemeralKeySecret as String?,
      publishableKey:
          publishableKey == const $CopyWithPlaceholder() ||
              publishableKey == null
          ? _value.publishableKey
          // ignore: cast_nullable_to_non_nullable
          : publishableKey as String,
    );
  }
}

extension $StripePaymentInitCopyWith on StripePaymentInit {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStripePaymentInit.copyWith(...)` or `instanceOfStripePaymentInit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StripePaymentInitCWProxy get copyWith =>
      _$StripePaymentInitCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StripePaymentInit _$StripePaymentInitFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StripePaymentInit',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'payment_intent_id',
        'client_secret',
        'customer_id',
        'ephemeral_key_secret',
        'publishable_key',
      ],
    );
    final val = StripePaymentInit(
      paymentIntentId: $checkedConvert('payment_intent_id', (v) => v as String),
      clientSecret: $checkedConvert('client_secret', (v) => v as String),
      customerId: $checkedConvert('customer_id', (v) => v as String?),
      ephemeralKeySecret: $checkedConvert(
        'ephemeral_key_secret',
        (v) => v as String?,
      ),
      publishableKey: $checkedConvert('publishable_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'paymentIntentId': 'payment_intent_id',
    'clientSecret': 'client_secret',
    'customerId': 'customer_id',
    'ephemeralKeySecret': 'ephemeral_key_secret',
    'publishableKey': 'publishable_key',
  },
);

Map<String, dynamic> _$StripePaymentInitToJson(StripePaymentInit instance) =>
    <String, dynamic>{
      'payment_intent_id': instance.paymentIntentId,
      'client_secret': instance.clientSecret,
      'customer_id': instance.customerId,
      'ephemeral_key_secret': instance.ephemeralKeySecret,
      'publishable_key': instance.publishableKey,
    };
