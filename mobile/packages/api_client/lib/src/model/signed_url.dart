//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signed_url.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SignedUrl {
  /// Returns a new [SignedUrl] instance.
  SignedUrl({required this.url, required this.expiresAt});

  @JsonKey(name: r'url', required: true, includeIfNull: false)
  final String url;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignedUrl && other.url == url && other.expiresAt == expiresAt;

  @override
  int get hashCode => url.hashCode + expiresAt.hashCode;

  factory SignedUrl.fromJson(Map<String, dynamic> json) =>
      _$SignedUrlFromJson(json);

  Map<String, dynamic> toJson() => _$SignedUrlToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
