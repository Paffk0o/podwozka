// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuoteCWProxy {
  Quote id(String id);

  Quote regionId(String regionId);

  Quote regionName(String regionName);

  Quote pickup(Place pickup);

  Quote destination(Place destination);

  Quote scheduledAt(DateTime? scheduledAt);

  Quote distanceM(int distanceM);

  Quote durationS(int durationS);

  Quote price(int price);

  Quote currency(String? currency);

  Quote tariffId(String tariffId);

  Quote routePolyline(String? routePolyline);

  Quote expiresAt(DateTime expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Quote(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Quote(...).copyWith(id: 12, name: "My name")
  /// ```
  Quote call({
    String id,
    String regionId,
    String regionName,
    Place pickup,
    Place destination,
    DateTime? scheduledAt,
    int distanceM,
    int durationS,
    int price,
    String? currency,
    String tariffId,
    String? routePolyline,
    DateTime expiresAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfQuote.copyWith(...)` or call `instanceOfQuote.copyWith.fieldName(value)` for a single field.
class _$QuoteCWProxyImpl implements _$QuoteCWProxy {
  const _$QuoteCWProxyImpl(this._value);

  final Quote _value;

  @override
  Quote id(String id) => call(id: id);

  @override
  Quote regionId(String regionId) => call(regionId: regionId);

  @override
  Quote regionName(String regionName) => call(regionName: regionName);

  @override
  Quote pickup(Place pickup) => call(pickup: pickup);

  @override
  Quote destination(Place destination) => call(destination: destination);

  @override
  Quote scheduledAt(DateTime? scheduledAt) => call(scheduledAt: scheduledAt);

  @override
  Quote distanceM(int distanceM) => call(distanceM: distanceM);

  @override
  Quote durationS(int durationS) => call(durationS: durationS);

  @override
  Quote price(int price) => call(price: price);

  @override
  Quote currency(String? currency) => call(currency: currency);

  @override
  Quote tariffId(String tariffId) => call(tariffId: tariffId);

  @override
  Quote routePolyline(String? routePolyline) =>
      call(routePolyline: routePolyline);

  @override
  Quote expiresAt(DateTime expiresAt) => call(expiresAt: expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Quote(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Quote(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Quote call({
    Object? id = const $CopyWithPlaceholder(),
    Object? regionId = const $CopyWithPlaceholder(),
    Object? regionName = const $CopyWithPlaceholder(),
    Object? pickup = const $CopyWithPlaceholder(),
    Object? destination = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? distanceM = const $CopyWithPlaceholder(),
    Object? durationS = const $CopyWithPlaceholder(),
    Object? price = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? tariffId = const $CopyWithPlaceholder(),
    Object? routePolyline = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return Quote(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      regionId: regionId == const $CopyWithPlaceholder() || regionId == null
          ? _value.regionId
          // ignore: cast_nullable_to_non_nullable
          : regionId as String,
      regionName:
          regionName == const $CopyWithPlaceholder() || regionName == null
          ? _value.regionName
          // ignore: cast_nullable_to_non_nullable
          : regionName as String,
      pickup: pickup == const $CopyWithPlaceholder() || pickup == null
          ? _value.pickup
          // ignore: cast_nullable_to_non_nullable
          : pickup as Place,
      destination:
          destination == const $CopyWithPlaceholder() || destination == null
          ? _value.destination
          // ignore: cast_nullable_to_non_nullable
          : destination as Place,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime?,
      distanceM: distanceM == const $CopyWithPlaceholder() || distanceM == null
          ? _value.distanceM
          // ignore: cast_nullable_to_non_nullable
          : distanceM as int,
      durationS: durationS == const $CopyWithPlaceholder() || durationS == null
          ? _value.durationS
          // ignore: cast_nullable_to_non_nullable
          : durationS as int,
      price: price == const $CopyWithPlaceholder() || price == null
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      tariffId: tariffId == const $CopyWithPlaceholder() || tariffId == null
          ? _value.tariffId
          // ignore: cast_nullable_to_non_nullable
          : tariffId as String,
      routePolyline: routePolyline == const $CopyWithPlaceholder()
          ? _value.routePolyline
          // ignore: cast_nullable_to_non_nullable
          : routePolyline as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $QuoteCopyWith on Quote {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfQuote.copyWith(...)` or `instanceOfQuote.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuoteCWProxy get copyWith => _$QuoteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Quote',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'region_id',
        'region_name',
        'pickup',
        'destination',
        'scheduled_at',
        'distance_m',
        'duration_s',
        'price',
        'tariff_id',
        'route_polyline',
        'expires_at',
      ],
    );
    final val = Quote(
      id: $checkedConvert('id', (v) => v as String),
      regionId: $checkedConvert('region_id', (v) => v as String),
      regionName: $checkedConvert('region_name', (v) => v as String),
      pickup: $checkedConvert(
        'pickup',
        (v) => Place.fromJson(v as Map<String, dynamic>),
      ),
      destination: $checkedConvert(
        'destination',
        (v) => Place.fromJson(v as Map<String, dynamic>),
      ),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      distanceM: $checkedConvert('distance_m', (v) => (v as num).toInt()),
      durationS: $checkedConvert('duration_s', (v) => (v as num).toInt()),
      price: $checkedConvert('price', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'PLN'),
      tariffId: $checkedConvert('tariff_id', (v) => v as String),
      routePolyline: $checkedConvert('route_polyline', (v) => v as String?),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'regionId': 'region_id',
    'regionName': 'region_name',
    'scheduledAt': 'scheduled_at',
    'distanceM': 'distance_m',
    'durationS': 'duration_s',
    'tariffId': 'tariff_id',
    'routePolyline': 'route_polyline',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
  'id': instance.id,
  'region_id': instance.regionId,
  'region_name': instance.regionName,
  'pickup': instance.pickup.toJson(),
  'destination': instance.destination.toJson(),
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'distance_m': instance.distanceM,
  'duration_s': instance.durationS,
  'price': instance.price,
  'currency': ?instance.currency,
  'tariff_id': instance.tariffId,
  'route_polyline': instance.routePolyline,
  'expires_at': instance.expiresAt.toIso8601String(),
};
