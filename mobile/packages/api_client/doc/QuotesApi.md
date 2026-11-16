# podwozka_api.api.QuotesApi

## Load the API package
```dart
import 'package:podwozka_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createQuote**](QuotesApi.md#createquote) | **POST** /quotes | Wycena kursu (cena z góry)


# **createQuote**
> Quote createQuote(quoteRequest)

Wycena kursu (cena z góry)

### Example
```dart
import 'package:podwozka_api/api.dart';

final api = PodwozkaApi().getQuotesApi();
final QuoteRequest quoteRequest = ; // QuoteRequest | 

try {
    final response = api.createQuote(quoteRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QuotesApi->createQuote: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **quoteRequest** | [**QuoteRequest**](QuoteRequest.md)|  | 

### Return type

[**Quote**](Quote.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

