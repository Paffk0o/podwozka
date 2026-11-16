// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EarningsSummaryCWProxy {
  EarningsSummary dateFrom(DateTime dateFrom);

  EarningsSummary dateTo(DateTime dateTo);

  EarningsSummary ridesCount(int ridesCount);

  EarningsSummary gross(int gross);

  EarningsSummary commission(int commission);

  EarningsSummary net(int net);

  EarningsSummary cashCollected(int cashCollected);

  EarningsSummary commissionDueFromCash(int commissionDueFromCash);

  EarningsSummary items(List<EarningEntry> items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `EarningsSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EarningsSummary(...).copyWith(id: 12, name: "My name")
  /// ```
  EarningsSummary call({
    DateTime dateFrom,
    DateTime dateTo,
    int ridesCount,
    int gross,
    int commission,
    int net,
    int cashCollected,
    int commissionDueFromCash,
    List<EarningEntry> items,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEarningsSummary.copyWith(...)` or call `instanceOfEarningsSummary.copyWith.fieldName(value)` for a single field.
class _$EarningsSummaryCWProxyImpl implements _$EarningsSummaryCWProxy {
  const _$EarningsSummaryCWProxyImpl(this._value);

  final EarningsSummary _value;

  @override
  EarningsSummary dateFrom(DateTime dateFrom) => call(dateFrom: dateFrom);

  @override
  EarningsSummary dateTo(DateTime dateTo) => call(dateTo: dateTo);

  @override
  EarningsSummary ridesCount(int ridesCount) => call(ridesCount: ridesCount);

  @override
  EarningsSummary gross(int gross) => call(gross: gross);

  @override
  EarningsSummary commission(int commission) => call(commission: commission);

  @override
  EarningsSummary net(int net) => call(net: net);

  @override
  EarningsSummary cashCollected(int cashCollected) =>
      call(cashCollected: cashCollected);

  @override
  EarningsSummary commissionDueFromCash(int commissionDueFromCash) =>
      call(commissionDueFromCash: commissionDueFromCash);

  @override
  EarningsSummary items(List<EarningEntry> items) => call(items: items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `EarningsSummary(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EarningsSummary(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  EarningsSummary call({
    Object? dateFrom = const $CopyWithPlaceholder(),
    Object? dateTo = const $CopyWithPlaceholder(),
    Object? ridesCount = const $CopyWithPlaceholder(),
    Object? gross = const $CopyWithPlaceholder(),
    Object? commission = const $CopyWithPlaceholder(),
    Object? net = const $CopyWithPlaceholder(),
    Object? cashCollected = const $CopyWithPlaceholder(),
    Object? commissionDueFromCash = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return EarningsSummary(
      dateFrom: dateFrom == const $CopyWithPlaceholder() || dateFrom == null
          ? _value.dateFrom
          // ignore: cast_nullable_to_non_nullable
          : dateFrom as DateTime,
      dateTo: dateTo == const $CopyWithPlaceholder() || dateTo == null
          ? _value.dateTo
          // ignore: cast_nullable_to_non_nullable
          : dateTo as DateTime,
      ridesCount:
          ridesCount == const $CopyWithPlaceholder() || ridesCount == null
          ? _value.ridesCount
          // ignore: cast_nullable_to_non_nullable
          : ridesCount as int,
      gross: gross == const $CopyWithPlaceholder() || gross == null
          ? _value.gross
          // ignore: cast_nullable_to_non_nullable
          : gross as int,
      commission:
          commission == const $CopyWithPlaceholder() || commission == null
          ? _value.commission
          // ignore: cast_nullable_to_non_nullable
          : commission as int,
      net: net == const $CopyWithPlaceholder() || net == null
          ? _value.net
          // ignore: cast_nullable_to_non_nullable
          : net as int,
      cashCollected:
          cashCollected == const $CopyWithPlaceholder() || cashCollected == null
          ? _value.cashCollected
          // ignore: cast_nullable_to_non_nullable
          : cashCollected as int,
      commissionDueFromCash:
          commissionDueFromCash == const $CopyWithPlaceholder() ||
              commissionDueFromCash == null
          ? _value.commissionDueFromCash
          // ignore: cast_nullable_to_non_nullable
          : commissionDueFromCash as int,
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<EarningEntry>,
    );
  }
}

extension $EarningsSummaryCopyWith on EarningsSummary {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEarningsSummary.copyWith(...)` or `instanceOfEarningsSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EarningsSummaryCWProxy get copyWith => _$EarningsSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EarningsSummary',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'date_from',
            'date_to',
            'rides_count',
            'gross',
            'commission',
            'net',
            'cash_collected',
            'commission_due_from_cash',
            'items',
          ],
        );
        final val = EarningsSummary(
          dateFrom: $checkedConvert(
            'date_from',
            (v) => DateTime.parse(v as String),
          ),
          dateTo: $checkedConvert(
            'date_to',
            (v) => DateTime.parse(v as String),
          ),
          ridesCount: $checkedConvert('rides_count', (v) => (v as num).toInt()),
          gross: $checkedConvert('gross', (v) => (v as num).toInt()),
          commission: $checkedConvert('commission', (v) => (v as num).toInt()),
          net: $checkedConvert('net', (v) => (v as num).toInt()),
          cashCollected: $checkedConvert(
            'cash_collected',
            (v) => (v as num).toInt(),
          ),
          commissionDueFromCash: $checkedConvert(
            'commission_due_from_cash',
            (v) => (v as num).toInt(),
          ),
          items: $checkedConvert(
            'items',
            (v) => (v as List<dynamic>)
                .map((e) => EarningEntry.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'dateFrom': 'date_from',
        'dateTo': 'date_to',
        'ridesCount': 'rides_count',
        'cashCollected': 'cash_collected',
        'commissionDueFromCash': 'commission_due_from_cash',
      },
    );

Map<String, dynamic> _$EarningsSummaryToJson(EarningsSummary instance) =>
    <String, dynamic>{
      'date_from': instance.dateFrom.toIso8601String(),
      'date_to': instance.dateTo.toIso8601String(),
      'rides_count': instance.ridesCount,
      'gross': instance.gross,
      'commission': instance.commission,
      'net': instance.net,
      'cash_collected': instance.cashCollected,
      'commission_due_from_cash': instance.commissionDueFromCash,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
