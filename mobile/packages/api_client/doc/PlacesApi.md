# podwozka_api.api.PlacesApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**autocompletePlaces**](PlacesApi.md#autocompleteplaces) | **GET** /places/autocomplete | Podpowiedzi adresów
[**getPlace**](PlacesApi.md#getplace) | **GET** /places/{place_id} | Szczegóły podpowiedzi (współrzędne)
[**reverseGeocode**](PlacesApi.md#reversegeocode) | **GET** /places/reverse | Adres dla punktu na mapie


# **autocompletePlaces**
> List<PlaceSuggestion> autocompletePlaces(sessionToken, input, lat, lng)

Podpowiedzi adresów

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getPlacesApi();
final String sessionToken = sessionToken_example; // String | Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie)
final String input = input_example; // String | 
final num lat = 8.14; // num | 
final num lng = 8.14; // num | 

try {
    final response = api.autocompletePlaces(sessionToken, input, lat, lng);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->autocompletePlaces: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sessionToken** | **String**| Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie) | 
 **input** | **String**|  | 
 **lat** | **num**|  | [optional] 
 **lng** | **num**|  | [optional] 

### Return type

[**List&lt;PlaceSuggestion&gt;**](PlaceSuggestion.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlace**
> Place getPlace(placeId, sessionToken)

Szczegóły podpowiedzi (współrzędne)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getPlacesApi();
final String placeId = placeId_example; // String | 
final String sessionToken = sessionToken_example; // String | Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie)

try {
    final response = api.getPlace(placeId, sessionToken);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->getPlace: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **placeId** | **String**|  | 
 **sessionToken** | **String**| Token sesji autouzupełniania (UUID z aplikacji, jeden na wyszukiwanie) | 

### Return type

[**Place**](Place.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reverseGeocode**
> Place reverseGeocode(lat, lng)

Adres dla punktu na mapie

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getPlacesApi();
final num lat = 8.14; // num | 
final num lng = 8.14; // num | 

try {
    final response = api.reverseGeocode(lat, lng);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PlacesApi->reverseGeocode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lat** | **num**|  | 
 **lng** | **num**|  | 

### Return type

[**Place**](Place.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

