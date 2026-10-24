// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_current_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DriverCurrentStateCWProxy {
  DriverCurrentState profile(DriverProfile profile);

  DriverCurrentState pendingOffer(RideOffer? pendingOffer);

  DriverCurrentState activeRide(Ride? activeRide);

  DriverCurrentState nextScheduledRide(Ride? nextScheduledRide);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverCurrentState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverCurrentState(...).copyWith(id: 12, name: "My name")
  /// ```
  DriverCurrentState call({
    DriverProfile profile,
    RideOffer? pendingOffer,
    Ride? activeRide,
    Ride? nextScheduledRide,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDriverCurrentState.copyWith(...)` or call `instanceOfDriverCurrentState.copyWith.fieldName(value)` for a single field.
class _$DriverCurrentStateCWProxyImpl implements _$DriverCurrentStateCWProxy {
  const _$DriverCurrentStateCWProxyImpl(this._value);

  final DriverCurrentState _value;

  @override
  DriverCurrentState profile(DriverProfile profile) => call(profile: profile);

  @override
  DriverCurrentState pendingOffer(RideOffer? pendingOffer) =>
      call(pendingOffer: pendingOffer);

  @override
  DriverCurrentState activeRide(Ride? activeRide) =>
      call(activeRide: activeRide);

  @override
  DriverCurrentState nextScheduledRide(Ride? nextScheduledRide) =>
      call(nextScheduledRide: nextScheduledRide);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverCurrentState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverCurrentState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DriverCurrentState call({
    Object? profile = const $CopyWithPlaceholder(),
    Object? pendingOffer = const $CopyWithPlaceholder(),
    Object? activeRide = const $CopyWithPlaceholder(),
    Object? nextScheduledRide = const $CopyWithPlaceholder(),
  }) {
    return DriverCurrentState(
      profile: profile == const $CopyWithPlaceholder() || profile == null
          ? _value.profile
          // ignore: cast_nullable_to_non_nullable
          : profile as DriverProfile,
      pendingOffer: pendingOffer == const $CopyWithPlaceholder()
          ? _value.pendingOffer
          // ignore: cast_nullable_to_non_nullable
          : pendingOffer as RideOffer?,
      activeRide: activeRide == const $CopyWithPlaceholder()
          ? _value.activeRide
          // ignore: cast_nullable_to_non_nullable
          : activeRide as Ride?,
      nextScheduledRide: nextScheduledRide == const $CopyWithPlaceholder()
          ? _value.nextScheduledRide
          // ignore: cast_nullable_to_non_nullable
          : nextScheduledRide as Ride?,
    );
  }
}

extension $DriverCurrentStateCopyWith on DriverCurrentState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDriverCurrentState.copyWith(...)` or `instanceOfDriverCurrentState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DriverCurrentStateCWProxy get copyWith =>
      _$DriverCurrentStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverCurrentState _$DriverCurrentStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DriverCurrentState',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'profile',
            'pending_offer',
            'active_ride',
            'next_scheduled_ride',
          ],
        );
        final val = DriverCurrentState(
          profile: $checkedConvert(
            'profile',
            (v) => DriverProfile.fromJson(v as Map<String, dynamic>),
          ),
          pendingOffer: $checkedConvert(
            'pending_offer',
            (v) => v == null
                ? null
                : RideOffer.fromJson(v as Map<String, dynamic>),
          ),
          activeRide: $checkedConvert(
            'active_ride',
            (v) => v == null ? null : Ride.fromJson(v as Map<String, dynamic>),
          ),
          nextScheduledRide: $checkedConvert(
            'next_scheduled_ride',
            (v) => v == null ? null : Ride.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pendingOffer': 'pending_offer',
        'activeRide': 'active_ride',
        'nextScheduledRide': 'next_scheduled_ride',
      },
    );

Map<String, dynamic> _$DriverCurrentStateToJson(DriverCurrentState instance) =>
    <String, dynamic>{
      'profile': instance.profile.toJson(),
      'pending_offer': instance.pendingOffer?.toJson(),
      'active_ride': instance.activeRide?.toJson(),
      'next_scheduled_ride': instance.nextScheduledRide?.toJson(),
    };
