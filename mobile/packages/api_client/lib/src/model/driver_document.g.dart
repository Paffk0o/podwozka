// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_document.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DriverDocumentCWProxy {
  DriverDocument id(String id);

  DriverDocument type(DocumentType type);

  DriverDocument status(DocumentStatus status);

  DriverDocument contentType(String contentType);

  DriverDocument expiresOn(DateTime? expiresOn);

  DriverDocument uploadedAt(DateTime? uploadedAt);

  DriverDocument reviewComment(String? reviewComment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverDocument(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverDocument(...).copyWith(id: 12, name: "My name")
  /// ```
  DriverDocument call({
    String id,
    DocumentType type,
    DocumentStatus status,
    String contentType,
    DateTime? expiresOn,
    DateTime? uploadedAt,
    String? reviewComment,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDriverDocument.copyWith(...)` or call `instanceOfDriverDocument.copyWith.fieldName(value)` for a single field.
class _$DriverDocumentCWProxyImpl implements _$DriverDocumentCWProxy {
  const _$DriverDocumentCWProxyImpl(this._value);

  final DriverDocument _value;

  @override
  DriverDocument id(String id) => call(id: id);

  @override
  DriverDocument type(DocumentType type) => call(type: type);

  @override
  DriverDocument status(DocumentStatus status) => call(status: status);

  @override
  DriverDocument contentType(String contentType) =>
      call(contentType: contentType);

  @override
  DriverDocument expiresOn(DateTime? expiresOn) => call(expiresOn: expiresOn);

  @override
  DriverDocument uploadedAt(DateTime? uploadedAt) =>
      call(uploadedAt: uploadedAt);

  @override
  DriverDocument reviewComment(String? reviewComment) =>
      call(reviewComment: reviewComment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverDocument(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverDocument(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DriverDocument call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? expiresOn = const $CopyWithPlaceholder(),
    Object? uploadedAt = const $CopyWithPlaceholder(),
    Object? reviewComment = const $CopyWithPlaceholder(),
  }) {
    return DriverDocument(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DocumentType,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DocumentStatus,
      contentType:
          contentType == const $CopyWithPlaceholder() || contentType == null
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String,
      expiresOn: expiresOn == const $CopyWithPlaceholder()
          ? _value.expiresOn
          // ignore: cast_nullable_to_non_nullable
          : expiresOn as DateTime?,
      uploadedAt: uploadedAt == const $CopyWithPlaceholder()
          ? _value.uploadedAt
          // ignore: cast_nullable_to_non_nullable
          : uploadedAt as DateTime?,
      reviewComment: reviewComment == const $CopyWithPlaceholder()
          ? _value.reviewComment
          // ignore: cast_nullable_to_non_nullable
          : reviewComment as String?,
    );
  }
}

extension $DriverDocumentCopyWith on DriverDocument {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDriverDocument.copyWith(...)` or `instanceOfDriverDocument.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DriverDocumentCWProxy get copyWith => _$DriverDocumentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDocument _$DriverDocumentFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DriverDocument',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'type',
            'status',
            'content_type',
            'expires_on',
            'uploaded_at',
            'review_comment',
          ],
        );
        final val = DriverDocument(
          id: $checkedConvert('id', (v) => v as String),
          type: $checkedConvert(
            'type',
            (v) => $enumDecode(_$DocumentTypeEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$DocumentStatusEnumMap, v),
          ),
          contentType: $checkedConvert('content_type', (v) => v as String),
          expiresOn: $checkedConvert(
            'expires_on',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          uploadedAt: $checkedConvert(
            'uploaded_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          reviewComment: $checkedConvert('review_comment', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'contentType': 'content_type',
        'expiresOn': 'expires_on',
        'uploadedAt': 'uploaded_at',
        'reviewComment': 'review_comment',
      },
    );

Map<String, dynamic> _$DriverDocumentToJson(DriverDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'content_type': instance.contentType,
      'expires_on': instance.expiresOn?.toIso8601String(),
      'uploaded_at': instance.uploadedAt?.toIso8601String(),
      'review_comment': instance.reviewComment,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.drivingLicense: 'driving_license',
  DocumentType.vehicleRegistration: 'vehicle_registration',
  DocumentType.insuranceOc: 'insurance_oc',
  DocumentType.driverPhoto: 'driver_photo',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.awaitingUpload: 'awaiting_upload',
  DocumentStatus.uploaded: 'uploaded',
  DocumentStatus.accepted: 'accepted',
  DocumentStatus.rejected: 'rejected',
};
