//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_upload_slot.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentUploadSlot {
  /// Returns a new [DocumentUploadSlot] instance.
  DocumentUploadSlot({
    required this.documentId,

    required this.uploadUrl,

    required this.requiredHeaders,

    required this.expiresAt,
  });

  @JsonKey(name: r'document_id', required: true, includeIfNull: false)
  final String documentId;

  @JsonKey(name: r'upload_url', required: true, includeIfNull: false)
  final String uploadUrl;

  /// Np. {\"x-ms-blob-type\": \"BlockBlob\", \"Content-Type\": \"image/jpeg\"}
  @JsonKey(name: r'required_headers', required: true, includeIfNull: false)
  final Map<String, String> requiredHeaders;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentUploadSlot &&
          other.documentId == documentId &&
          other.uploadUrl == uploadUrl &&
          other.requiredHeaders == requiredHeaders &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      documentId.hashCode +
      uploadUrl.hashCode +
      requiredHeaders.hashCode +
      expiresAt.hashCode;

  factory DocumentUploadSlot.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadSlotFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentUploadSlotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
