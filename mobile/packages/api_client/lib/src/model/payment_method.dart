//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// `card` covers cards and wallets (Apple Pay / Google Pay) in Stripe PaymentSheet.
enum PaymentMethod {
  @JsonValue(r'card')
  card(r'card'),
  @JsonValue(r'blik')
  blik(r'blik'),
  @JsonValue(r'cash')
  cash(r'cash');

  const PaymentMethod(this.value);

  final String value;

  @override
  String toString() => value;
}
