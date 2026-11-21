import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

class _FakeSessionStorage extends SessionStorage {
  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> getRefreshToken() async => null;
}

void main() {
  group('ApiClient.uploadMultipart', () {
    test('sets image/jpeg Content-Type for .jpg uploads instead of octet-stream',
        () async {
      late String capturedBody;
      final client = MockClient((request) async {
        capturedBody = utf8.decode(request.bodyBytes, allowMalformed: true);
        return http.Response(
          jsonEncode({'url': 'https://cdn.example.com/branch.jpg'}),
          200,
        );
      });

      final apiClient = ApiClient(
        sessionStorage: _FakeSessionStorage(),
        client: client,
      );

      await apiClient.uploadMultipart(
        '/api/v1/media/upload',
        fileBytes: [0xFF, 0xD8, 0xFF, 0xE0],
        fileName: 'branch_cover.jpg',
      );

      expect(capturedBody, contains('content-type: image/jpeg'));
      expect(capturedBody, isNot(contains('application/octet-stream')));
    });

    test('sets image/png Content-Type for .png uploads', () async {
      late String capturedBody;
      final client = MockClient((request) async {
        capturedBody = utf8.decode(request.bodyBytes, allowMalformed: true);
        return http.Response(
          jsonEncode({'url': 'https://cdn.example.com/branch.png'}),
          200,
        );
      });

      final apiClient = ApiClient(
        sessionStorage: _FakeSessionStorage(),
        client: client,
      );

      await apiClient.uploadMultipart(
        '/api/v1/media/upload',
        fileBytes: [0x89, 0x50, 0x4E, 0x47],
        fileName: 'branch_cover.png',
      );

      expect(capturedBody, contains('content-type: image/png'));
    });
  });
}
