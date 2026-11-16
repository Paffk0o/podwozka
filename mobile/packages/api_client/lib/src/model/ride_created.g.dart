// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_created.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RideCreatedCWProxy {
  RideCreated ride(Ride ride);

  RideCreated payment(StripePaymentInit? payment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideCreated(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideCreated(...).copyWith(id: 12, name: "My name")
  /// ```
  RideCreated call({Ride ride, StripePaymentInit? payment});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRideCreated.copyWith(...)` or call `instanceOfRideCreated.copyWith.fieldName(value)` for a single field.
class _$RideCreatedCWProxyImpl implements _$RideCreatedCWProxy {
  const _$RideCreatedCWProxyImpl(this._value);

  final RideCreated _value;

  @override
  RideCreated ride(Ride ride) => call(ride: ride);

  @override
  RideCreated payment(StripePaymentInit? payment) => call(payment: payment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RideCreated(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RideCreated(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RideCreated call({
    Object? ride = const $CopyWithPlaceholder(),
    Object? payment = const $CopyWithPlaceholder(),
  }) {
    return RideCreated(
      ride: ride == const $CopyWithPlaceholder() || ride == null
          ? _value.ride
          // ignore: cast_nullable_to_non_nullable
          : ride as Ride,
      payment: payment == const $CopyWithPlaceholder()
          ? _value.payment
          // ignore: cast_nullable_to_non_nullable
          : payment as StripePaymentInit?,
    );
  }
}

extension $RideCreatedCopyWith on RideCreated {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRideCreated.copyWith(...)` or `instanceOfRideCreated.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RideCreatedCWProxy get copyWith => _$RideCreatedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideCreated _$RideCreatedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RideCreated', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ride', 'payment']);
      final val = RideCreated(
        ride: $checkedConvert(
          'ride',
          (v) => Ride.fromJson(v as Map<String, dynamic>),
        ),
        payment: $checkedConvert(
          'payment',
          (v) => v == null
              ? null
              : StripePaymentInit.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RideCreatedToJson(RideCreated instance) =>
    <String, dynamic>{
      'ride': instance.ride.toJson(),
      'payment': instance.payment?.toJson(),
    };
