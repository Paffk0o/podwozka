// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TariffCreateCWProxy {
  TariffCreate baseFare(int baseFare);

  TariffCreate perKm(int perKm);

  TariffCreate perMinute(int perMinute);

  TariffCreate minimumFare(int minimumFare);

  TariffCreate nightMultiplierPercent(int? nightMultiplierPercent);

  TariffCreate nightStartHour(int? nightStartHour);

  TariffCreate nightEndHour(int? nightEndHour);

  TariffCreate commissionPercent(int? commissionPercent);

  TariffCreate validFrom(DateTime? validFrom);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `TariffCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TariffCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  TariffCreate call({
    int baseFare,
    int perKm,
    int perMinute,
    int minimumFare,
    int? nightMultiplierPercent,
    int? nightStartHour,
    int? nightEndHour,
    int? commissionPercent,
    DateTime? validFrom,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTariffCreate.copyWith(...)` or call `instanceOfTariffCreate.copyWith.fieldName(value)` for a single field.
class _$TariffCreateCWProxyImpl implements _$TariffCreateCWProxy {
  const _$TariffCreateCWProxyImpl(this._value);

  final TariffCreate _value;

  @override
  TariffCreate baseFare(int baseFare) => call(baseFare: baseFare);

  @override
  TariffCreate perKm(int perKm) => call(perKm: perKm);

  @override
  TariffCreate perMinute(int perMinute) => call(perMinute: perMinute);

  @override
  TariffCreate minimumFare(int minimumFare) => call(minimumFare: minimumFare);

  @override
  TariffCreate nightMultiplierPercent(int? nightMultiplierPercent) =>
      call(nightMultiplierPercent: nightMultiplierPercent);

  @override
  TariffCreate nightStartHour(int? nightStartHour) =>
      call(nightStartHour: nightStartHour);

  @override
  TariffCreate nightEndHour(int? nightEndHour) =>
      call(nightEndHour: nightEndHour);

  @override
  TariffCreate commissionPercent(int? commissionPercent) =>
      call(commissionPercent: commissionPercent);

  @override
  TariffCreate validFrom(DateTime? validFrom) => call(validFrom: validFrom);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `TariffCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TariffCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  TariffCreate call({
    Object? baseFare = const $CopyWithPlaceholder(),
    Object? perKm = const $CopyWithPlaceholder(),
    Object? perMinute = const $CopyWithPlaceholder(),
    Object? minimumFare = const $CopyWithPlaceholder(),
    Object? nightMultiplierPercent = const $CopyWithPlaceholder(),
    Object? nightStartHour = const $CopyWithPlaceholder(),
    Object? nightEndHour = const $CopyWithPlaceholder(),
    Object? commissionPercent = const $CopyWithPlaceholder(),
    Object? validFrom = const $CopyWithPlaceholder(),
  }) {
    return TariffCreate(
      baseFare: baseFare == const $CopyWithPlaceholder() || baseFare == null
          ? _value.baseFare
          // ignore: cast_nullable_to_non_nullable
          : baseFare as int,
      perKm: perKm == const $CopyWithPlaceholder() || perKm == null
          ? _value.perKm
          // ignore: cast_nullable_to_non_nullable
          : perKm as int,
      perMinute: perMinute == const $CopyWithPlaceholder() || perMinute == null
          ? _value.perMinute
          // ignore: cast_nullable_to_non_nullable
          : perMinute as int,
      minimumFare:
          minimumFare == const $CopyWithPlaceholder() || minimumFare == null
          ? _value.minimumFare
          // ignore: cast_nullable_to_non_nullable
          : minimumFare as int,
      nightMultiplierPercent:
          nightMultiplierPercent == const $CopyWithPlaceholder()
          ? _value.nightMultiplierPercent
          // ignore: cast_nullable_to_non_nullable
          : nightMultiplierPercent as int?,
      nightStartHour: nightStartHour == const $CopyWithPlaceholder()
          ? _value.nightStartHour
          // ignore: cast_nullable_to_non_nullable
          : nightStartHour as int?,
      nightEndHour: nightEndHour == const $CopyWithPlaceholder()
          ? _value.nightEndHour
          // ignore: cast_nullable_to_non_nullable
          : nightEndHour as int?,
      commissionPercent: commissionPercent == const $CopyWithPlaceholder()
          ? _value.commissionPercent
          // ignore: cast_nullable_to_non_nullable
          : commissionPercent as int?,
      validFrom: validFrom == const $CopyWithPlaceholder()
          ? _value.validFrom
          // ignore: cast_nullable_to_non_nullable
          : validFrom as DateTime?,
    );
  }
}

extension $TariffCreateCopyWith on TariffCreate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTariffCreate.copyWith(...)` or `instanceOfTariffCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TariffCreateCWProxy get copyWith => _$TariffCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TariffCreate _$TariffCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'TariffCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['base_fare', 'per_km', 'per_minute', 'minimum_fare'],
    );
    final val = TariffCreate(
      baseFare: $checkedConvert('base_fare', (v) => (v as num).toInt()),
      perKm: $checkedConvert('per_km', (v) => (v as num).toInt()),
      perMinute: $checkedConvert('per_minute', (v) => (v as num).toInt()),
      minimumFare: $checkedConvert('minimum_fare', (v) => (v as num).toInt()),
      nightMultiplierPercent: $checkedConvert(
        'night_multiplier_percent',
        (v) => (v as num?)?.toInt() ?? 100,
      ),
      nightStartHour: $checkedConvert(
        'night_start_hour',
        (v) => (v as num?)?.toInt() ?? 22,
      ),
      nightEndHour: $checkedConvert(
        'night_end_hour',
        (v) => (v as num?)?.toInt() ?? 6,
      ),
      commissionPercent: $checkedConvert(
        'commission_percent',
        (v) => (v as num?)?.toInt() ?? 10,
      ),
      validFrom: $checkedConvert(
        'valid_from',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'baseFare': 'base_fare',
    'perKm': 'per_km',
    'perMinute': 'per_minute',
    'minimumFare': 'minimum_fare',
    'nightMultiplierPercent': 'night_multiplier_percent',
    'nightStartHour': 'night_start_hour',
    'nightEndHour': 'night_end_hour',
    'commissionPercent': 'commission_percent',
    'validFrom': 'valid_from',
  },
);

Map<String, dynamic> _$TariffCreateToJson(TariffCreate instance) =>
    <String, dynamic>{
      'base_fare': instance.baseFare,
      'per_km': instance.perKm,
      'per_minute': instance.perMinute,
      'minimum_fare': instance.minimumFare,
      'night_multiplier_percent': ?instance.nightMultiplierPercent,
      'night_start_hour': ?instance.nightStartHour,
      'night_end_hour': ?instance.nightEndHour,
      'commission_percent': ?instance.commissionPercent,
      'valid_from': ?instance.validFrom?.toIso8601String(),
    };
