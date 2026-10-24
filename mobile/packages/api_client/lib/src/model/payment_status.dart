//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum PaymentStatus {
  @JsonValue(r'pending')
  pending(r'pending'),
  @JsonValue(r'authorized')
  authorized(r'authorized'),
  @JsonValue(r'paid')
  paid(r'paid'),
  @JsonValue(r'refunded')
  refunded(r'refunded'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'cash_due')
  cashDue(r'cash_due'),
  @JsonValue(r'cash_collected')
  cashCollected(r'cash_collected');

  const PaymentStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
