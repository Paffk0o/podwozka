//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place_suggestion.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlaceSuggestion {
  /// Returns a new [PlaceSuggestion] instance.
  PlaceSuggestion({
    required this.placeId,

    required this.primaryText,

    required this.secondaryText,
  });

  @JsonKey(name: r'place_id', required: true, includeIfNull: false)
  final String placeId;

  @JsonKey(name: r'primary_text', required: true, includeIfNull: false)
  final String primaryText;

  @JsonKey(name: r'secondary_text', required: true, includeIfNull: true)
  final String? secondaryText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceSuggestion &&
          other.placeId == placeId &&
          other.primaryText == primaryText &&
          other.secondaryText == secondaryText;

  @override
  int get hashCode =>
      placeId.hashCode +
      primaryText.hashCode +
      (secondaryText == null ? 0 : secondaryText.hashCode);

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) =>
      _$PlaceSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceSuggestionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
