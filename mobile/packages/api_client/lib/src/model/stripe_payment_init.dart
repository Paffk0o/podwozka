//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stripe_payment_init.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StripePaymentInit {
  /// Returns a new [StripePaymentInit] instance.
  StripePaymentInit({
    required this.paymentIntentId,

    required this.clientSecret,

    required this.customerId,

    required this.ephemeralKeySecret,

    required this.publishableKey,
  });

  @JsonKey(name: r'payment_intent_id', required: true, includeIfNull: false)
  final String paymentIntentId;

  @JsonKey(name: r'client_secret', required: true, includeIfNull: false)
  final String clientSecret;

  @JsonKey(name: r'customer_id', required: true, includeIfNull: true)
  final String? customerId;

  @JsonKey(name: r'ephemeral_key_secret', required: true, includeIfNull: true)
  final String? ephemeralKeySecret;

  @JsonKey(name: r'publishable_key', required: true, includeIfNull: false)
  final String publishableKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StripePaymentInit &&
          other.paymentIntentId == paymentIntentId &&
          other.clientSecret == clientSecret &&
          other.customerId == customerId &&
          other.ephemeralKeySecret == ephemeralKeySecret &&
          other.publishableKey == publishableKey;

  @override
  int get hashCode =>
      paymentIntentId.hashCode +
      clientSecret.hashCode +
      (customerId == null ? 0 : customerId.hashCode) +
      (ephemeralKeySecret == null ? 0 : ephemeralKeySecret.hashCode) +
      publishableKey.hashCode;

  factory StripePaymentInit.fromJson(Map<String, dynamic> json) =>
      _$StripePaymentInitFromJson(json);

  Map<String, dynamic> toJson() => _$StripePaymentInitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
