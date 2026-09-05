import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../config/app_config.dart';
import '../../data/models/lat_lng.dart';
import 'app_map_placeholder.dart';

/// Marker spec decoupled from google_maps types.
class MapMarker {
  final String id;
  final GeoPoint position;
  final double hue; // gmap.BitmapDescriptor hue (0–360)
  final String? title;

  const MapMarker({
    required this.id,
    required this.position,
    this.hue = 120, // green
    this.title,
  });
}

/// A map widget that renders real Google Maps when an API key is configured,
/// otherwise falls back to the animated painted placeholder.
///
/// This lets the whole app work today (placeholder) and instantly upgrade to
/// real maps the moment you build with:
///   flutter run --dart-define=GOOGLE_MAPS_KEY=YOUR_KEY
class BikeJeeMap extends StatefulWidget {
  final GeoPoint? center;
  final List<MapMarker> markers;
  final List<GeoPoint> routePolyline;
  final double height;
  final bool isFullScreen;
  final bool myLocationEnabled;
  final void Function(gmap.GoogleMapController)? onMapCreated;

  const BikeJeeMap({
    super.key,
    this.center,
    this.markers = const [],
    this.routePolyline = const [],
    this.height = 220,
    this.isFullScreen = false,
    this.myLocationEnabled = true,
    this.onMapCreated,
  });

  @override
  State<BikeJeeMap> createState() => _BikeJeeMapState();
}

class _BikeJeeMapState extends State<BikeJeeMap> {
  gmap.GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    // No key → animated placeholder keeps the UI functional
    if (!AppConfig.hasMapsKey) {
      return AppMapPlaceholder(
        height: widget.height,
        isFullScreen: widget.isFullScreen,
        showRoute: widget.routePolyline.isNotEmpty || widget.markers.length > 1,
      );
    }

    final center = widget.center ??
        (widget.markers.isNotEmpty
            ? widget.markers.first.position
            : const GeoPoint(latitude: 12.9716, longitude: 77.5946));

    final googleMap = gmap.GoogleMap(
      initialCameraPosition: gmap.CameraPosition(
        target: gmap.LatLng(center.latitude, center.longitude),
        zoom: 15,
      ),
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      markers: widget.markers
          .map((m) => gmap.Marker(
                markerId: gmap.MarkerId(m.id),
                position: gmap.LatLng(m.position.latitude, m.position.longitude),
                icon: gmap.BitmapDescriptor.defaultMarkerWithHue(m.hue),
                infoWindow: gmap.InfoWindow(title: m.title),
              ))
          .toSet(),
      polylines: widget.routePolyline.length >= 2
          ? {
              gmap.Polyline(
                polylineId: const gmap.PolylineId('route'),
                width: 5,
                color: const Color(0xFF00B14F),
                points: widget.routePolyline
                    .map((p) => gmap.LatLng(p.latitude, p.longitude))
                    .toList(),
              ),
            }
          : {},
      onMapCreated: (c) {
        _controller = c;
        widget.onMapCreated?.call(c);
      },
    );

    if (widget.isFullScreen) return googleMap;
    return SizedBox(height: widget.height, child: googleMap);
  }

  /// Animate the camera to a new position.
  Future<void> moveTo(GeoPoint p, {double zoom = 15}) async {
    await _controller?.animateCamera(
      gmap.CameraUpdate.newLatLngZoom(
        gmap.LatLng(p.latitude, p.longitude),
        zoom,
      ),
    );
  }
}
