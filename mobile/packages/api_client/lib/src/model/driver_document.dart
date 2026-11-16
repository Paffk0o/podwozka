//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/document_status.dart';
import 'package:podwozka_api/src/model/document_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_document.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DriverDocument {
  /// Returns a new [DriverDocument] instance.
  DriverDocument({
    required this.id,

    required this.type,

    required this.status,

    required this.contentType,

    required this.expiresOn,

    required this.uploadedAt,

    required this.reviewComment,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final DocumentType type;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final DocumentStatus status;

  @JsonKey(name: r'content_type', required: true, includeIfNull: false)
  final String contentType;

  @JsonKey(name: r'expires_on', required: true, includeIfNull: true)
  final DateTime? expiresOn;

  @JsonKey(name: r'uploaded_at', required: true, includeIfNull: true)
  final DateTime? uploadedAt;

  @JsonKey(name: r'review_comment', required: true, includeIfNull: true)
  final String? reviewComment;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDocument &&
          other.id == id &&
          other.type == type &&
          other.status == status &&
          other.contentType == contentType &&
          other.expiresOn == expiresOn &&
          other.uploadedAt == uploadedAt &&
          other.reviewComment == reviewComment;

  @override
  int get hashCode =>
      id.hashCode +
      type.hashCode +
      status.hashCode +
      contentType.hashCode +
      (expiresOn == null ? 0 : expiresOn.hashCode) +
      (uploadedAt == null ? 0 : uploadedAt.hashCode) +
      (reviewComment == null ? 0 : reviewComment.hashCode);

  factory DriverDocument.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
