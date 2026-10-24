# podwozka_api.api.MeApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**confirmPhoneVerification**](MeApi.md#confirmphoneverification) | **POST** /me/phone/verification/confirm | Potwierdź numer kodem z SMS
[**deleteMe**](MeApi.md#deleteme) | **DELETE** /me | Usuń konto (Keycloak + anonimizacja danych)
[**getMe**](MeApi.md#getme) | **GET** /me | Mój profil
[**registerDeviceToken**](MeApi.md#registerdevicetoken) | **PUT** /me/device-tokens | Zarejestruj token push (FCM) urządzenia
[**requestPhoneVerification**](MeApi.md#requestphoneverification) | **POST** /me/phone/verification | Wyślij kod SMS na numer telefonu
[**upsertMe**](MeApi.md#upsertme) | **PUT** /me | Utwórz lub zaktualizuj mój profil


# **confirmPhoneVerification**
> Me confirmPhoneVerification(phoneVerificationConfirm)

Potwierdź numer kodem z SMS

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();
final PhoneVerificationConfirm phoneVerificationConfirm = ; // PhoneVerificationConfirm | 

try {
    final response = api.confirmPhoneVerification(phoneVerificationConfirm);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeApi->confirmPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **phoneVerificationConfirm** | [**PhoneVerificationConfirm**](PhoneVerificationConfirm.md)|  | 

### Return type

[**Me**](Me.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteMe**
> deleteMe()

Usuń konto (Keycloak + anonimizacja danych)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();

try {
    api.deleteMe();
} on DioException catch (e) {
    print('Exception when calling MeApi->deleteMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMe**
> Me getMe()

Mój profil

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();

try {
    final response = api.getMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeApi->getMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Me**](Me.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDeviceToken**
> registerDeviceToken(deviceTokenIn)

Zarejestruj token push (FCM) urządzenia

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();
final DeviceTokenIn deviceTokenIn = ; // DeviceTokenIn | 

try {
    api.registerDeviceToken(deviceTokenIn);
} on DioException catch (e) {
    print('Exception when calling MeApi->registerDeviceToken: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceTokenIn** | [**DeviceTokenIn**](DeviceTokenIn.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestPhoneVerification**
> Object requestPhoneVerification(phoneVerificationRequest)

Wyślij kod SMS na numer telefonu

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();
final PhoneVerificationRequest phoneVerificationRequest = ; // PhoneVerificationRequest | 

try {
    final response = api.requestPhoneVerification(phoneVerificationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeApi->requestPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **phoneVerificationRequest** | [**PhoneVerificationRequest**](PhoneVerificationRequest.md)|  | 

### Return type

**Object**

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **upsertMe**
> Me upsertMe(meUpsert)

Utwórz lub zaktualizuj mój profil

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getMeApi();
final MeUpsert meUpsert = ; // MeUpsert | 

try {
    final response = api.upsertMe(meUpsert);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MeApi->upsertMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meUpsert** | [**MeUpsert**](MeUpsert.md)|  | 

### Return type

[**Me**](Me.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

