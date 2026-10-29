import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/domain/value_objects/email.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/domain/value_objects/password.dart';

void main() {
  group('Value Objects Test', () {
    test('Email VO validation', () {
      expect(Email('user@shiftiq.com').isValid, true);
      expect(Email('invalid-email').isValid, false);
      expect(Email('').isValid, false);
    });

    test('Password VO validation', () {
      expect(Password('Secret123!').isValid, true);
      expect(Password('short').isValid, false);
      expect(Password('').isValid, false);
    });
  });
}
