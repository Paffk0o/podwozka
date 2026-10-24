# podwozka_api.api.RidesApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**cancelMyRide**](RidesApi.md#cancelmyride) | **POST** /rides/{ride_id}/cancel | Anuluj kurs (pasażer)
[**createRide**](RidesApi.md#createride) | **POST** /rides | Zamów kurs na podstawie wyceny
[**getMyRide**](RidesApi.md#getmyride) | **GET** /rides/{ride_id} | Szczegóły kursu
[**listMyRides**](RidesApi.md#listmyrides) | **GET** /rides | Moje kursy (najnowsze pierwsze)
[**rateDriver**](RidesApi.md#ratedriver) | **POST** /rides/{ride_id}/rating | Oceń kierowcę


# **cancelMyRide**
> Ride cancelMyRide(rideId, cancelRequest)

Anuluj kurs (pasażer)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRidesApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final CancelRequest cancelRequest = ; // CancelRequest | 

try {
    final response = api.cancelMyRide(rideId, cancelRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->cancelMyRide: $e\n');
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

# **createRide**
> RideCreated createRide(rideCreate)

Zamów kurs na podstawie wyceny

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRidesApi();
final RideCreate rideCreate = ; // RideCreate | 

try {
    final response = api.createRide(rideCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->createRide: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **rideCreate** | [**RideCreate**](RideCreate.md)|  | 

### Return type

[**RideCreated**](RideCreated.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMyRide**
> Ride getMyRide(rideId)

Szczegóły kursu

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRidesApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.getMyRide(rideId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->getMyRide: $e\n');
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

# **listMyRides**
> RidePage listMyRides(active, limit, offset)

Moje kursy (najnowsze pierwsze)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRidesApi();
final bool active = true; // bool | Tylko aktywne / tylko zakończone
final int limit = 56; // int | 
final int offset = 56; // int | 

try {
    final response = api.listMyRides(active, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->listMyRides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **active** | **bool**| Tylko aktywne / tylko zakończone | [optional] 
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

# **rateDriver**
> rateDriver(rideId, ratingCreate)

Oceń kierowcę

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRidesApi();
final String rideId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RatingCreate ratingCreate = ; // RatingCreate | 

try {
    api.rateDriver(rideId, ratingCreate);
} on DioException catch (e) {
    print('Exception when calling RidesApi->rateDriver: $e\n');
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

