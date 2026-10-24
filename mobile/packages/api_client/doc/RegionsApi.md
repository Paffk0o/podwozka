# podwozka_api.api.RegionsApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listRegions**](RegionsApi.md#listregions) | **GET** /regions | Aktywne regiony (gminy)


# **listRegions**
> List<Region> listRegions()

Aktywne regiony (gminy)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getRegionsApi();

try {
    final response = api.listRegions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegionsApi->listRegions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Region&gt;**](Region.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

