// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_upload_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentUploadRequestCWProxy {
  DocumentUploadRequest type(DocumentType type);

  DocumentUploadRequest contentType(String contentType);

  DocumentUploadRequest sizeBytes(int sizeBytes);

  DocumentUploadRequest expiresOn(DateTime? expiresOn);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DocumentUploadRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DocumentUploadRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  DocumentUploadRequest call({
    DocumentType type,
    String contentType,
    int sizeBytes,
    DateTime? expiresOn,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDocumentUploadRequest.copyWith(...)` or call `instanceOfDocumentUploadRequest.copyWith.fieldName(value)` for a single field.
class _$DocumentUploadRequestCWProxyImpl
    implements _$DocumentUploadRequestCWProxy {
  const _$DocumentUploadRequestCWProxyImpl(this._value);

  final DocumentUploadRequest _value;

  @override
  DocumentUploadRequest type(DocumentType type) => call(type: type);

  @override
  DocumentUploadRequest contentType(String contentType) =>
      call(contentType: contentType);

  @override
  DocumentUploadRequest sizeBytes(int sizeBytes) => call(sizeBytes: sizeBytes);

  @override
  DocumentUploadRequest expiresOn(DateTime? expiresOn) =>
      call(expiresOn: expiresOn);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DocumentUploadRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DocumentUploadRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DocumentUploadRequest call({
    Object? type = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? expiresOn = const $CopyWithPlaceholder(),
  }) {
    return DocumentUploadRequest(
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DocumentType,
      contentType:
          contentType == const $CopyWithPlaceholder() || contentType == null
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder() || sizeBytes == null
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      expiresOn: expiresOn == const $CopyWithPlaceholder()
          ? _value.expiresOn
          // ignore: cast_nullable_to_non_nullable
          : expiresOn as DateTime?,
    );
  }
}

extension $DocumentUploadRequestCopyWith on DocumentUploadRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDocumentUploadRequest.copyWith(...)` or `instanceOfDocumentUploadRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentUploadRequestCWProxy get copyWith =>
      _$DocumentUploadRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentUploadRequest _$DocumentUploadRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DocumentUploadRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['type', 'content_type', 'size_bytes'],
    );
    final val = DocumentUploadRequest(
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$DocumentTypeEnumMap, v),
      ),
      contentType: $checkedConvert('content_type', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      expiresOn: $checkedConvert(
        'expires_on',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'contentType': 'content_type',
    'sizeBytes': 'size_bytes',
    'expiresOn': 'expires_on',
  },
);

Map<String, dynamic> _$DocumentUploadRequestToJson(
  DocumentUploadRequest instance,
) => <String, dynamic>{
  'type': _$DocumentTypeEnumMap[instance.type]!,
  'content_type': instance.contentType,
  'size_bytes': instance.sizeBytes,
  'expires_on': ?instance.expiresOn?.toIso8601String(),
};

const _$DocumentTypeEnumMap = {
  DocumentType.drivingLicense: 'driving_license',
  DocumentType.vehicleRegistration: 'vehicle_registration',
  DocumentType.insuranceOc: 'insurance_oc',
  DocumentType.driverPhoto: 'driver_photo',
};
