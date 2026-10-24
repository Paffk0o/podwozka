//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/vehicle.dart';
import 'package:podwozka_api/src/model/driver_document.dart';
import 'package:podwozka_api/src/model/driver_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_driver.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminDriver {
  /// Returns a new [AdminDriver] instance.
  AdminDriver({
    required this.userId,

    required this.status,

    required this.regionId,

    required this.vehicle,

    required this.documents,

    required this.rejectionReason,

    required this.ratingAvg,

    required this.online,

    required this.approvedAt,

    required this.fullName,

    required this.email,

    required this.phone,

    required this.submittedAt,
  });

  @JsonKey(name: r'user_id', required: true, includeIfNull: false)
  final String userId;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final DriverStatus status;

  @JsonKey(name: r'region_id', required: true, includeIfNull: false)
  final String regionId;

  @JsonKey(name: r'vehicle', required: true, includeIfNull: false)
  final Vehicle vehicle;

  @JsonKey(name: r'documents', required: true, includeIfNull: false)
  final List<DriverDocument> documents;

  @JsonKey(name: r'rejection_reason', required: true, includeIfNull: true)
  final String? rejectionReason;

  @JsonKey(name: r'rating_avg', required: true, includeIfNull: true)
  final num? ratingAvg;

  @JsonKey(name: r'online', required: true, includeIfNull: false)
  final bool online;

  @JsonKey(name: r'approved_at', required: true, includeIfNull: true)
  final DateTime? approvedAt;

  @JsonKey(name: r'full_name', required: true, includeIfNull: true)
  final String? fullName;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'phone', required: true, includeIfNull: true)
  final String? phone;

  @JsonKey(name: r'submitted_at', required: true, includeIfNull: true)
  final DateTime? submittedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDriver &&
          other.userId == userId &&
          other.status == status &&
          other.regionId == regionId &&
          other.vehicle == vehicle &&
          other.documents == documents &&
          other.rejectionReason == rejectionReason &&
          other.ratingAvg == ratingAvg &&
          other.online == online &&
          other.approvedAt == approvedAt &&
          other.fullName == fullName &&
          other.email == email &&
          other.phone == phone &&
          other.submittedAt == submittedAt;

  @override
  int get hashCode =>
      userId.hashCode +
      status.hashCode +
      regionId.hashCode +
      vehicle.hashCode +
      documents.hashCode +
      (rejectionReason == null ? 0 : rejectionReason.hashCode) +
      (ratingAvg == null ? 0 : ratingAvg.hashCode) +
      online.hashCode +
      (approvedAt == null ? 0 : approvedAt.hashCode) +
      (fullName == null ? 0 : fullName.hashCode) +
      (email == null ? 0 : email.hashCode) +
      (phone == null ? 0 : phone.hashCode) +
      (submittedAt == null ? 0 : submittedAt.hashCode);

  factory AdminDriver.fromJson(Map<String, dynamic> json) =>
      _$AdminDriverFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDriverToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
