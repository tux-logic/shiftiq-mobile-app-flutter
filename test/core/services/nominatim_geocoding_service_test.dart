import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/services/nominatim_geocoding_service.dart';

void main() {
  group('NominatimGeocodingService', () {
    test('searchAddress parses valid Nominatim places', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'nominatim.openstreetmap.org');
        expect(request.url.path, '/search');
        expect(request.url.queryParameters['q'], 'Av Javier Prado 4200');
        return http.Response(
          jsonEncode([
            {
              'display_name': 'Av. Javier Prado Este 4200, Santiago de Surco, Lima',
              'lat': '-12.0859',
              'lon': '-76.9762',
            },
          ]),
          200,
        );
      });

      final service = NominatimGeocodingService(client: client);
      final places = await service.searchAddress('Av Javier Prado 4200');

      expect(places, hasLength(1));
      expect(
        places.first.displayName,
        'Av. Javier Prado Este 4200, Santiago de Surco, Lima',
      );
      expect(places.first.latitude, closeTo(-12.0859, 0.0001));
      expect(places.first.longitude, closeTo(-76.9762, 0.0001));
    });

    test('searchAddress skips network call for queries shorter than 3 chars', () async {
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('[]', 200);
      });

      final service = NominatimGeocodingService(client: client);
      final places = await service.searchAddress('Av');

      expect(called, isFalse);
      expect(places, isEmpty);
    });

    test('reverseGeocode formats concise street, suburb, and city', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/reverse');
        return http.Response(
          jsonEncode({
            'display_name': 'Full long fallback',
            'address': {
              'road': 'Av. Primavera',
              'house_number': '1250',
              'suburb': 'Santiago de Surco',
              'city': 'Lima',
            },
          }),
          200,
        );
      });

      final service = NominatimGeocodingService(client: client);
      final address = await service.reverseGeocode(-12.1112, -76.9821);

      expect(address, 'Av. Primavera 1250, Santiago de Surco, Lima');
    });
  });
}
