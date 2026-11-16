# podwozka_api.api.AdminApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminApproveDriver**](AdminApi.md#adminapprovedriver) | **POST** /admin/drivers/{user_id}/approve | Zatwierdź kierowcę (nadaje rolę driver w Keycloaku)
[**adminCreateRegion**](AdminApi.md#admincreateregion) | **POST** /admin/regions | Dodaj region (granica GeoJSON)
[**adminCreateTariff**](AdminApi.md#admincreatetariff) | **POST** /admin/regions/{region_id}/tariffs | Nowa wersja cennika (zamyka poprzednią)
[**adminGetDocumentUrl**](AdminApi.md#admingetdocumenturl) | **GET** /admin/drivers/{user_id}/documents/{document_id}/view-url | Krótkotrwały link do podglądu dokumentu
[**adminGetDriver**](AdminApi.md#admingetdriver) | **GET** /admin/drivers/{user_id} | Szczegóły kierowcy
[**adminListDrivers**](AdminApi.md#adminlistdrivers) | **GET** /admin/drivers | Kierowcy / wnioski
[**adminListRegions**](AdminApi.md#adminlistregions) | **GET** /admin/regions | Wszystkie regiony
[**adminListRides**](AdminApi.md#adminlistrides) | **GET** /admin/rides | Kursy (filtry)
[**adminListTariffs**](AdminApi.md#adminlisttariffs) | **GET** /admin/regions/{region_id}/tariffs | Historia cenników regionu (najnowszy pierwszy)
[**adminRejectDriver**](AdminApi.md#adminrejectdriver) | **POST** /admin/drivers/{user_id}/reject | Odrzuć wniosek
[**adminSuspendDriver**](AdminApi.md#adminsuspenddriver) | **POST** /admin/drivers/{user_id}/suspend | Zawieś kierowcę
[**adminUpdateRegion**](AdminApi.md#adminupdateregion) | **PATCH** /admin/regions/{region_id} | Edytuj region


# **adminApproveDriver**
> AdminDriver adminApproveDriver(userId)

Zatwierdź kierowcę (nadaje rolę driver w Keycloaku)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String userId = userId_example; // String | 

try {
    final response = api.adminApproveDriver(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminApproveDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**AdminDriver**](AdminDriver.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateRegion**
> RegionDetail adminCreateRegion(regionCreate)

Dodaj region (granica GeoJSON)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final RegionCreate regionCreate = ; // RegionCreate | 

try {
    final response = api.adminCreateRegion(regionCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateRegion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionCreate** | [**RegionCreate**](RegionCreate.md)|  | 

### Return type

[**RegionDetail**](RegionDetail.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCreateTariff**
> Tariff adminCreateTariff(regionId, tariffCreate)

Nowa wersja cennika (zamyka poprzednią)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String regionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TariffCreate tariffCreate = ; // TariffCreate | 

try {
    final response = api.adminCreateTariff(regionId, tariffCreate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminCreateTariff: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionId** | **String**|  | 
 **tariffCreate** | [**TariffCreate**](TariffCreate.md)|  | 

### Return type

[**Tariff**](Tariff.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetDocumentUrl**
> SignedUrl adminGetDocumentUrl(userId, documentId)

Krótkotrwały link do podglądu dokumentu

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String userId = userId_example; // String | 
final String documentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminGetDocumentUrl(userId, documentId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetDocumentUrl: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **documentId** | **String**|  | 

### Return type

[**SignedUrl**](SignedUrl.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminGetDriver**
> AdminDriver adminGetDriver(userId)

Szczegóły kierowcy

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String userId = userId_example; // String | 

try {
    final response = api.adminGetDriver(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminGetDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**AdminDriver**](AdminDriver.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListDrivers**
> AdminDriverPage adminListDrivers(status, regionId, limit, offset)

Kierowcy / wnioski

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final DriverStatus status = ; // DriverStatus | 
final String regionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final int limit = 56; // int | 
final int offset = 56; // int | 

try {
    final response = api.adminListDrivers(status, regionId, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListDrivers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**DriverStatus**](.md)|  | [optional] 
 **regionId** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **offset** | **int**|  | [optional] [default to 0]

### Return type

[**AdminDriverPage**](AdminDriverPage.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListRegions**
> List<RegionDetail> adminListRegions()

Wszystkie regiony

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();

try {
    final response = api.adminListRegions();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListRegions: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;RegionDetail&gt;**](RegionDetail.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListRides**
> RidePage adminListRides(regionId, status, dateFrom, dateTo, limit, offset)

Kursy (filtry)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String regionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RideStatus status = ; // RideStatus | 
final DateTime dateFrom = 2013-10-20T19:20:30+01:00; // DateTime | 
final DateTime dateTo = 2013-10-20T19:20:30+01:00; // DateTime | 
final int limit = 56; // int | 
final int offset = 56; // int | 

try {
    final response = api.adminListRides(regionId, status, dateFrom, dateTo, limit, offset);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListRides: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionId** | **String**|  | [optional] 
 **status** | [**RideStatus**](.md)|  | [optional] 
 **dateFrom** | **DateTime**|  | [optional] 
 **dateTo** | **DateTime**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **offset** | **int**|  | [optional] [default to 0]

### Return type

[**RidePage**](RidePage.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminListTariffs**
> List<Tariff> adminListTariffs(regionId)

Historia cenników regionu (najnowszy pierwszy)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String regionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.adminListTariffs(regionId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminListTariffs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionId** | **String**|  | 

### Return type

[**List&lt;Tariff&gt;**](Tariff.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminRejectDriver**
> AdminDriver adminRejectDriver(userId, reasonRequest)

Odrzuć wniosek

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String userId = userId_example; // String | 
final ReasonRequest reasonRequest = ; // ReasonRequest | 

try {
    final response = api.adminRejectDriver(userId, reasonRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminRejectDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **reasonRequest** | [**ReasonRequest**](ReasonRequest.md)|  | 

### Return type

[**AdminDriver**](AdminDriver.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSuspendDriver**
> AdminDriver adminSuspendDriver(userId, reasonRequest)

Zawieś kierowcę

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String userId = userId_example; // String | 
final ReasonRequest reasonRequest = ; // ReasonRequest | 

try {
    final response = api.adminSuspendDriver(userId, reasonRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminSuspendDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **reasonRequest** | [**ReasonRequest**](ReasonRequest.md)|  | 

### Return type

[**AdminDriver**](AdminDriver.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUpdateRegion**
> RegionDetail adminUpdateRegion(regionId, regionUpdate)

Edytuj region

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getAdminApi();
final String regionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final RegionUpdate regionUpdate = ; // RegionUpdate | 

try {
    final response = api.adminUpdateRegion(regionId, regionUpdate);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUpdateRegion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **regionId** | **String**|  | 
 **regionUpdate** | [**RegionUpdate**](RegionUpdate.md)|  | 

### Return type

[**RegionDetail**](RegionDetail.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

