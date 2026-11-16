//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DocumentType {
  @JsonValue(r'driving_license')
  drivingLicense(r'driving_license'),
  @JsonValue(r'vehicle_registration')
  vehicleRegistration(r'vehicle_registration'),
  @JsonValue(r'insurance_oc')
  insuranceOc(r'insurance_oc'),
  @JsonValue(r'driver_photo')
  driverPhoto(r'driver_photo');

  const DocumentType(this.value);

  final String value;

  @override
  String toString() => value;
}
