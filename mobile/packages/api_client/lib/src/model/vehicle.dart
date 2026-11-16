//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Vehicle {
  /// Returns a new [Vehicle] instance.
  Vehicle({
    required this.make,

    required this.model,

    required this.color,

    required this.plate,

    this.seats = 4,
  });

  @JsonKey(name: r'make', required: true, includeIfNull: false)
  final String make;

  @JsonKey(name: r'model', required: true, includeIfNull: false)
  final String model;

  @JsonKey(name: r'color', required: true, includeIfNull: false)
  final String color;

  /// Numer rejestracyjny
  @JsonKey(name: r'plate', required: true, includeIfNull: false)
  final String plate;

  // minimum: 1
  // maximum: 8
  @JsonKey(
    defaultValue: 4,
    name: r'seats',
    required: false,
    includeIfNull: false,
  )
  final int? seats;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          other.make == make &&
          other.model == model &&
          other.color == color &&
          other.plate == plate &&
          other.seats == seats;

  @override
  int get hashCode =>
      make.hashCode +
      model.hashCode +
      color.hashCode +
      plate.hashCode +
      seats.hashCode;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
