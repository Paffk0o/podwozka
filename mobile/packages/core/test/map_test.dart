import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// 1×1 transparent PNG — tiles without network access.
final _transparentPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

class _OfflineTiles extends TileProvider {
  int requests = 0;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    requests++;
    return MemoryImage(_transparentPng);
  }
}

Future<_OfflineTiles> _pumpMap(WidgetTester tester, PodwozkaMap map) async {
  final tiles = _OfflineTiles();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapTilesProvider.overrideWithValue(
          MapTilesConfig(
            urlTemplate: 'https://tiles.test/{z}/{x}/{y}.png',
            userAgentPackageName: 'pl.podwozka.test',
            tileProvider: tiles,
          ),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: map)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
  return tiles;
}

void main() {
  group('decodePolyline', () {
    test('decodes the reference example from the Google documentation', () {
      final points = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(points, hasLength(3));
      expect(points[0].latitude, closeTo(38.5, 1e-6));
      expect(points[0].longitude, closeTo(-120.2, 1e-6));
      expect(points[1].latitude, closeTo(40.7, 1e-6));
      expect(points[1].longitude, closeTo(-120.95, 1e-6));
      expect(points[2].latitude, closeTo(43.252, 1e-6));
      expect(points[2].longitude, closeTo(-126.453, 1e-6));
    });

    test('missing or truncated polyline → no route (straight line fallback)', () {
      expect(decodePolyline(null), isEmpty);
      expect(decodePolyline(''), isEmpty);
      expect(decodePolyline('_p~iF~ps'), isEmpty);
    });
  });

  test('API places convert to map coordinates', () {
    final place = Place(location: GeoPoint(lat: 50.1, lng: 19.9), address: 'Rynek 1');
    expect(place.toLatLng(), const LatLng(50.1, 19.9));
    expect(const LatLng(50.1, 19.9).toGeoPoint().lat, 50.1);
  });

  testWidgets('shows pins, OSM attribution and loads tiles through the configured provider', (
    tester,
  ) async {
    final tiles = await _pumpMap(
      tester,
      const PodwozkaMap(
        pins: [
          MapPin(LatLng(50.06, 19.94), MapPinKind.pickup),
          MapPin(LatLng(50.08, 19.98), MapPinKind.destination),
          MapPin(LatLng(50.07, 19.95), MapPinKind.driver),
        ],
        route: [LatLng(50.06, 19.94), LatLng(50.08, 19.98)],
      ),
    );

    expect(find.byIcon(Icons.trip_origin), findsOneWidget); // pickup
    expect(find.byIcon(Icons.place), findsOneWidget); // destination
    expect(find.byIcon(Icons.local_taxi), findsOneWidget); // driver
    expect(find.text('© OpenStreetMap'), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(tiles.requests, greaterThan(0));
  });

  testWidgets('tap on the map reports the coordinates (pin dropping)', (tester) async {
    LatLng? tapped;
    await _pumpMap(
      tester,
      PodwozkaMap(center: const LatLng(50.06, 19.94), onTap: (point) => tapped = point),
    );

    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tapped, isNotNull);
    expect(tapped!.latitude, closeTo(50.06, 0.01));
    expect(tapped!.longitude, closeTo(19.94, 0.01));
  });
}
