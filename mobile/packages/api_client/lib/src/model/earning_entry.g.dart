// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earning_entry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EarningEntryCWProxy {
  EarningEntry rideId(String rideId);

  EarningEntry completedAt(DateTime completedAt);

  EarningEntry paymentMethod(PaymentMethod paymentMethod);

  EarningEntry gross(int gross);

  EarningEntry commission(int commission);

  EarningEntry net(int net);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `EarningEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EarningEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  EarningEntry call({
    String rideId,
    DateTime completedAt,
    PaymentMethod paymentMethod,
    int gross,
    int commission,
    int net,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEarningEntry.copyWith(...)` or call `instanceOfEarningEntry.copyWith.fieldName(value)` for a single field.
class _$EarningEntryCWProxyImpl implements _$EarningEntryCWProxy {
  const _$EarningEntryCWProxyImpl(this._value);

  final EarningEntry _value;

  @override
  EarningEntry rideId(String rideId) => call(rideId: rideId);

  @override
  EarningEntry completedAt(DateTime completedAt) =>
      call(completedAt: completedAt);

  @override
  EarningEntry paymentMethod(PaymentMethod paymentMethod) =>
      call(paymentMethod: paymentMethod);

  @override
  EarningEntry gross(int gross) => call(gross: gross);

  @override
  EarningEntry commission(int commission) => call(commission: commission);

  @override
  EarningEntry net(int net) => call(net: net);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `EarningEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EarningEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  EarningEntry call({
    Object? rideId = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? gross = const $CopyWithPlaceholder(),
    Object? commission = const $CopyWithPlaceholder(),
    Object? net = const $CopyWithPlaceholder(),
  }) {
    return EarningEntry(
      rideId: rideId == const $CopyWithPlaceholder() || rideId == null
          ? _value.rideId
          // ignore: cast_nullable_to_non_nullable
          : rideId as String,
      completedAt:
          completedAt == const $CopyWithPlaceholder() || completedAt == null
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime,
      paymentMethod:
          paymentMethod == const $CopyWithPlaceholder() || paymentMethod == null
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as PaymentMethod,
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
    );
  }
}

extension $EarningEntryCopyWith on EarningEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEarningEntry.copyWith(...)` or `instanceOfEarningEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EarningEntryCWProxy get copyWith => _$EarningEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningEntry _$EarningEntryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'EarningEntry',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'ride_id',
            'completed_at',
            'payment_method',
            'gross',
            'commission',
            'net',
          ],
        );
        final val = EarningEntry(
          rideId: $checkedConvert('ride_id', (v) => v as String),
          completedAt: $checkedConvert(
            'completed_at',
            (v) => DateTime.parse(v as String),
          ),
          paymentMethod: $checkedConvert(
            'payment_method',
            (v) => $enumDecode(_$PaymentMethodEnumMap, v),
          ),
          gross: $checkedConvert('gross', (v) => (v as num).toInt()),
          commission: $checkedConvert('commission', (v) => (v as num).toInt()),
          net: $checkedConvert('net', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'rideId': 'ride_id',
        'completedAt': 'completed_at',
        'paymentMethod': 'payment_method',
      },
    );

Map<String, dynamic> _$EarningEntryToJson(EarningEntry instance) =>
    <String, dynamic>{
      'ride_id': instance.rideId,
      'completed_at': instance.completedAt.toIso8601String(),
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'gross': instance.gross,
      'commission': instance.commission,
      'net': instance.net,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.card: 'card',
  PaymentMethod.blik: 'blik',
  PaymentMethod.cash: 'cash',
};
