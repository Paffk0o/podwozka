// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TariffCWProxy {
  Tariff baseFare(int baseFare);

  Tariff perKm(int perKm);

  Tariff perMinute(int perMinute);

  Tariff minimumFare(int minimumFare);

  Tariff nightMultiplierPercent(int? nightMultiplierPercent);

  Tariff nightStartHour(int? nightStartHour);

  Tariff nightEndHour(int? nightEndHour);

  Tariff commissionPercent(int? commissionPercent);

  Tariff id(String id);

  Tariff regionId(String regionId);

  Tariff validFrom(DateTime validFrom);

  Tariff validTo(DateTime? validTo);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Tariff(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Tariff(...).copyWith(id: 12, name: "My name")
  /// ```
  Tariff call({
    int baseFare,
    int perKm,
    int perMinute,
    int minimumFare,
    int? nightMultiplierPercent,
    int? nightStartHour,
    int? nightEndHour,
    int? commissionPercent,
    String id,
    String regionId,
    DateTime validFrom,
    DateTime? validTo,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTariff.copyWith(...)` or call `instanceOfTariff.copyWith.fieldName(value)` for a single field.
class _$TariffCWProxyImpl implements _$TariffCWProxy {
  const _$TariffCWProxyImpl(this._value);

  final Tariff _value;

  @override
  Tariff baseFare(int baseFare) => call(baseFare: baseFare);

  @override
  Tariff perKm(int perKm) => call(perKm: perKm);

  @override
  Tariff perMinute(int perMinute) => call(perMinute: perMinute);

  @override
  Tariff minimumFare(int minimumFare) => call(minimumFare: minimumFare);

  @override
  Tariff nightMultiplierPercent(int? nightMultiplierPercent) =>
      call(nightMultiplierPercent: nightMultiplierPercent);

  @override
  Tariff nightStartHour(int? nightStartHour) =>
      call(nightStartHour: nightStartHour);

  @override
  Tariff nightEndHour(int? nightEndHour) => call(nightEndHour: nightEndHour);

  @override
  Tariff commissionPercent(int? commissionPercent) =>
      call(commissionPercent: commissionPercent);

  @override
  Tariff id(String id) => call(id: id);

  @override
  Tariff regionId(String regionId) => call(regionId: regionId);

  @override
  Tariff validFrom(DateTime validFrom) => call(validFrom: validFrom);

  @override
  Tariff validTo(DateTime? validTo) => call(validTo: validTo);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Tariff(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Tariff(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Tariff call({
    Object? baseFare = const $CopyWithPlaceholder(),
    Object? perKm = const $CopyWithPlaceholder(),
    Object? perMinute = const $CopyWithPlaceholder(),
    Object? minimumFare = const $CopyWithPlaceholder(),
    Object? nightMultiplierPercent = const $CopyWithPlaceholder(),
    Object? nightStartHour = const $CopyWithPlaceholder(),
    Object? nightEndHour = const $CopyWithPlaceholder(),
    Object? commissionPercent = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? regionId = const $CopyWithPlaceholder(),
    Object? validFrom = const $CopyWithPlaceholder(),
    Object? validTo = const $CopyWithPlaceholder(),
  }) {
    return Tariff(
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
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      regionId: regionId == const $CopyWithPlaceholder() || regionId == null
          ? _value.regionId
          // ignore: cast_nullable_to_non_nullable
          : regionId as String,
      validFrom: validFrom == const $CopyWithPlaceholder() || validFrom == null
          ? _value.validFrom
          // ignore: cast_nullable_to_non_nullable
          : validFrom as DateTime,
      validTo: validTo == const $CopyWithPlaceholder()
          ? _value.validTo
          // ignore: cast_nullable_to_non_nullable
          : validTo as DateTime?,
    );
  }
}

extension $TariffCopyWith on Tariff {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTariff.copyWith(...)` or `instanceOfTariff.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TariffCWProxy get copyWith => _$TariffCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tariff _$TariffFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Tariff',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'base_fare',
        'per_km',
        'per_minute',
        'minimum_fare',
        'id',
        'region_id',
        'valid_from',
        'valid_to',
      ],
    );
    final val = Tariff(
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
      id: $checkedConvert('id', (v) => v as String),
      regionId: $checkedConvert('region_id', (v) => v as String),
      validFrom: $checkedConvert(
        'valid_from',
        (v) => DateTime.parse(v as String),
      ),
      validTo: $checkedConvert(
        'valid_to',
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
    'regionId': 'region_id',
    'validFrom': 'valid_from',
    'validTo': 'valid_to',
  },
);

Map<String, dynamic> _$TariffToJson(Tariff instance) => <String, dynamic>{
  'base_fare': instance.baseFare,
  'per_km': instance.perKm,
  'per_minute': instance.perMinute,
  'minimum_fare': instance.minimumFare,
  'night_multiplier_percent': ?instance.nightMultiplierPercent,
  'night_start_hour': ?instance.nightStartHour,
  'night_end_hour': ?instance.nightEndHour,
  'commission_percent': ?instance.commissionPercent,
  'id': instance.id,
  'region_id': instance.regionId,
  'valid_from': instance.validFrom.toIso8601String(),
  'valid_to': instance.validTo?.toIso8601String(),
};
