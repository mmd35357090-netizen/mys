import 'package:flutter/material.dart';

enum StaticMapType {
  roadmap,
  satellite,
  terrain,
  hybrid,
}

class GeocodedLocation {
  final String? address;
  final double? latitude;
  final double? longitude;

  GeocodedLocation.address(this.address)
      : latitude = null,
        longitude = null;

  GeocodedLocation.latLng(this.latitude, this.longitude) : address = null;
}

class StaticMapMarker {
  final Color color;
  final String label;
  final List<GeocodedLocation> locations;
  final String? icon;
  final MarkerAnchor anchor;

  StaticMapMarker({
    required this.color,
    required this.label,
    required this.locations,
    this.icon,
    this.anchor = MarkerAnchor.center,
  });

  static StaticMapMarker custom({
    required String icon,
    required MarkerAnchor anchor,
    required List<GeocodedLocation> locations,
  }) {
    return StaticMapMarker(
      color: Colors.transparent,
      label: '',
      locations: locations,
      icon: icon,
      anchor: anchor,
    );
  }
}

enum MarkerAnchor {
  center,
  topleft,
}
