// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DriverProfileCWProxy {
  DriverProfile userId(String userId);

  DriverProfile status(DriverStatus status);

  DriverProfile regionId(String regionId);

  DriverProfile vehicle(Vehicle vehicle);

  DriverProfile documents(List<DriverDocument> documents);

  DriverProfile rejectionReason(String? rejectionReason);

  DriverProfile ratingAvg(num? ratingAvg);

  DriverProfile online(bool online);

  DriverProfile approvedAt(DateTime? approvedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverProfile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverProfile(...).copyWith(id: 12, name: "My name")
  /// ```
  DriverProfile call({
    String userId,
    DriverStatus status,
    String regionId,
    Vehicle vehicle,
    List<DriverDocument> documents,
    String? rejectionReason,
    num? ratingAvg,
    bool online,
    DateTime? approvedAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDriverProfile.copyWith(...)` or call `instanceOfDriverProfile.copyWith.fieldName(value)` for a single field.
class _$DriverProfileCWProxyImpl implements _$DriverProfileCWProxy {
  const _$DriverProfileCWProxyImpl(this._value);

  final DriverProfile _value;

  @override
  DriverProfile userId(String userId) => call(userId: userId);

  @override
  DriverProfile status(DriverStatus status) => call(status: status);

  @override
  DriverProfile regionId(String regionId) => call(regionId: regionId);

  @override
  DriverProfile vehicle(Vehicle vehicle) => call(vehicle: vehicle);

  @override
  DriverProfile documents(List<DriverDocument> documents) =>
      call(documents: documents);

  @override
  DriverProfile rejectionReason(String? rejectionReason) =>
      call(rejectionReason: rejectionReason);

  @override
  DriverProfile ratingAvg(num? ratingAvg) => call(ratingAvg: ratingAvg);

  @override
  DriverProfile online(bool online) => call(online: online);

  @override
  DriverProfile approvedAt(DateTime? approvedAt) =>
      call(approvedAt: approvedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `DriverProfile(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DriverProfile(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  DriverProfile call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? regionId = const $CopyWithPlaceholder(),
    Object? vehicle = const $CopyWithPlaceholder(),
    Object? documents = const $CopyWithPlaceholder(),
    Object? rejectionReason = const $CopyWithPlaceholder(),
    Object? ratingAvg = const $CopyWithPlaceholder(),
    Object? online = const $CopyWithPlaceholder(),
    Object? approvedAt = const $CopyWithPlaceholder(),
  }) {
    return DriverProfile(
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
    );
  }
}

extension $DriverProfileCopyWith on DriverProfile {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDriverProfile.copyWith(...)` or `instanceOfDriverProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DriverProfileCWProxy get copyWith => _$DriverProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DriverProfile',
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
          ],
        );
        final val = DriverProfile(
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
          rejectionReason: $checkedConvert(
            'rejection_reason',
            (v) => v as String?,
          ),
          ratingAvg: $checkedConvert('rating_avg', (v) => v as num?),
          online: $checkedConvert('online', (v) => v as bool),
          approvedAt: $checkedConvert(
            'approved_at',
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
      },
    );

Map<String, dynamic> _$DriverProfileToJson(DriverProfile instance) =>
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
    };

const _$DriverStatusEnumMap = {
  DriverStatus.draft: 'draft',
  DriverStatus.pending: 'pending',
  DriverStatus.approved: 'approved',
  DriverStatus.rejected: 'rejected',
  DriverStatus.suspended: 'suspended',
};
