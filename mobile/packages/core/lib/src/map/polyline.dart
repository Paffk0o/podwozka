import 'package:latlong2/latlong.dart';

/// Decodes a Google "encoded polyline" (precision 5) — the format of `route_polyline`
/// returned by `POST /quotes` and `GET /rides/{id}` when the backend uses Google Routes.
/// Returns an empty list for null/empty/corrupted input (the map then draws a straight line).
List<LatLng> decodePolyline(String? encoded) {
  if (encoded == null || encoded.isEmpty) return const [];
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  try {
    while (index < encoded.length) {
      final (dLat, afterLat) = _readValue(encoded, index);
      final (dLng, afterLng) = _readValue(encoded, afterLat);
      index = afterLng;
      lat += dLat;
      lng += dLng;
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
  } on RangeError {
    return const [];
  }
  return points;
}

(int, int) _readValue(String encoded, int start) {
  var index = start;
  var result = 0;
  var shift = 0;
  int byte;
  do {
    byte = encoded.codeUnitAt(index++) - 63;
    result |= (byte & 0x1f) << shift;
    shift += 5;
  } while (byte >= 0x20);
  final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  return (value, index);
}
