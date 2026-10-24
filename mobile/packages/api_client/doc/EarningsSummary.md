# podwozka_api.model.EarningsSummary

## Load the model package
```dart
import 'package:podwozka_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**dateFrom** | [**DateTime**](DateTime.md) |  | 
**dateTo** | [**DateTime**](DateTime.md) |  | 
**ridesCount** | **int** |  | 
**gross** | **int** | Kwota w groszach (1 PLN = 100) | 
**commission** | **int** | Kwota w groszach (1 PLN = 100) | 
**net** | **int** | Kwota w groszach (1 PLN = 100) | 
**cashCollected** | **int** | Gotówka przyjęta przez kierowcę | 
**commissionDueFromCash** | **int** | Prowizja do rozliczenia z gotówki | 
**items** | [**List&lt;EarningEntry&gt;**](EarningEntry.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


