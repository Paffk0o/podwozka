import 'package:podwozka_api/src/model/admin_driver.dart';
import 'package:podwozka_api/src/model/admin_driver_page.dart';
import 'package:podwozka_api/src/model/availability_update.dart';
import 'package:podwozka_api/src/model/cancel_request.dart';
import 'package:podwozka_api/src/model/device_token_in.dart';
import 'package:podwozka_api/src/model/document_upload_request.dart';
import 'package:podwozka_api/src/model/document_upload_slot.dart';
import 'package:podwozka_api/src/model/driver_application_upsert.dart';
import 'package:podwozka_api/src/model/driver_current_state.dart';
import 'package:podwozka_api/src/model/driver_document.dart';
import 'package:podwozka_api/src/model/driver_profile.dart';
import 'package:podwozka_api/src/model/driver_ride_action_request.dart';
import 'package:podwozka_api/src/model/earning_entry.dart';
import 'package:podwozka_api/src/model/earnings_summary.dart';
import 'package:podwozka_api/src/model/geo_point.dart';
import 'package:podwozka_api/src/model/http_validation_error.dart';
import 'package:podwozka_api/src/model/health.dart';
import 'package:podwozka_api/src/model/me.dart';
import 'package:podwozka_api/src/model/me_upsert.dart';
import 'package:podwozka_api/src/model/phone_verification_confirm.dart';
import 'package:podwozka_api/src/model/phone_verification_request.dart';
import 'package:podwozka_api/src/model/place.dart';
import 'package:podwozka_api/src/model/place_suggestion.dart';
import 'package:podwozka_api/src/model/public_config.dart';
import 'package:podwozka_api/src/model/quote.dart';
import 'package:podwozka_api/src/model/quote_request.dart';
import 'package:podwozka_api/src/model/rating_create.dart';
import 'package:podwozka_api/src/model/reason_request.dart';
import 'package:podwozka_api/src/model/region.dart';
import 'package:podwozka_api/src/model/region_create.dart';
import 'package:podwozka_api/src/model/region_detail.dart';
import 'package:podwozka_api/src/model/region_update.dart';
import 'package:podwozka_api/src/model/ride.dart';
import 'package:podwozka_api/src/model/ride_create.dart';
import 'package:podwozka_api/src/model/ride_created.dart';
import 'package:podwozka_api/src/model/ride_driver_info.dart';
import 'package:podwozka_api/src/model/ride_offer.dart';
import 'package:podwozka_api/src/model/ride_page.dart';
import 'package:podwozka_api/src/model/ride_passenger_info.dart';
import 'package:podwozka_api/src/model/signed_url.dart';
import 'package:podwozka_api/src/model/stripe_payment_init.dart';
import 'package:podwozka_api/src/model/tariff.dart';
import 'package:podwozka_api/src/model/tariff_create.dart';
import 'package:podwozka_api/src/model/validation_error.dart';
import 'package:podwozka_api/src/model/vehicle.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AdminDriver':
      return AdminDriver.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'AdminDriverPage':
      return AdminDriverPage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AvailabilityUpdate':
      return AvailabilityUpdate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CancelRequest':
      return CancelRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DevicePlatform':
    case 'DeviceTokenIn':
      return DeviceTokenIn.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DocumentStatus':
    case 'DocumentType':
    case 'DocumentUploadRequest':
      return DocumentUploadRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DocumentUploadSlot':
      return DocumentUploadSlot.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverApplicationUpsert':
      return DriverApplicationUpsert.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverCurrentState':
      return DriverCurrentState.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverDocument':
      return DriverDocument.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverProfile':
      return DriverProfile.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverRideAction':
    case 'DriverRideActionRequest':
      return DriverRideActionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DriverStatus':
    case 'EarningEntry':
      return EarningEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'EarningsSummary':
      return EarningsSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GeoPoint':
      return GeoPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'HTTPValidationError':
      return HTTPValidationError.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Health':
      return Health.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Me':
      return Me.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MeUpsert':
      return MeUpsert.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PaymentMethod':
    case 'PaymentStatus':
    case 'PhoneVerificationConfirm':
      return PhoneVerificationConfirm.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PhoneVerificationRequest':
      return PhoneVerificationRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Place':
      return Place.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlaceSuggestion':
      return PlaceSuggestion.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PublicConfig':
      return PublicConfig.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Quote':
      return Quote.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'QuoteRequest':
      return QuoteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RatingCreate':
      return RatingCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ReasonRequest':
      return ReasonRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Region':
      return Region.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RegionCreate':
      return RegionCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RegionDetail':
      return RegionDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RegionUpdate':
      return RegionUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Ride':
      return Ride.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RideCreate':
      return RideCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RideCreated':
      return RideCreated.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RideDriverInfo':
      return RideDriverInfo.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RideOffer':
      return RideOffer.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RidePage':
      return RidePage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RidePassengerInfo':
      return RidePassengerInfo.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RideStatus':
    case 'SignedUrl':
      return SignedUrl.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'StripePaymentInit':
      return StripePaymentInit.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Tariff':
      return Tariff.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'TariffCreate':
      return TariffCreate.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ValidationError':
      return ValidationError.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Vehicle':
      return Vehicle.fromJson(value as Map<String, dynamic>) as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
          value.keys as Iterable<String>,
          value.values.map(
            (dynamic v) => deserialize<BaseType, BaseType>(
              v,
              targetType,
              growable: growable,
            ),
          ),
        ) as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
