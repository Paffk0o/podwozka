# podwozka_api.model.Quote

## Load the model package
```dart
import 'package:podwozka_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**regionId** | **String** |  | 
**regionName** | **String** |  | 
**pickup** | [**Place**](Place.md) |  | 
**destination** | [**Place**](Place.md) |  | 
**scheduledAt** | [**DateTime**](DateTime.md) |  | 
**distanceM** | **int** |  | 
**durationS** | **int** |  | 
**price** | **int** | Kwota w groszach (1 PLN = 100) | 
**currency** | **String** |  | [optional] [default to 'PLN']
**tariffId** | **String** |  | 
**routePolyline** | **String** | Trasa w formacie encoded polyline (Google) | 
**expiresAt** | [**DateTime**](DateTime.md) | Wycena ważna do (5 min) | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


