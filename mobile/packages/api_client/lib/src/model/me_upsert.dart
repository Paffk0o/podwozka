//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_upsert.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeUpsert {
  /// Returns a new [MeUpsert] instance.
  MeUpsert({this.fullName, this.phone});

  @JsonKey(name: r'full_name', required: false, includeIfNull: false)
  final String? fullName;

  /// Numer w formacie E.164, np. +48600100200
  @JsonKey(name: r'phone', required: false, includeIfNull: false)
  final String? phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeUpsert && other.fullName == fullName && other.phone == phone;

  @override
  int get hashCode =>
      (fullName == null ? 0 : fullName.hashCode) +
      (phone == null ? 0 : phone.hashCode);

  factory MeUpsert.fromJson(Map<String, dynamic> json) =>
      _$MeUpsertFromJson(json);

  Map<String, dynamic> toJson() => _$MeUpsertToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
