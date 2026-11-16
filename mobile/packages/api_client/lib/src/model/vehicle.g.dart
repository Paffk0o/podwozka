// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VehicleCWProxy {
  Vehicle make(String make);

  Vehicle model(String model);

  Vehicle color(String color);

  Vehicle plate(String plate);

  Vehicle seats(int? seats);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Vehicle(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Vehicle(...).copyWith(id: 12, name: "My name")
  /// ```
  Vehicle call({
    String make,
    String model,
    String color,
    String plate,
    int? seats,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfVehicle.copyWith(...)` or call `instanceOfVehicle.copyWith.fieldName(value)` for a single field.
class _$VehicleCWProxyImpl implements _$VehicleCWProxy {
  const _$VehicleCWProxyImpl(this._value);

  final Vehicle _value;

  @override
  Vehicle make(String make) => call(make: make);

  @override
  Vehicle model(String model) => call(model: model);

  @override
  Vehicle color(String color) => call(color: color);

  @override
  Vehicle plate(String plate) => call(plate: plate);

  @override
  Vehicle seats(int? seats) => call(seats: seats);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `Vehicle(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Vehicle(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  Vehicle call({
    Object? make = const $CopyWithPlaceholder(),
    Object? model = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? plate = const $CopyWithPlaceholder(),
    Object? seats = const $CopyWithPlaceholder(),
  }) {
    return Vehicle(
      make: make == const $CopyWithPlaceholder() || make == null
          ? _value.make
          // ignore: cast_nullable_to_non_nullable
          : make as String,
      model: model == const $CopyWithPlaceholder() || model == null
          ? _value.model
          // ignore: cast_nullable_to_non_nullable
          : model as String,
      color: color == const $CopyWithPlaceholder() || color == null
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as String,
      plate: plate == const $CopyWithPlaceholder() || plate == null
          ? _value.plate
          // ignore: cast_nullable_to_non_nullable
          : plate as String,
      seats: seats == const $CopyWithPlaceholder()
          ? _value.seats
          // ignore: cast_nullable_to_non_nullable
          : seats as int?,
    );
  }
}

extension $VehicleCopyWith on Vehicle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfVehicle.copyWith(...)` or `instanceOfVehicle.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VehicleCWProxy get copyWith => _$VehicleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Vehicle', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['make', 'model', 'color', 'plate']);
      final val = Vehicle(
        make: $checkedConvert('make', (v) => v as String),
        model: $checkedConvert('model', (v) => v as String),
        color: $checkedConvert('color', (v) => v as String),
        plate: $checkedConvert('plate', (v) => v as String),
        seats: $checkedConvert('seats', (v) => (v as num?)?.toInt() ?? 4),
      );
      return val;
    });

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'make': instance.make,
  'model': instance.model,
  'color': instance.color,
  'plate': instance.plate,
  'seats': ?instance.seats,
};
