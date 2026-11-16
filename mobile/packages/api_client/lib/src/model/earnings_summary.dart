//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/earning_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'earnings_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EarningsSummary {
  /// Returns a new [EarningsSummary] instance.
  EarningsSummary({
    required this.dateFrom,

    required this.dateTo,

    required this.ridesCount,

    required this.gross,

    required this.commission,

    required this.net,

    required this.cashCollected,

    required this.commissionDueFromCash,

    required this.items,
  });

  @JsonKey(name: r'date_from', required: true, includeIfNull: false)
  final DateTime dateFrom;

  @JsonKey(name: r'date_to', required: true, includeIfNull: false)
  final DateTime dateTo;

  @JsonKey(name: r'rides_count', required: true, includeIfNull: false)
  final int ridesCount;

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

  /// Gotówka przyjęta przez kierowcę
  // minimum: 0
  @JsonKey(name: r'cash_collected', required: true, includeIfNull: false)
  final int cashCollected;

  /// Prowizja do rozliczenia z gotówki
  // minimum: 0
  @JsonKey(
    name: r'commission_due_from_cash',
    required: true,
    includeIfNull: false,
  )
  final int commissionDueFromCash;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<EarningEntry> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarningsSummary &&
          other.dateFrom == dateFrom &&
          other.dateTo == dateTo &&
          other.ridesCount == ridesCount &&
          other.gross == gross &&
          other.commission == commission &&
          other.net == net &&
          other.cashCollected == cashCollected &&
          other.commissionDueFromCash == commissionDueFromCash &&
          other.items == items;

  @override
  int get hashCode =>
      dateFrom.hashCode +
      dateTo.hashCode +
      ridesCount.hashCode +
      gross.hashCode +
      commission.hashCode +
      net.hashCode +
      cashCollected.hashCode +
      commissionDueFromCash.hashCode +
      items.hashCode;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
