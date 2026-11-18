import 'package:latlong2/latlong.dart';
import 'package:podwozka_api/podwozka_api.dart';

import '../location/location_service.dart';

extension GeoPointLatLng on GeoPoint {
  LatLng toLatLng() => LatLng(lat.toDouble(), lng.toDouble());
}

extension PlaceLatLng on Place {
  LatLng toLatLng() => location.toLatLng();
}

extension LocationFixLatLng on LocationFix {
  LatLng toLatLng() => LatLng(lat, lng);
}

extension LatLngGeoPoint on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(lat: latitude, lng: longitude);
}
