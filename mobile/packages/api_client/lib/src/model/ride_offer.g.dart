// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_offer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RideOfferCWProxy {
  RideOffer id(String id);

  RideOffer ride(Ride ride);

  RideOffer pickupDistanceM(int pickupDistanceM);

  RideOffer pickupEtaS(int pickupEtaS);

  RideOffer expiresAt(DateTime expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideOffer(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideOffer(...).copyWith(id: 12, name: "My name")
  /// ```
  RideOffer call({
    String id,
    Ride ride,
    int pickupDistanceM,
    int pickupEtaS,
    DateTime expiresAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRideOffer.copyWith(...)` or call `instanceOfRideOffer.copyWith.fieldName(value)` for a single field.
class _$RideOfferCWProxyImpl implements _$RideOfferCWProxy {
  const _$RideOfferCWProxyImpl(this._value);

  final RideOffer _value;

  @override
  RideOffer id(String id) => call(id: id);

  @override
  RideOffer ride(Ride ride) => call(ride: ride);

  @override
  RideOffer pickupDistanceM(int pickupDistanceM) =>
      call(pickupDistanceM: pickupDistanceM);

  @override
  RideOffer pickupEtaS(int pickupEtaS) => call(pickupEtaS: pickupEtaS);

  @override
  RideOffer expiresAt(DateTime expiresAt) => call(expiresAt: expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideOffer(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideOffer(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RideOffer call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ride = const $CopyWithPlaceholder(),
    Object? pickupDistanceM = const $CopyWithPlaceholder(),
    Object? pickupEtaS = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return RideOffer(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ride: ride == const $CopyWithPlaceholder() || ride == null
          ? _value.ride
          // ignore: cast_nullable_to_non_nullable
          : ride as Ride,
      pickupDistanceM:
          pickupDistanceM == const $CopyWithPlaceholder() ||
              pickupDistanceM == null
          ? _value.pickupDistanceM
          // ignore: cast_nullable_to_non_nullable
          : pickupDistanceM as int,
      pickupEtaS:
          pickupEtaS == const $CopyWithPlaceholder() || pickupEtaS == null
          ? _value.pickupEtaS
          // ignore: cast_nullable_to_non_nullable
          : pickupEtaS as int,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $RideOfferCopyWith on RideOffer {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRideOffer.copyWith(...)` or `instanceOfRideOffer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RideOfferCWProxy get copyWith => _$RideOfferCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideOffer _$RideOfferFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RideOffer',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'ride',
        'pickup_distance_m',
        'pickup_eta_s',
        'expires_at',
      ],
    );
    final val = RideOffer(
      id: $checkedConvert('id', (v) => v as String),
      ride: $checkedConvert(
        'ride',
        (v) => Ride.fromJson(v as Map<String, dynamic>),
      ),
      pickupDistanceM: $checkedConvert(
        'pickup_distance_m',
        (v) => (v as num).toInt(),
      ),
      pickupEtaS: $checkedConvert('pickup_eta_s', (v) => (v as num).toInt()),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'pickupDistanceM': 'pickup_distance_m',
    'pickupEtaS': 'pickup_eta_s',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$RideOfferToJson(RideOffer instance) => <String, dynamic>{
  'id': instance.id,
  'ride': instance.ride.toJson(),
  'pickup_distance_m': instance.pickupDistanceM,
  'pickup_eta_s': instance.pickupEtaS,
  'expires_at': instance.expiresAt.toIso8601String(),
};
