//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/place.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quote_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QuoteRequest {
  /// Returns a new [QuoteRequest] instance.
  QuoteRequest({
    required this.pickup,

    required this.destination,

    this.scheduledAt,
  });

  @JsonKey(name: r'pickup', required: true, includeIfNull: false)
  final Place pickup;

  @JsonKey(name: r'destination', required: true, includeIfNull: false)
  final Place destination;

  /// Brak = kurs teraz; data = rezerwacja (min. 30 min, max. 14 dni)
  @JsonKey(name: r'scheduled_at', required: false, includeIfNull: false)
  final DateTime? scheduledAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteRequest &&
          other.pickup == pickup &&
          other.destination == destination &&
          other.scheduledAt == scheduledAt;

  @override
  int get hashCode =>
      pickup.hashCode +
      destination.hashCode +
      (scheduledAt == null ? 0 : scheduledAt.hashCode);

  factory QuoteRequest.fromJson(Map<String, dynamic> json) =>
      _$QuoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
