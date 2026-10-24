//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/document_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_upload_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DocumentUploadRequest {
  /// Returns a new [DocumentUploadRequest] instance.
  DocumentUploadRequest({
    required this.type,

    required this.contentType,

    required this.sizeBytes,

    this.expiresOn,
  });

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final DocumentType type;

  @JsonKey(name: r'content_type', required: true, includeIfNull: false)
  final String contentType;

  /// Maks. 10 MB
  // minimum: 0
  // maximum: 10485760
  @JsonKey(name: r'size_bytes', required: true, includeIfNull: false)
  final int sizeBytes;

  /// Data ważności dokumentu
  @JsonKey(name: r'expires_on', required: false, includeIfNull: false)
  final DateTime? expiresOn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentUploadRequest &&
          other.type == type &&
          other.contentType == contentType &&
          other.sizeBytes == sizeBytes &&
          other.expiresOn == expiresOn;

  @override
  int get hashCode =>
      type.hashCode +
      contentType.hashCode +
      sizeBytes.hashCode +
      (expiresOn == null ? 0 : expiresOn.hashCode);

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentUploadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
