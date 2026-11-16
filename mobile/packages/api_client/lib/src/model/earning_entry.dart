//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/payment_method.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'earning_entry.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EarningEntry {
  /// Returns a new [EarningEntry] instance.
  EarningEntry({
    required this.rideId,

    required this.completedAt,

    required this.paymentMethod,

    required this.gross,

    required this.commission,

    required this.net,
  });

  @JsonKey(name: r'ride_id', required: true, includeIfNull: false)
  final String rideId;

  @JsonKey(name: r'completed_at', required: true, includeIfNull: false)
  final DateTime completedAt;

  @JsonKey(name: r'payment_method', required: true, includeIfNull: false)
  final PaymentMethod paymentMethod;

  /// Kwota w groszach (1 PLN = 100)
  // minimum: 0
  @JsonKey(name: r'gross', required: true, includeIfNull: false)
  final int gross;

  /// Kwota w groszach (1 PLN = 100)
  // minimum: 0
  @JsonKey(name: r'commission', required: true, includeIfNull: false)
  final int commission;

  /// Kwota w groszach (1 PLN = 100)
  // minimum: 0
  @JsonKey(name: r'net', required: true, includeIfNull: false)
  final int net;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarningEntry &&
          other.rideId == rideId &&
          other.completedAt == completedAt &&
          other.paymentMethod == paymentMethod &&
          other.gross == gross &&
          other.commission == commission &&
          other.net == net;

  @override
  int get hashCode =>
      rideId.hashCode +
      completedAt.hashCode +
      paymentMethod.hashCode +
      gross.hashCode +
      commission.hashCode +
      net.hashCode;

  factory EarningEntry.fromJson(Map<String, dynamic> json) =>
      _$EarningEntryFromJson(json);

  Map<String, dynamic> toJson() => _$EarningEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
