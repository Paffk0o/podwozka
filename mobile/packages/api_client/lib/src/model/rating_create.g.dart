// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RatingCreateCWProxy {
  RatingCreate stars(int stars);

  RatingCreate comment(String? comment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RatingCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RatingCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  RatingCreate call({int stars, String? comment});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRatingCreate.copyWith(...)` or call `instanceOfRatingCreate.copyWith.fieldName(value)` for a single field.
class _$RatingCreateCWProxyImpl implements _$RatingCreateCWProxy {
  const _$RatingCreateCWProxyImpl(this._value);

  final RatingCreate _value;

  @override
  RatingCreate stars(int stars) => call(stars: stars);

  @override
  RatingCreate comment(String? comment) => call(comment: comment);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RatingCreate(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RatingCreate(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RatingCreate call({
    Object? stars = const $CopyWithPlaceholder(),
    Object? comment = const $CopyWithPlaceholder(),
  }) {
    return RatingCreate(
      stars: stars == const $CopyWithPlaceholder() || stars == null
          ? _value.stars
          // ignore: cast_nullable_to_non_nullable
          : stars as int,
      comment: comment == const $CopyWithPlaceholder()
          ? _value.comment
          // ignore: cast_nullable_to_non_nullable
          : comment as String?,
    );
  }
}

extension $RatingCreateCopyWith on RatingCreate {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRatingCreate.copyWith(...)` or `instanceOfRatingCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RatingCreateCWProxy get copyWith => _$RatingCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingCreate _$RatingCreateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RatingCreate', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['stars']);
      final val = RatingCreate(
        stars: $checkedConvert('stars', (v) => (v as num).toInt()),
        comment: $checkedConvert('comment', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$RatingCreateToJson(RatingCreate instance) =>
    <String, dynamic>{'stars': instance.stars, 'comment': ?instance.comment};
