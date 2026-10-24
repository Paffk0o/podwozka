//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:podwozka_api/src/model/admin_driver.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_driver_page.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminDriverPage {
  /// Returns a new [AdminDriverPage] instance.
  AdminDriverPage({
    required this.items,

    required this.total,

    required this.limit,

    required this.offset,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AdminDriver> items;

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @JsonKey(name: r'limit', required: true, includeIfNull: false)
  final int limit;

  @JsonKey(name: r'offset', required: true, includeIfNull: false)
  final int offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDriverPage &&
          other.items == items &&
          other.total == total &&
          other.limit == limit &&
          other.offset == offset;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + limit.hashCode + offset.hashCode;

  factory AdminDriverPage.fromJson(Map<String, dynamic> json) =>
      _$AdminDriverPageFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDriverPageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
