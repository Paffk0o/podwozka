# podwozka_api.api.SystemApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPublicConfig**](SystemApi.md#getpublicconfig) | **GET** /config | Publiczna konfiguracja aplikacji
[**health**](SystemApi.md#health) | **GET** /health | Healthcheck


# **getPublicConfig**
> PublicConfig getPublicConfig()

Publiczna konfiguracja aplikacji

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getSystemApi();

try {
    final response = api.getPublicConfig();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->getPublicConfig: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PublicConfig**](PublicConfig.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **health**
> Health health()

Healthcheck

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getSystemApi();

try {
    final response = api.health();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->health: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

