//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/ride.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ride_page.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RidePage {
  /// Returns a new [RidePage] instance.
  RidePage({
    required this.items,

    required this.total,

    required this.limit,

    required this.offset,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<Ride> items;

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @JsonKey(name: r'limit', required: true, includeIfNull: false)
  final int limit;

  @JsonKey(name: r'offset', required: true, includeIfNull: false)
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RidePage &&
          other.items == items &&
          other.total == total &&
          other.limit == limit &&
          other.offset == offset;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + limit.hashCode + offset.hashCode;

  factory RidePage.fromJson(Map<String, dynamic> json) =>
      _$RidePageFromJson(json);

  Map<String, dynamic> toJson() => _$RidePageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
