//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phone_verification_confirm.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PhoneVerificationConfirm {
  /// Returns a new [PhoneVerificationConfirm] instance.
  PhoneVerificationConfirm({required this.code});

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneVerificationConfirm && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory PhoneVerificationConfirm.fromJson(Map<String, dynamic> json) =>
      _$PhoneVerificationConfirmFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneVerificationConfirmToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
