// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_upload_slot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentUploadSlotCWProxy {
  DocumentUploadSlot documentId(String documentId);

  DocumentUploadSlot uploadUrl(String uploadUrl);

  DocumentUploadSlot requiredHeaders(Map<String, String> requiredHeaders);

  DocumentUploadSlot expiresAt(DateTime expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DocumentUploadSlot(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DocumentUploadSlot(...).copyWith(id: 12, name: "My name")
  /// ```
  DocumentUploadSlot call({
    String documentId,
    String uploadUrl,
    Map<String, String> requiredHeaders,
    DateTime expiresAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDocumentUploadSlot.copyWith(...)` or call `instanceOfDocumentUploadSlot.copyWith.fieldName(value)` for a single field.
class _$DocumentUploadSlotCWProxyImpl implements _$DocumentUploadSlotCWProxy {
  const _$DocumentUploadSlotCWProxyImpl(this._value);

  final DocumentUploadSlot _value;

  @override
  DocumentUploadSlot documentId(String documentId) =>
      call(documentId: documentId);

  @override
  DocumentUploadSlot uploadUrl(String uploadUrl) => call(uploadUrl: uploadUrl);

  @override
  DocumentUploadSlot requiredHeaders(Map<String, String> requiredHeaders) =>
      call(requiredHeaders: requiredHeaders);

  @override
  DocumentUploadSlot expiresAt(DateTime expiresAt) =>
      call(expiresAt: expiresAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DocumentUploadSlot(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DocumentUploadSlot(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DocumentUploadSlot call({
    Object? documentId = const $CopyWithPlaceholder(),
    Object? uploadUrl = const $CopyWithPlaceholder(),
    Object? requiredHeaders = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return DocumentUploadSlot(
      documentId:
          documentId == const $CopyWithPlaceholder() || documentId == null
          ? _value.documentId
          // ignore: cast_nullable_to_non_nullable
          : documentId as String,
      uploadUrl: uploadUrl == const $CopyWithPlaceholder() || uploadUrl == null
          ? _value.uploadUrl
          // ignore: cast_nullable_to_non_nullable
          : uploadUrl as String,
      requiredHeaders:
          requiredHeaders == const $CopyWithPlaceholder() ||
              requiredHeaders == null
          ? _value.requiredHeaders
          // ignore: cast_nullable_to_non_nullable
          : requiredHeaders as Map<String, String>,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
    );
  }
}

extension $DocumentUploadSlotCopyWith on DocumentUploadSlot {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDocumentUploadSlot.copyWith(...)` or `instanceOfDocumentUploadSlot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentUploadSlotCWProxy get copyWith =>
      _$DocumentUploadSlotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentUploadSlot _$DocumentUploadSlotFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DocumentUploadSlot',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'document_id',
            'upload_url',
            'required_headers',
            'expires_at',
          ],
        );
        final val = DocumentUploadSlot(
          documentId: $checkedConvert('document_id', (v) => v as String),
          uploadUrl: $checkedConvert('upload_url', (v) => v as String),
          requiredHeaders: $checkedConvert(
            'required_headers',
            (v) => Map<String, String>.from(v as Map),
          ),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'documentId': 'document_id',
        'uploadUrl': 'upload_url',
        'requiredHeaders': 'required_headers',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$DocumentUploadSlotToJson(DocumentUploadSlot instance) =>
    <String, dynamic>{
      'document_id': instance.documentId,
      'upload_url': instance.uploadUrl,
      'required_headers': instance.requiredHeaders,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
