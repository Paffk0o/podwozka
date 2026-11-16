# podwozka_api.model.Ride

## Load the model package
```dart
import 'package:podwozka_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**status** | [**RideStatus**](RideStatus.md) |  | 
**regionId** | **String** |  | 
**pickup** | [**Place**](Place.md) |  | 
**destination** | [**Place**](Place.md) |  | 
**scheduledAt** | [**DateTime**](DateTime.md) | Rezerwacja; brak = kurs teraz | 
**requestedAt** | [**DateTime**](DateTime.md) |  | 
**acceptedAt** | [**DateTime**](DateTime.md) |  | 
**startedAt** | [**DateTime**](DateTime.md) |  | 
**completedAt** | [**DateTime**](DateTime.md) |  | 
**cancelledAt** | [**DateTime**](DateTime.md) |  | 
**cancelReason** | **String** |  | 
**price** | **int** | Kwota w groszach (1 PLN = 100) | 
**currency** | **String** |  | [optional] [default to 'PLN']
**paymentMethod** | [**PaymentMethod**](PaymentMethod.md) |  | 
**paymentStatus** | [**PaymentStatus**](PaymentStatus.md) |  | 
**distanceM** | **int** |  | 
**durationS** | **int** |  | 
**routePolyline** | **String** |  | 
**passengerNote** | **String** |  | 
**driver** | [**RideDriverInfo**](RideDriverInfo.md) |  | 
**passenger** | [**RidePassengerInfo**](RidePassengerInfo.md) | Wypełniane tylko w widoku kierowcy/admina | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


