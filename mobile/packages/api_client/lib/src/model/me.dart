//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.id,

    required this.email,

    required this.fullName,

    required this.phone,

    required this.phoneVerified,

    required this.roles,
  });

  /// Identyfikator użytkownika (claim `sub` z Keycloaka)
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'full_name', required: true, includeIfNull: true)
  final String? fullName;

  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @JsonKey(name: r'phone_verified', required: true, includeIfNull: false)
  final bool phoneVerified;

  /// Role realmu: passenger, driver, admin
  @JsonKey(name: r'roles', required: true, includeIfNull: false)
  final List<String> roles;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Me &&
          other.id == id &&
          other.email == email &&
          other.fullName == fullName &&
          other.phone == phone &&
          other.phoneVerified == phoneVerified &&
          other.roles == roles;

  @override
  int get hashCode =>
      id.hashCode +
      (email == null ? 0 : email.hashCode) +
      (fullName == null ? 0 : fullName.hashCode) +
      (phone == null ? 0 : phone.hashCode) +
      phoneVerified.hashCode +
      roles.hashCode;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
