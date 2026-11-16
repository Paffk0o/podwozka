//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DriverRideAction {
  @JsonValue(r'depart')
  depart(r'depart'),
  @JsonValue(r'arrived')
  arrived(r'arrived'),
  @JsonValue(r'start')
  start(r'start'),
  @JsonValue(r'complete')
  complete(r'complete');

  const DriverRideAction(this.value);

  final String value;

  @override
  String toString() => value;
}
