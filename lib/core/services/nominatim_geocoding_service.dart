import 'dart:convert';

import 'package:http/http.dart' as http;

/// A geocoded place returned by Nominatim OpenStreetMap search.
class GeocodingPlace {
  final String displayName;
  final double latitude;
  final double longitude;

  const GeocodingPlace({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Lightweight OpenStreetMap Nominatim geocoding and reverse-geocoding client.
class NominatimGeocodingService {
  static const String _baseHost = 'nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'ShiftIQMobile/1.0 (workshop-branch-locator)',
    'Accept': 'application/json',
  };

  final http.Client _client;

  NominatimGeocodingService({http.Client? client})
      : _client = client ?? http.Client();

  /// Searches matching places for a free-text street address or district query.
  Future<List<GeocodingPlace>> searchAddress(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];

    final uri = Uri.https(_baseHost, '/search', {
      'q': trimmed,
      'format': 'jsonv2',
      'limit': '5',
      'addressdetails': '1',
    });

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      final results = <GeocodingPlace>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final lat = double.tryParse(item['lat']?.toString() ?? '');
        final lon = double.tryParse(item['lon']?.toString() ?? '');
        final name = item['display_name']?.toString().trim() ?? '';
        if (lat != null && lon != null && name.isNotEmpty) {
          results.add(
            GeocodingPlace(
              displayName: name,
              latitude: lat,
              longitude: lon,
            ),
          );
        }
      }
      return results;
    } catch (_) {
      return const [];
    }
  }

  /// Resolves a concise human-readable address for the given coordinates.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final uri = Uri.https(_baseHost, '/reverse', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'format': 'jsonv2',
      'addressdetails': '1',
    });

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final addressMap = decoded['address'];
      if (addressMap is Map<String, dynamic>) {
        final road = addressMap['road']?.toString().trim();
        final houseNumber = addressMap['house_number']?.toString().trim();
        final suburb = addressMap['suburb']?.toString().trim() ??
            addressMap['neighbourhood']?.toString().trim() ??
            addressMap['city_district']?.toString().trim();
        final city = addressMap['city']?.toString().trim() ??
            addressMap['town']?.toString().trim() ??
            addressMap['state']?.toString().trim();

        final parts = <String>[];
        if (road != null && road.isNotEmpty) {
          parts.add(
            houseNumber != null && houseNumber.isNotEmpty
                ? '$road $houseNumber'
                : road,
          );
        }
        if (suburb != null && suburb.isNotEmpty) parts.add(suburb);
        if (city != null && city.isNotEmpty && city != suburb) parts.add(city);
        if (parts.isNotEmpty) return parts.join(', ');
      }

      final display = decoded['display_name']?.toString().trim();
      return (display != null && display.isNotEmpty) ? display : null;
    } catch (_) {
      return null;
    }
  }
}
