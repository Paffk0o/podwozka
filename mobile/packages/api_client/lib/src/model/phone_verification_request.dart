//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phone_verification_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PhoneVerificationRequest {
  /// Returns a new [PhoneVerificationRequest] instance.
  PhoneVerificationRequest({required this.phone});

  /// Numer w formacie E.164, np. +48600100200
  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneVerificationRequest && other.phone == phone;

  @override
  int get hashCode => phone.hashCode;

  factory PhoneVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneVerificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneVerificationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
