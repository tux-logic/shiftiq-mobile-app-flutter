import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations system locale & ARB parity', () {
    test('resolveInitialLocale respects saved override first', () {
      expect(
        AppLocalizations.resolveInitialLocale('en', const Locale('es', 'PE')),
        const Locale('en'),
      );
      expect(
        AppLocalizations.resolveInitialLocale('es', const Locale('en', 'US')),
        const Locale('es'),
      );
    });

    test('resolveInitialLocale uses system locale when supported', () {
      expect(
        AppLocalizations.resolveInitialLocale(null, const Locale('en', 'US')),
        const Locale('en'),
      );
      expect(
        AppLocalizations.resolveInitialLocale('', const Locale('es', 'MX')),
        const Locale('es'),
      );
    });

    test('resolveInitialLocale falls back to Spanish when system locale is unsupported', () {
      expect(
        AppLocalizations.resolveInitialLocale(null, const Locale('fr', 'FR')),
        const Locale('es'),
      );
      expect(
        AppLocalizations.resolveInitialLocale(null, const Locale('pt', 'BR')),
        const Locale('es'),
      );
    });

    test('app_es.arb and app_en.arb have 100% key parity and non-empty values', () {
      final esMap = jsonDecode(File('lib/l10n/app_es.arb').readAsStringSync())
          as Map<String, dynamic>;
      final enMap = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;

      final esKeys = esMap.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();

      expect(esKeys, equals(enKeys));
      for (final key in esKeys) {
        expect((esMap[key] as String).trim(), isNotEmpty, reason: 'Empty ES: $key');
        expect((enMap[key] as String).trim(), isNotEmpty, reason: 'Empty EN: $key');
      }
    });
  });
}
