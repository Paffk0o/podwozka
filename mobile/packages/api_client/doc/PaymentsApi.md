# podwozka_api.api.PaymentsApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**stripeWebhook**](PaymentsApi.md#stripewebhook) | **POST** /payments/stripe/webhook | Webhook Stripe (bez autoryzacji JWT, weryfikacja podpisu)


# **stripeWebhook**
> Object stripeWebhook()

Webhook Stripe (bez autoryzacji JWT, weryfikacja podpisu)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getPaymentsApi();

try {
    final response = api.stripeWebhook();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PaymentsApi->stripeWebhook: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**Object**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

