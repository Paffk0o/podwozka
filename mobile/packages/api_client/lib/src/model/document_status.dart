//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DocumentStatus {
  @JsonValue(r'awaiting_upload')
  awaitingUpload(r'awaiting_upload'),
  @JsonValue(r'uploaded')
  uploaded(r'uploaded'),
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'rejected')
  rejected(r'rejected');

  const DocumentStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
