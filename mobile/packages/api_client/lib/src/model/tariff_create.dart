//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tariff_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TariffCreate {
  /// Returns a new [TariffCreate] instance.
  TariffCreate({
    required this.baseFare,

    required this.perKm,

    required this.perMinute,

    required this.minimumFare,

    this.nightMultiplierPercent = 100,

    this.nightStartHour = 22,

    this.nightEndHour = 6,

    this.commissionPercent = 10,

    this.validFrom,
  });

  /// Opłata startowa
  // minimum: 0
  @JsonKey(name: r'base_fare', required: true, includeIfNull: false)
  final int baseFare;

  /// Stawka za km
  // minimum: 0
  @JsonKey(name: r'per_km', required: true, includeIfNull: false)
  final int perKm;

  /// Stawka za minutę jazdy
  // minimum: 0
  @JsonKey(name: r'per_minute', required: true, includeIfNull: false)
  final int perMinute;

  /// Cena minimalna kursu
  // minimum: 0
  @JsonKey(name: r'minimum_fare', required: true, includeIfNull: false)
  final int minimumFare;

  /// Mnożnik nocny w procentach (np. 120 = +20%)
  // minimum: 100
  // maximum: 300
  @JsonKey(
    defaultValue: 100,
    name: r'night_multiplier_percent',
    required: false,
    includeIfNull: false,
  )
  final int? nightMultiplierPercent;

  // minimum: 0
  // maximum: 23
  @JsonKey(
    defaultValue: 22,
    name: r'night_start_hour',
    required: false,
    includeIfNull: false,
  )
  final int? nightStartHour;

  // minimum: 0
  // maximum: 23
  @JsonKey(
    defaultValue: 6,
    name: r'night_end_hour',
    required: false,
    includeIfNull: false,
  )
  final int? nightEndHour;

  /// Prowizja platformy
  // minimum: 0
  // maximum: 50
  @JsonKey(
    defaultValue: 10,
    name: r'commission_percent',
    required: false,
    includeIfNull: false,
  )
  final int? commissionPercent;

  /// Domyślnie: teraz
  @JsonKey(name: r'valid_from', required: false, includeIfNull: false)
  final DateTime? validFrom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TariffCreate &&
          other.baseFare == baseFare &&
          other.perKm == perKm &&
          other.perMinute == perMinute &&
          other.minimumFare == minimumFare &&
          other.nightMultiplierPercent == nightMultiplierPercent &&
          other.nightStartHour == nightStartHour &&
          other.nightEndHour == nightEndHour &&
          other.commissionPercent == commissionPercent &&
          other.validFrom == validFrom;

  @override
  int get hashCode =>
      baseFare.hashCode +
      perKm.hashCode +
      perMinute.hashCode +
      minimumFare.hashCode +
      nightMultiplierPercent.hashCode +
      nightStartHour.hashCode +
      nightEndHour.hashCode +
      commissionPercent.hashCode +
      (validFrom == null ? 0 : validFrom.hashCode);

  factory TariffCreate.fromJson(Map<String, dynamic> json) =>
      _$TariffCreateFromJson(json);

  Map<String, dynamic> toJson() => _$TariffCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
