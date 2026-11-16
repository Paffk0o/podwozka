# podwozka_api.model.Tariff

## Load the model package
```dart
import 'package:podwozka_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**baseFare** | **int** | Opłata startowa | 
**perKm** | **int** | Stawka za km | 
**perMinute** | **int** | Stawka za minutę jazdy | 
**minimumFare** | **int** | Cena minimalna kursu | 
**nightMultiplierPercent** | **int** | Mnożnik nocny w procentach (np. 120 = +20%) | [optional] [default to 100]
**nightStartHour** | **int** |  | [optional] [default to 22]
**nightEndHour** | **int** |  | [optional] [default to 6]
**commissionPercent** | **int** | Prowizja platformy | [optional] [default to 10]
**id** | **String** |  | 
**regionId** | **String** |  | 
**validFrom** | [**DateTime**](DateTime.md) |  | 
**validTo** | [**DateTime**](DateTime.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


