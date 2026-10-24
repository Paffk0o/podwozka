//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/payment_method.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RideCreate {
  /// Returns a new [RideCreate] instance.
  RideCreate({
    required this.quoteId,

    required this.paymentMethod,

    this.passengerNote,
  });

  @JsonKey(name: r'quote_id', required: true, includeIfNull: false)
  final String quoteId;

  @JsonKey(name: r'payment_method', required: true, includeIfNull: false)
  final PaymentMethod paymentMethod;

  @JsonKey(name: r'passenger_note', required: false, includeIfNull: false)
  final String? passengerNote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideCreate &&
          other.quoteId == quoteId &&
          other.paymentMethod == paymentMethod &&
          other.passengerNote == passengerNote;

  @override
  int get hashCode =>
      quoteId.hashCode +
      paymentMethod.hashCode +
      (passengerNote == null ? 0 : passengerNote.hashCode);

  factory RideCreate.fromJson(Map<String, dynamic> json) =>
      _$RideCreateFromJson(json);

  Map<String, dynamic> toJson() => _$RideCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
