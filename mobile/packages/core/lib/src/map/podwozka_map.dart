import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

/// Where map tiles come from. Default: OpenStreetMap (no key, no billing account).
///
/// The OSM tile usage policy requires an identifying User-Agent and visible attribution,
/// and forbids heavy use — for production traffic point [urlTemplate] at a commercial
/// OSM tile provider or an own tile server: `--dart-define=MAP_TILE_URL=https://…/{z}/{x}/{y}.png`.
class MapTilesConfig {
  const MapTilesConfig({
    required this.urlTemplate,
    required this.userAgentPackageName,
    this.attribution = 'OpenStreetMap',
    this.attributionUrl = 'https://www.openstreetmap.org/copyright',
    this.tileProvider,
  });

  final String urlTemplate;
  final String userAgentPackageName;
  final String attribution;
  final String attributionUrl;

  /// Tests pass a provider that does not touch the network.
  final TileProvider? tileProvider;

  static const defaultUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
}

final mapTilesProvider = Provider<MapTilesConfig>(
  (ref) => MapTilesConfig(
    urlTemplate: MapTilesConfig.defaultUrl,
    userAgentPackageName: ref.watch(appConfigProvider).redirectScheme,
  ),
);

enum MapPinKind { me, pickup, destination, driver }

@immutable
class MapPin {
  const MapPin(this.point, this.kind, {this.heading, this.label});

  final LatLng point;
  final MapPinKind kind;

  /// Driver's heading in degrees (0 = north), from `ride.driver_location`.
  final double? heading;
  final String? label;
}

/// Shared map: OSM tiles, pins (me / pickup / destination / driver), optional route.
/// When [fitToContent] is set the camera keeps all pins and the route in view whenever
/// they change; otherwise it starts at [center].
class PodwozkaMap extends ConsumerStatefulWidget {
  const PodwozkaMap({
    this.center,
    this.zoom = 14,
    this.pins = const [],
    this.route = const [],
    this.fitToContent = true,
    this.padding = const EdgeInsets.fromLTRB(48, 96, 48, 160),
    this.onTap,
    this.onLongPress,
    this.controller,
    this.attributionAlignment = Alignment.bottomRight,
    super.key,
  });

  /// Initial centre when there is nothing to fit (e.g. the user's position).
  final LatLng? center;
  final double zoom;
  final List<MapPin> pins;

  /// Route line. A single segment pickup→destination is drawn dashed (no real route known).
  final List<LatLng> route;
  final bool fitToContent;

  /// Space kept free around the content (app bar on top, bottom sheet below).
  final EdgeInsets padding;
  final void Function(LatLng point)? onTap;
  final void Function(LatLng point)? onLongPress;
  final MapController? controller;

  /// The OSM attribution must stay visible — move it away from bottom sheets / buttons.
  final Alignment attributionAlignment;

  /// Middle of Poland — used only when nothing else is known.
  static const fallbackCenter = LatLng(52.0, 19.4);

  @override
  ConsumerState<PodwozkaMap> createState() => _PodwozkaMapState();
}

class _PodwozkaMapState extends ConsumerState<PodwozkaMap> {
  late final MapController _controller = widget.controller ?? MapController();
  bool _ready = false;

  List<LatLng> get _content => [...widget.pins.map((p) => p.point), ...widget.route];

  @override
  void didUpdateWidget(covariant PodwozkaMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready || !widget.fitToContent) return;
    if (!_sameContent(oldWidget)) _fit();
  }

  bool _sameContent(PodwozkaMap old) {
    final a = [...old.pins.map((p) => p.point), ...old.route];
    final b = _content;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _fit() {
    final points = _content;
    if (points.isEmpty) return;
    if (points.length == 1) {
      _controller.move(points.single, math.max(_controller.camera.zoom, widget.zoom));
      return;
    }
    _controller.fitCamera(
      CameraFit.coordinates(coordinates: points, padding: widget.padding, maxZoom: 16),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(mapTilesProvider);
    final scheme = Theme.of(context).colorScheme;
    final route = widget.route;
    final content = _content;
    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter:
            widget.center ?? (content.isEmpty ? PodwozkaMap.fallbackCenter : content.first),
        initialZoom: widget.center == null && content.isEmpty ? 6 : widget.zoom,
        initialCameraFit: widget.fitToContent && content.length > 1
            ? CameraFit.coordinates(coordinates: content, padding: widget.padding, maxZoom: 16)
            : null,
        minZoom: 5,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () => _ready = true,
        onTap: widget.onTap == null ? null : (_, point) => widget.onTap!(point),
        onLongPress: widget.onLongPress == null ? null : (_, point) => widget.onLongPress!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: tiles.urlTemplate,
          userAgentPackageName: tiles.userAgentPackageName,
          tileProvider: tiles.tileProvider,
          maxNativeZoom: 19,
        ),
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 5,
                color: scheme.primary,
                borderStrokeWidth: 2,
                borderColor: scheme.surface,
                pattern: route.length == 2
                    ? StrokePattern.dashed(segments: const [12, 8])
                    : const StrokePattern.solid(),
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final pin in widget.pins)
              Marker(
                point: pin.point,
                width: 48,
                height: 48,
                alignment: pin.kind == MapPinKind.pickup || pin.kind == MapPinKind.destination
                    ? Alignment.topCenter
                    : Alignment.center,
                child: _PinIcon(pin: pin),
              ),
          ],
        ),
        SimpleAttributionWidget(
          source: Text(tiles.attribution),
          alignment: widget.attributionAlignment,
          onTap: () => launchUrl(Uri.parse(tiles.attributionUrl)),
        ),
      ],
    );
  }
}

class _PinIcon extends StatelessWidget {
  const _PinIcon({required this.pin});

  final MapPin pin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, semantics) = switch (pin.kind) {
      MapPinKind.me => (Icons.my_location, scheme.primary, 'Twoja pozycja'),
      MapPinKind.pickup => (Icons.trip_origin, scheme.primary, 'Miejsce odbioru'),
      MapPinKind.destination => (Icons.place, scheme.error, 'Cel podróży'),
      MapPinKind.driver => (Icons.local_taxi, scheme.tertiary, 'Kierowca'),
    };
    Widget child = Icon(icon, color: color, size: pin.kind == MapPinKind.destination ? 44 : 32);
    if (pin.kind == MapPinKind.driver || pin.kind == MapPinKind.me) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Padding(padding: const EdgeInsets.all(4), child: child),
      );
    }
    return Semantics(label: pin.label ?? semantics, child: child);
  }
}
