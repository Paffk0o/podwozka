//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'public_config.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PublicConfig {
  /// Returns a new [PublicConfig] instance.
  PublicConfig({
    required this.oidcIssuer,

    required this.stripePublishableKey,

    this.minAppVersion = '0.1.0',

    this.supportPhone,
  });

  @JsonKey(name: r'oidc_issuer', required: true, includeIfNull: false)
  final String oidcIssuer;

  @JsonKey(name: r'stripe_publishable_key', required: true, includeIfNull: true)
  final String? stripePublishableKey;

  /// Starsze wersje muszą się zaktualizować
  @JsonKey(
    defaultValue: '0.1.0',
    name: r'min_app_version',
    required: false,
    includeIfNull: false,
  )
  final String? minAppVersion;

  @JsonKey(name: r'support_phone', required: false, includeIfNull: false)
  final String? supportPhone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicConfig &&
          other.oidcIssuer == oidcIssuer &&
          other.stripePublishableKey == stripePublishableKey &&
          other.minAppVersion == minAppVersion &&
          other.supportPhone == supportPhone;

  @override
  int get hashCode =>
      oidcIssuer.hashCode +
      (stripePublishableKey == null ? 0 : stripePublishableKey.hashCode) +
      minAppVersion.hashCode +
      (supportPhone == null ? 0 : supportPhone.hashCode);

  factory PublicConfig.fromJson(Map<String, dynamic> json) =>
      _$PublicConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PublicConfigToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
