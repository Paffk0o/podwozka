# podwozka_api.model.RegionDetail

## Load the model package
```dart
import 'package:podwozka_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**name** | **String** |  | 
**teryt** | **String** | Kod TERYT gminy (7 cyfr) | 
**timezone** | **String** |  | [optional] [default to 'Europe/Warsaw']
**active** | **bool** |  | 
**area** | **Map&lt;String, Object&gt;** | Granica gminy jako GeoJSON (Polygon lub MultiPolygon, WGS84 / EPSG:4326) | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


