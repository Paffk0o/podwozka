// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RideCWProxy {
  Ride id(String id);

  Ride status(RideStatus status);

  Ride regionId(String regionId);

  Ride pickup(Place pickup);

  Ride destination(Place destination);

  Ride scheduledAt(DateTime? scheduledAt);

  Ride requestedAt(DateTime requestedAt);

  Ride acceptedAt(DateTime? acceptedAt);

  Ride startedAt(DateTime? startedAt);

  Ride completedAt(DateTime? completedAt);

  Ride cancelledAt(DateTime? cancelledAt);

  Ride cancelReason(String? cancelReason);

  Ride price(int price);

  Ride currency(String? currency);

  Ride paymentMethod(PaymentMethod paymentMethod);

  Ride paymentStatus(PaymentStatus paymentStatus);

  Ride distanceM(int distanceM);

  Ride durationS(int durationS);

  Ride routePolyline(String? routePolyline);

  Ride passengerNote(String? passengerNote);

  Ride driver(RideDriverInfo? driver);

  Ride passenger(RidePassengerInfo? passenger);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Ride(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Ride(...).copyWith(id: 12, name: "My name")
  /// ```
  Ride call({
    String id,
    RideStatus status,
    String regionId,
    Place pickup,
    Place destination,
    DateTime? scheduledAt,
    DateTime requestedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    int price,
    String? currency,
    PaymentMethod paymentMethod,
    PaymentStatus paymentStatus,
    int distanceM,
    int durationS,
    String? routePolyline,
    String? passengerNote,
    RideDriverInfo? driver,
    RidePassengerInfo? passenger,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRide.copyWith(...)` or call `instanceOfRide.copyWith.fieldName(value)` for a single field.
class _$RideCWProxyImpl implements _$RideCWProxy {
  const _$RideCWProxyImpl(this._value);

  final Ride _value;

  @override
  Ride id(String id) => call(id: id);

  @override
  Ride status(RideStatus status) => call(status: status);

  @override
  Ride regionId(String regionId) => call(regionId: regionId);

  @override
  Ride pickup(Place pickup) => call(pickup: pickup);

  @override
  Ride destination(Place destination) => call(destination: destination);

  @override
  Ride scheduledAt(DateTime? scheduledAt) => call(scheduledAt: scheduledAt);

  @override
  Ride requestedAt(DateTime requestedAt) => call(requestedAt: requestedAt);

  @override
  Ride acceptedAt(DateTime? acceptedAt) => call(acceptedAt: acceptedAt);

  @override
  Ride startedAt(DateTime? startedAt) => call(startedAt: startedAt);

  @override
  Ride completedAt(DateTime? completedAt) => call(completedAt: completedAt);

  @override
  Ride cancelledAt(DateTime? cancelledAt) => call(cancelledAt: cancelledAt);

  @override
  Ride cancelReason(String? cancelReason) => call(cancelReason: cancelReason);

  @override
  Ride price(int price) => call(price: price);

  @override
  Ride currency(String? currency) => call(currency: currency);

  @override
  Ride paymentMethod(PaymentMethod paymentMethod) =>
      call(paymentMethod: paymentMethod);

  @override
  Ride paymentStatus(PaymentStatus paymentStatus) =>
      call(paymentStatus: paymentStatus);

  @override
  Ride distanceM(int distanceM) => call(distanceM: distanceM);

  @override
  Ride durationS(int durationS) => call(durationS: durationS);

  @override
  Ride routePolyline(String? routePolyline) =>
      call(routePolyline: routePolyline);

  @override
  Ride passengerNote(String? passengerNote) =>
      call(passengerNote: passengerNote);

  @override
  Ride driver(RideDriverInfo? driver) => call(driver: driver);

  @override
  Ride passenger(RidePassengerInfo? passenger) => call(passenger: passenger);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Ride(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Ride(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Ride call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? regionId = const $CopyWithPlaceholder(),
    Object? pickup = const $CopyWithPlaceholder(),
    Object? destination = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? requestedAt = const $CopyWithPlaceholder(),
    Object? acceptedAt = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
    Object? cancelledAt = const $CopyWithPlaceholder(),
    Object? cancelReason = const $CopyWithPlaceholder(),
    Object? price = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? paymentStatus = const $CopyWithPlaceholder(),
    Object? distanceM = const $CopyWithPlaceholder(),
    Object? durationS = const $CopyWithPlaceholder(),
    Object? routePolyline = const $CopyWithPlaceholder(),
    Object? passengerNote = const $CopyWithPlaceholder(),
    Object? driver = const $CopyWithPlaceholder(),
    Object? passenger = const $CopyWithPlaceholder(),
  }) {
    return Ride(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as RideStatus,
      regionId: regionId == const $CopyWithPlaceholder() || regionId == null
          ? _value.regionId
          // ignore: cast_nullable_to_non_nullable
          : regionId as String,
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
      requestedAt:
          requestedAt == const $CopyWithPlaceholder() || requestedAt == null
          ? _value.requestedAt
          // ignore: cast_nullable_to_non_nullable
          : requestedAt as DateTime,
      acceptedAt: acceptedAt == const $CopyWithPlaceholder()
          ? _value.acceptedAt
          // ignore: cast_nullable_to_non_nullable
          : acceptedAt as DateTime?,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime?,
      cancelledAt: cancelledAt == const $CopyWithPlaceholder()
          ? _value.cancelledAt
          // ignore: cast_nullable_to_non_nullable
          : cancelledAt as DateTime?,
      cancelReason: cancelReason == const $CopyWithPlaceholder()
          ? _value.cancelReason
          // ignore: cast_nullable_to_non_nullable
          : cancelReason as String?,
      price: price == const $CopyWithPlaceholder() || price == null
          ? _value.price
          // ignore: cast_nullable_to_non_nullable
          : price as int,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      paymentMethod:
          paymentMethod == const $CopyWithPlaceholder() || paymentMethod == null
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as PaymentMethod,
      paymentStatus:
          paymentStatus == const $CopyWithPlaceholder() || paymentStatus == null
          ? _value.paymentStatus
          // ignore: cast_nullable_to_non_nullable
          : paymentStatus as PaymentStatus,
      distanceM: distanceM == const $CopyWithPlaceholder() || distanceM == null
          ? _value.distanceM
          // ignore: cast_nullable_to_non_nullable
          : distanceM as int,
      durationS: durationS == const $CopyWithPlaceholder() || durationS == null
          ? _value.durationS
          // ignore: cast_nullable_to_non_nullable
          : durationS as int,
      routePolyline: routePolyline == const $CopyWithPlaceholder()
          ? _value.routePolyline
          // ignore: cast_nullable_to_non_nullable
          : routePolyline as String?,
      passengerNote: passengerNote == const $CopyWithPlaceholder()
          ? _value.passengerNote
          // ignore: cast_nullable_to_non_nullable
          : passengerNote as String?,
      driver: driver == const $CopyWithPlaceholder()
          ? _value.driver
          // ignore: cast_nullable_to_non_nullable
          : driver as RideDriverInfo?,
      passenger: passenger == const $CopyWithPlaceholder()
          ? _value.passenger
          // ignore: cast_nullable_to_non_nullable
          : passenger as RidePassengerInfo?,
    );
  }
}

extension $RideCopyWith on Ride {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRide.copyWith(...)` or `instanceOfRide.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RideCWProxy get copyWith => _$RideCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Ride',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'status',
        'region_id',
        'pickup',
        'destination',
        'scheduled_at',
        'requested_at',
        'accepted_at',
        'started_at',
        'completed_at',
        'cancelled_at',
        'cancel_reason',
        'price',
        'payment_method',
        'payment_status',
        'distance_m',
        'duration_s',
        'route_polyline',
        'passenger_note',
        'driver',
        'passenger',
      ],
    );
    final val = Ride(
      id: $checkedConvert('id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$RideStatusEnumMap, v),
      ),
      regionId: $checkedConvert('region_id', (v) => v as String),
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
      requestedAt: $checkedConvert(
        'requested_at',
        (v) => DateTime.parse(v as String),
      ),
      acceptedAt: $checkedConvert(
        'accepted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      startedAt: $checkedConvert(
        'started_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      completedAt: $checkedConvert(
        'completed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      cancelledAt: $checkedConvert(
        'cancelled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      cancelReason: $checkedConvert('cancel_reason', (v) => v as String?),
      price: $checkedConvert('price', (v) => (v as num).toInt()),
      currency: $checkedConvert('currency', (v) => v as String? ?? 'PLN'),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) => $enumDecode(_$PaymentMethodEnumMap, v),
      ),
      paymentStatus: $checkedConvert(
        'payment_status',
        (v) => $enumDecode(_$PaymentStatusEnumMap, v),
      ),
      distanceM: $checkedConvert('distance_m', (v) => (v as num).toInt()),
      durationS: $checkedConvert('duration_s', (v) => (v as num).toInt()),
      routePolyline: $checkedConvert('route_polyline', (v) => v as String?),
      passengerNote: $checkedConvert('passenger_note', (v) => v as String?),
      driver: $checkedConvert(
        'driver',
        (v) => v == null
            ? null
            : RideDriverInfo.fromJson(v as Map<String, dynamic>),
      ),
      passenger: $checkedConvert(
        'passenger',
        (v) => v == null
            ? null
            : RidePassengerInfo.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'regionId': 'region_id',
    'scheduledAt': 'scheduled_at',
    'requestedAt': 'requested_at',
    'acceptedAt': 'accepted_at',
    'startedAt': 'started_at',
    'completedAt': 'completed_at',
    'cancelledAt': 'cancelled_at',
    'cancelReason': 'cancel_reason',
    'paymentMethod': 'payment_method',
    'paymentStatus': 'payment_status',
    'distanceM': 'distance_m',
    'durationS': 'duration_s',
    'routePolyline': 'route_polyline',
    'passengerNote': 'passenger_note',
  },
);

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$RideStatusEnumMap[instance.status]!,
  'region_id': instance.regionId,
  'pickup': instance.pickup.toJson(),
  'destination': instance.destination.toJson(),
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'requested_at': instance.requestedAt.toIso8601String(),
  'accepted_at': instance.acceptedAt?.toIso8601String(),
  'started_at': instance.startedAt?.toIso8601String(),
  'completed_at': instance.completedAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'cancel_reason': instance.cancelReason,
  'price': instance.price,
  'currency': ?instance.currency,
  'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'distance_m': instance.distanceM,
  'duration_s': instance.durationS,
  'route_polyline': instance.routePolyline,
  'passenger_note': instance.passengerNote,
  'driver': instance.driver?.toJson(),
  'passenger': instance.passenger?.toJson(),
};

const _$RideStatusEnumMap = {
  RideStatus.requested: 'requested',
  RideStatus.scheduled: 'scheduled',
  RideStatus.dispatching: 'dispatching',
  RideStatus.accepted: 'accepted',
  RideStatus.driverArriving: 'driver_arriving',
  RideStatus.arrived: 'arrived',
  RideStatus.inProgress: 'in_progress',
  RideStatus.completed: 'completed',
  RideStatus.cancelledByPassenger: 'cancelled_by_passenger',
  RideStatus.cancelledByDriver: 'cancelled_by_driver',
  RideStatus.noDriver: 'no_driver',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.card: 'card',
  PaymentMethod.blik: 'blik',
  PaymentMethod.cash: 'cash',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.authorized: 'authorized',
  PaymentStatus.paid: 'paid',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cashDue: 'cash_due',
  PaymentStatus.cashCollected: 'cash_collected',
};
