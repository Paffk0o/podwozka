// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_suggestion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlaceSuggestionCWProxy {
  PlaceSuggestion placeId(String placeId);

  PlaceSuggestion primaryText(String primaryText);

  PlaceSuggestion secondaryText(String? secondaryText);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PlaceSuggestion(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PlaceSuggestion(...).copyWith(id: 12, name: "My name")
  /// ```
  PlaceSuggestion call({
    String placeId,
    String primaryText,
    String? secondaryText,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPlaceSuggestion.copyWith(...)` or call `instanceOfPlaceSuggestion.copyWith.fieldName(value)` for a single field.
class _$PlaceSuggestionCWProxyImpl implements _$PlaceSuggestionCWProxy {
  const _$PlaceSuggestionCWProxyImpl(this._value);

  final PlaceSuggestion _value;

  @override
  PlaceSuggestion placeId(String placeId) => call(placeId: placeId);

  @override
  PlaceSuggestion primaryText(String primaryText) =>
      call(primaryText: primaryText);

  @override
  PlaceSuggestion secondaryText(String? secondaryText) =>
      call(secondaryText: secondaryText);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `PlaceSuggestion(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PlaceSuggestion(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  PlaceSuggestion call({
    Object? placeId = const $CopyWithPlaceholder(),
    Object? primaryText = const $CopyWithPlaceholder(),
    Object? secondaryText = const $CopyWithPlaceholder(),
  }) {
    return PlaceSuggestion(
      placeId: placeId == const $CopyWithPlaceholder() || placeId == null
          ? _value.placeId
          // ignore: cast_nullable_to_non_nullable
          : placeId as String,
      primaryText:
          primaryText == const $CopyWithPlaceholder() || primaryText == null
          ? _value.primaryText
          // ignore: cast_nullable_to_non_nullable
          : primaryText as String,
      secondaryText: secondaryText == const $CopyWithPlaceholder()
          ? _value.secondaryText
          // ignore: cast_nullable_to_non_nullable
          : secondaryText as String?,
    );
  }
}

extension $PlaceSuggestionCopyWith on PlaceSuggestion {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPlaceSuggestion.copyWith(...)` or `instanceOfPlaceSuggestion.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlaceSuggestionCWProxy get copyWith => _$PlaceSuggestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSuggestion _$PlaceSuggestionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PlaceSuggestion',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['place_id', 'primary_text', 'secondary_text'],
        );
        final val = PlaceSuggestion(
          placeId: $checkedConvert('place_id', (v) => v as String),
          primaryText: $checkedConvert('primary_text', (v) => v as String),
          secondaryText: $checkedConvert('secondary_text', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'placeId': 'place_id',
        'primaryText': 'primary_text',
        'secondaryText': 'secondary_text',
      },
    );

Map<String, dynamic> _$PlaceSuggestionToJson(PlaceSuggestion instance) =>
    <String, dynamic>{
      'place_id': instance.placeId,
      'primary_text': instance.primaryText,
      'secondary_text': instance.secondaryText,
    };
