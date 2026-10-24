//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/place.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quote.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Quote {
  /// Returns a new [Quote] instance.
  Quote({
    required this.id,

    required this.regionId,

    required this.regionName,

    required this.pickup,

    required this.destination,

    required this.scheduledAt,

    required this.distanceM,

    required this.durationS,

    required this.price,

    this.currency = 'PLN',

    required this.tariffId,

    required this.routePolyline,

    required this.expiresAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'region_id', required: true, includeIfNull: false)
  final String regionId;

  @JsonKey(name: r'region_name', required: true, includeIfNull: false)
  final String regionName;

  @JsonKey(name: r'pickup', required: true, includeIfNull: false)
  final Place pickup;

  @JsonKey(name: r'destination', required: true, includeIfNull: false)
  final Place destination;

  @JsonKey(name: r'scheduled_at', required: true, includeIfNull: true)
  final DateTime? scheduledAt;

  @JsonKey(name: r'distance_m', required: true, includeIfNull: false)
  final int distanceM;

  @JsonKey(name: r'duration_s', required: true, includeIfNull: false)
  final int durationS;

  /// Kwota w groszach (1 PLN = 100)
  // minimum: 0
  @JsonKey(name: r'price', required: true, includeIfNull: false)
  final int price;

  @JsonKey(
    defaultValue: 'PLN',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )
  final String? currency;

  @JsonKey(name: r'tariff_id', required: true, includeIfNull: false)
  final String tariffId;

  /// Trasa w formacie encoded polyline (Google)
  @JsonKey(name: r'route_polyline', required: true, includeIfNull: true)
  final String? routePolyline;

  /// Wycena ważna do (5 min)
  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          other.id == id &&
          other.regionId == regionId &&
          other.regionName == regionName &&
          other.pickup == pickup &&
          other.destination == destination &&
          other.scheduledAt == scheduledAt &&
          other.distanceM == distanceM &&
          other.durationS == durationS &&
          other.price == price &&
          other.currency == currency &&
          other.tariffId == tariffId &&
          other.routePolyline == routePolyline &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      id.hashCode +
      regionId.hashCode +
      regionName.hashCode +
      pickup.hashCode +
      destination.hashCode +
      (scheduledAt == null ? 0 : scheduledAt.hashCode) +
      distanceM.hashCode +
      durationS.hashCode +
      price.hashCode +
      currency.hashCode +
      tariffId.hashCode +
      (routePolyline == null ? 0 : routePolyline.hashCode) +
      expiresAt.hashCode;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
