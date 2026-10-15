import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'model.dart';
import 'static_map_controller.dart';
export 'model.dart';
export 'static_map_controller.dart';

class StaticMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String apiKey;
  final int zoom;
  final int width;
  final int height;
  final StaticMapType mapType;
  final List<StaticMapMarker> markers;

  const StaticMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.apiKey,
    this.zoom = 14,
    this.width = 600,
    this.height = 300,
    this.mapType = StaticMapType.roadmap,
    this.markers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final StaticMapsController mapsController =
        StaticMapsController(apiKey: apiKey);

    try {
      final url = mapsController.getStaticMapUrl(
        latitude: latitude,
        longitude: longitude,
        zoom: zoom,
        width: width,
        height: height,
        mapType: mapType,
        markers: markers,
      );

      return FutureBuilder<Uint8List>(
        future: mapsController.fetchStaticMapImage(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Image.memory(
              snapshot.data!,
              width: width.toDouble(),
              height: height.toDouble(),
              fit: BoxFit.cover,
            );
          }
        },
      );
    } catch (e) {
      return Center(child: Text('Error: $e'));
    }
  }
}
