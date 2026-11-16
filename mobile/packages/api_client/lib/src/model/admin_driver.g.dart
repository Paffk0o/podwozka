// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_driver.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminDriverCWProxy {
  AdminDriver userId(String userId);

  AdminDriver status(DriverStatus status);

  AdminDriver regionId(String regionId);

  AdminDriver vehicle(Vehicle vehicle);

  AdminDriver documents(List<DriverDocument> documents);

  AdminDriver rejectionReason(String? rejectionReason);

  AdminDriver ratingAvg(num? ratingAvg);

  AdminDriver online(bool online);

  AdminDriver approvedAt(DateTime? approvedAt);

  AdminDriver fullName(String? fullName);

  AdminDriver email(String? email);

  AdminDriver phone(String? phone);

  AdminDriver submittedAt(DateTime? submittedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AdminDriver(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AdminDriver(...).copyWith(id: 12, name: "My name")
  /// ```
  AdminDriver call({
    String userId,
    DriverStatus status,
    String regionId,
    Vehicle vehicle,
    List<DriverDocument> documents,
    String? rejectionReason,
    num? ratingAvg,
    bool online,
    DateTime? approvedAt,
    String? fullName,
    String? email,
    String? phone,
    DateTime? submittedAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAdminDriver.copyWith(...)` or call `instanceOfAdminDriver.copyWith.fieldName(value)` for a single field.
class _$AdminDriverCWProxyImpl implements _$AdminDriverCWProxy {
  const _$AdminDriverCWProxyImpl(this._value);

  final AdminDriver _value;

  @override
  AdminDriver userId(String userId) => call(userId: userId);

  @override
  AdminDriver status(DriverStatus status) => call(status: status);

  @override
  AdminDriver regionId(String regionId) => call(regionId: regionId);

  @override
  AdminDriver vehicle(Vehicle vehicle) => call(vehicle: vehicle);

  @override
  AdminDriver documents(List<DriverDocument> documents) =>
      call(documents: documents);

  @override
  AdminDriver rejectionReason(String? rejectionReason) =>
      call(rejectionReason: rejectionReason);

  @override
  AdminDriver ratingAvg(num? ratingAvg) => call(ratingAvg: ratingAvg);

  @override
  AdminDriver online(bool online) => call(online: online);

  @override
  AdminDriver approvedAt(DateTime? approvedAt) => call(approvedAt: approvedAt);

  @override
  AdminDriver fullName(String? fullName) => call(fullName: fullName);

  @override
  AdminDriver email(String? email) => call(email: email);

  @override
  AdminDriver phone(String? phone) => call(phone: phone);

  @override
  AdminDriver submittedAt(DateTime? submittedAt) =>
      call(submittedAt: submittedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `AdminDriver(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AdminDriver(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AdminDriver call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? regionId = const $CopyWithPlaceholder(),
    Object? vehicle = const $CopyWithPlaceholder(),
    Object? documents = const $CopyWithPlaceholder(),
    Object? rejectionReason = const $CopyWithPlaceholder(),
    Object? ratingAvg = const $CopyWithPlaceholder(),
    Object? online = const $CopyWithPlaceholder(),
    Object? approvedAt = const $CopyWithPlaceholder(),
    Object? fullName = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? submittedAt = const $CopyWithPlaceholder(),
  }) {
    return AdminDriver(
      userId: userId == const $CopyWithPlaceholder() || userId == null
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as DriverStatus,
      regionId: regionId == const $CopyWithPlaceholder() || regionId == null
          ? _value.regionId
          // ignore: cast_nullable_to_non_nullable
          : regionId as String,
      vehicle: vehicle == const $CopyWithPlaceholder() || vehicle == null
          ? _value.vehicle
          // ignore: cast_nullable_to_non_nullable
          : vehicle as Vehicle,
      documents: documents == const $CopyWithPlaceholder() || documents == null
          ? _value.documents
          // ignore: cast_nullable_to_non_nullable
          : documents as List<DriverDocument>,
      rejectionReason: rejectionReason == const $CopyWithPlaceholder()
          ? _value.rejectionReason
          // ignore: cast_nullable_to_non_nullable
          : rejectionReason as String?,
      ratingAvg: ratingAvg == const $CopyWithPlaceholder()
          ? _value.ratingAvg
          // ignore: cast_nullable_to_non_nullable
          : ratingAvg as num?,
      online: online == const $CopyWithPlaceholder() || online == null
          ? _value.online
          // ignore: cast_nullable_to_non_nullable
          : online as bool,
      approvedAt: approvedAt == const $CopyWithPlaceholder()
          ? _value.approvedAt
          // ignore: cast_nullable_to_non_nullable
          : approvedAt as DateTime?,
      fullName: fullName == const $CopyWithPlaceholder()
          ? _value.fullName
          // ignore: cast_nullable_to_non_nullable
          : fullName as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      submittedAt: submittedAt == const $CopyWithPlaceholder()
          ? _value.submittedAt
          // ignore: cast_nullable_to_non_nullable
          : submittedAt as DateTime?,
    );
  }
}

extension $AdminDriverCopyWith on AdminDriver {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAdminDriver.copyWith(...)` or `instanceOfAdminDriver.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminDriverCWProxy get copyWith => _$AdminDriverCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminDriver _$AdminDriverFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AdminDriver',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'user_id',
        'status',
        'region_id',
        'vehicle',
        'documents',
        'rejection_reason',
        'rating_avg',
        'online',
        'approved_at',
        'full_name',
        'email',
        'phone',
        'submitted_at',
      ],
    );
    final val = AdminDriver(
      userId: $checkedConvert('user_id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$DriverStatusEnumMap, v),
      ),
      regionId: $checkedConvert('region_id', (v) => v as String),
      vehicle: $checkedConvert(
        'vehicle',
        (v) => Vehicle.fromJson(v as Map<String, dynamic>),
      ),
      documents: $checkedConvert(
        'documents',
        (v) => (v as List<dynamic>)
            .map((e) => DriverDocument.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      rejectionReason: $checkedConvert('rejection_reason', (v) => v as String?),
      ratingAvg: $checkedConvert('rating_avg', (v) => v as num?),
      online: $checkedConvert('online', (v) => v as bool),
      approvedAt: $checkedConvert(
        'approved_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      fullName: $checkedConvert('full_name', (v) => v as String?),
      email: $checkedConvert('email', (v) => v as String?),
      phone: $checkedConvert('phone', (v) => v as String?),
      submittedAt: $checkedConvert(
        'submitted_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'userId': 'user_id',
    'regionId': 'region_id',
    'rejectionReason': 'rejection_reason',
    'ratingAvg': 'rating_avg',
    'approvedAt': 'approved_at',
    'fullName': 'full_name',
    'submittedAt': 'submitted_at',
  },
);

Map<String, dynamic> _$AdminDriverToJson(AdminDriver instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'status': _$DriverStatusEnumMap[instance.status]!,
      'region_id': instance.regionId,
      'vehicle': instance.vehicle.toJson(),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
      'rejection_reason': instance.rejectionReason,
      'rating_avg': instance.ratingAvg,
      'online': instance.online,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'full_name': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'submitted_at': instance.submittedAt?.toIso8601String(),
    };

const _$DriverStatusEnumMap = {
  DriverStatus.draft: 'draft',
  DriverStatus.pending: 'pending',
  DriverStatus.approved: 'approved',
  DriverStatus.rejected: 'rejected',
  DriverStatus.suspended: 'suspended',
};
