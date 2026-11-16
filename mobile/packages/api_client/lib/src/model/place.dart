//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/geo_point.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Place {
  /// Returns a new [Place] instance.
  Place({required this.location, required this.address, this.placeId});

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final GeoPoint location;

  @JsonKey(name: r'address', required: true, includeIfNull: false)
  final String address;

  /// Google Places ID, jeśli znany
  @JsonKey(name: r'place_id', required: false, includeIfNull: false)
  final String? placeId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place &&
          other.location == location &&
          other.address == address &&
          other.placeId == placeId;

  @override
  int get hashCode =>
      location.hashCode +
      address.hashCode +
      (placeId == null ? 0 : placeId.hashCode);

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
