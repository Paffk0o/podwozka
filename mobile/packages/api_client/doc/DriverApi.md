# podwozka_api.api.DriverApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptOffer**](DriverApi.md#acceptoffer) | **POST** /drivers/me/offers/{offer_id}/accept | Przyjmij ofertę kursu
[**cancelDriverRide**](DriverApi.md#canceldriverride) | **POST** /drivers/me/rides/{ride_id}/cancel | Anuluj kurs (kierowca)
[**claimScheduledRide**](DriverApi.md#claimscheduledride) | **POST** /drivers/me/scheduled-board/{ride_id}/claim | Weź rezerwację z giełdy
[**completeDocumentUpload**](DriverApi.md#completedocumentupload) | **POST** /drivers/me/documents/{document_id}/complete | Potwierdź, że plik został wysłany
[**confirmCashCollected**](DriverApi.md#confirmcashcollected) | **POST** /drivers/me/rides/{ride_id}/cash-collected | Potwierdź przyjęcie gotówki
[**createDocumentUpload**](DriverApi.md#createdocumentupload) | **POST** /drivers/me/documents | Poproś o link do wysłania dokumentu (Azure Blob SAS)
[**declineOffer**](DriverApi.md#declineoffer) | **POST** /drivers/me/offers/{offer_id}/decline | Odrzuć ofertę kursu
[**getDriverCurrentState**](DriverApi.md#getdrivercurrentstate) | **GET** /drivers/me/current | Bieżący stan kierowcy (oferta, aktywny kurs)
[**getDriverEarnings**](DriverApi.md#getdriverearnings) | **GET** /drivers/me/earnings | Zarobki w okresie
[**getMyDriverProfile**](DriverApi.md#getmydriverprofile) | **GET** /drivers/me | Mój profil kierowcy / status wniosku
[**listDriverRides**](DriverApi.md#listdriverrides) | **GET** /drivers/me/rides | Moje kursy jako kierowca (aktywne, zaplanowane, historia)
[**listScheduledBoard**](DriverApi.md#listscheduledboard) | **GET** /drivers/me/scheduled-board | Giełda rezerwacji w moim regionie (nieprzypisane)
[**performRideAction**](DriverApi.md#performrideaction) | **POST** /drivers/me/rides/{ride_id}/actions | Zmień status kursu (wyjazd, na miejscu, start, koniec)
[**ratePassenger**](DriverApi.md#ratepassenger) | **POST** /drivers/me/rides/{ride_id}/rating | Oceń pasażera
[**setDriverAvailability**](DriverApi.md#setdriveravailability) | **PUT** /drivers/me/availability | Przejdź online / offline
[**submitDriverApplication**](DriverApi.md#submitdriverapplication) | **POST** /drivers/me/application/submit | Wyślij wniosek do weryfikacji
[**upsertDriverApplication**](DriverApi.md#upsertdriverapplication) | **PUT** /drivers/me/application | Utwórz / popraw wniosek kierowcy (region, pojazd)


# **acceptOffer**
> Ride acceptOffer(offerId)

Przyjmij ofertę kursu

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String offerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.acceptOffer(offerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->acceptOffer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offerId** | **String**|  | 

### Return type

[**Ride**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelDriverRide**
> Ride cancelDriverRide(rideId, cancelRequest)

Anuluj kurs (kierowca)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final CancelRequest cancelRequest = ; // CancelRequest | 

try {
    final response = api.cancelDriverRide(rideId, cancelRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->cancelDriverRide: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**|  | 
 **cancelRequest** | [**CancelRequest**](CancelRequest.md)|  | 

### Return type

[**Ride**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **claimScheduledRide**
> Ride claimScheduledRide(rideId)

Weź rezerwację z giełdy

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.claimScheduledRide(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->claimScheduledRide: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**|  | 

### Return type

[**Ride**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeDocumentUpload**
> DriverDocument completeDocumentUpload(documentId)

Potwierdź, że plik został wysłany

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.completeDocumentUpload(documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->completeDocumentUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentId** | **String**|  | 

### Return type

[**DriverDocument**](DriverDocument.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmCashCollected**
> Ride confirmCashCollected(rideId)

Potwierdź przyjęcie gotówki

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.confirmCashCollected(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->confirmCashCollected: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**|  | 

### Return type

[**Ride**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDocumentUpload**
> DocumentUploadSlot createDocumentUpload(documentUploadRequest)

Poproś o link do wysłania dokumentu (Azure Blob SAS)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final DocumentUploadRequest documentUploadRequest = ; // DocumentUploadRequest | 

try {
    final response = api.createDocumentUpload(documentUploadRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->createDocumentUpload: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **documentUploadRequest** | [**DocumentUploadRequest**](DocumentUploadRequest.md)|  | 

### Return type

[**DocumentUploadSlot**](DocumentUploadSlot.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **declineOffer**
> declineOffer(offerId)

Odrzuć ofertę kursu

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String offerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.declineOffer(offerId);
} on DioException catch (e) {
    print('Exception when calling DriverApi->declineOffer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **offerId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDriverCurrentState**
> DriverCurrentState getDriverCurrentState()

Bieżący stan kierowcy (oferta, aktywny kurs)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();

try {
    final response = api.getDriverCurrentState();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->getDriverCurrentState: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DriverCurrentState**](DriverCurrentState.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDriverEarnings**
> EarningsSummary getDriverEarnings(dateFrom, dateTo)

Zarobki w okresie

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final DateTime dateFrom = 2013-10-20; // DateTime | 
final DateTime dateTo = 2013-10-20; // DateTime | 

try {
    final response = api.getDriverEarnings(dateFrom, dateTo);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->getDriverEarnings: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **dateFrom** | **DateTime**|  | 
 **dateTo** | **DateTime**|  | 

### Return type

[**EarningsSummary**](EarningsSummary.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyDriverProfile**
> DriverProfile getMyDriverProfile()

Mój profil kierowcy / status wniosku

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();

try {
    final response = api.getMyDriverProfile();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->getMyDriverProfile: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DriverProfile**](DriverProfile.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDriverRides**
> RidePage listDriverRides(active, limit, offset)

Moje kursy jako kierowca (aktywne, zaplanowane, historia)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final bool active = true; // bool | 
final int limit = 56; // int | 
final int offset = 56; // int | 

try {
    final response = api.listDriverRides(active, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->listDriverRides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **active** | **bool**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 20]
 **offset** | **int**|  | [optional] [default to 0]

### Return type

[**RidePage**](RidePage.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listScheduledBoard**
> List<Ride> listScheduledBoard()

Giełda rezerwacji w moim regionie (nieprzypisane)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();

try {
    final response = api.listScheduledBoard();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->listScheduledBoard: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Ride&gt;**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **performRideAction**
> Ride performRideAction(rideId, driverRideActionRequest)

Zmień status kursu (wyjazd, na miejscu, start, koniec)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final DriverRideActionRequest driverRideActionRequest = ; // DriverRideActionRequest | 

try {
    final response = api.performRideAction(rideId, driverRideActionRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->performRideAction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**|  | 
 **driverRideActionRequest** | [**DriverRideActionRequest**](DriverRideActionRequest.md)|  | 

### Return type

[**Ride**](Ride.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **ratePassenger**
> ratePassenger(rideId, ratingCreate)

Oceń pasażera

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RatingCreate ratingCreate = ; // RatingCreate | 

try {
    api.ratePassenger(rideId, ratingCreate);
} on DioException catch (e) {
    print('Exception when calling DriverApi->ratePassenger: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideId** | **String**|  | 
 **ratingCreate** | [**RatingCreate**](RatingCreate.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setDriverAvailability**
> DriverProfile setDriverAvailability(availabilityUpdate)

Przejdź online / offline

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final AvailabilityUpdate availabilityUpdate = ; // AvailabilityUpdate | 

try {
    final response = api.setDriverAvailability(availabilityUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->setDriverAvailability: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **availabilityUpdate** | [**AvailabilityUpdate**](AvailabilityUpdate.md)|  | 

### Return type

[**DriverProfile**](DriverProfile.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **submitDriverApplication**
> DriverProfile submitDriverApplication()

Wyślij wniosek do weryfikacji

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();

try {
    final response = api.submitDriverApplication();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->submitDriverApplication: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**DriverProfile**](DriverProfile.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertDriverApplication**
> DriverProfile upsertDriverApplication(driverApplicationUpsert)

Utwórz / popraw wniosek kierowcy (region, pojazd)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getDriverApi();
final DriverApplicationUpsert driverApplicationUpsert = ; // DriverApplicationUpsert | 

try {
    final response = api.upsertDriverApplication(driverApplicationUpsert);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverApi->upsertDriverApplication: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **driverApplicationUpsert** | [**DriverApplicationUpsert**](DriverApplicationUpsert.md)|  | 

### Return type

[**DriverProfile**](DriverProfile.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

