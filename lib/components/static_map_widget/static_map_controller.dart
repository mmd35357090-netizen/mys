import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'model.dart';

class StaticMapsController {
  final String apiKey;
  final String baseUrl = 'https://maps.googleapis.com/maps/api/staticmap';

  StaticMapsController({required this.apiKey});

  String getStaticMapUrl({
    required double latitude,
    required double longitude,
    int zoom = 14,
    int width = 600,
    int height = 300,
    StaticMapType mapType = StaticMapType.roadmap,
    List<StaticMapMarker> markers = const [],
  }) {
    // Ensure width and height are positive integers
    if (width <= 0 || height <= 0) {
      throw Exception('Invalid size parameters. Width and height must be positive integers.');
    }

    final markersParam = _buildMarkersParam(markers);
    final url = Uri.parse(baseUrl).replace(queryParameters: {
      'center': '$latitude,$longitude',
      'zoom': zoom.toString(),
      'size': '${width}x$height',
      'maptype': mapType.name,
      'markers': markersParam,
      'key': apiKey,
    }).toString();

    return url;
  }

  Future<Uint8List> fetchStaticMapImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load static map image: ${response.reasonPhrase}');
    }
  }

  String _buildMarkersParam(List<StaticMapMarker> markers) {
    return markers.map((marker) {
      final colorHex = '#${marker.color.value.toRadixString(16).substring(2)}';
      final locations = marker.locations.map((loc) {
        if (loc.address != null) {
          return loc.address!;
        } else {
          return '${loc.latitude},${loc.longitude}';
        }
      }).join('|');

      final parts = <String>[
        if (marker.icon != null) 'icon:${marker.icon}',
        'color:$colorHex',
        'label:${marker.label}',
        locations,
      ];

      return parts.join('|');
    }).join('&markers=');
  }
}
