import 'package:flutter_test/flutter_test.dart';
import 'package:zbd_ramp/zbd_ramp.dart';

void main() {
  group('ZBD Ramp Package Tests', () {
    test('RampConfig creation', () {
      const config = RampConfig(
        sessionToken: 'test-token',
        environment: Environment.production,
      );

      expect(config.sessionToken, 'test-token');
      expect(config.environment, Environment.production);
    });

    test('RampConfig with secret', () {
      const config = RampConfig(
        sessionToken: 'test-token',
        environment: Environment.x1,
        secret: 'test-secret',
      );

      expect(config.sessionToken, 'test-token');
      expect(config.environment, Environment.x1);
      expect(config.secret, 'test-secret');
    });

    test('RampCallbacks creation', () {
      final callbacks = RampCallbacks(
        onSuccess: (data) {},
        onError: (error) {},
        onReady: () {},
        onClose: () {},
      );

      expect(callbacks.onSuccess, isNotNull);
      expect(callbacks.onError, isNotNull);
      expect(callbacks.onReady, isNotNull);
      expect(callbacks.onClose, isNotNull);
    });

    test('RampError creation from json', () {
      final errorJson = {
        'code': 'PAYMENT_ERROR',
        'message': 'Payment failed',
        'details': {'status': '500'}
      };

      final error = RampError.fromJson(errorJson);

      expect(error.code, 'PAYMENT_ERROR');
      expect(error.message, 'Payment failed');
      expect(error.details, {'status': '500'});
    });

    test('RampError toString', () {
      const error = RampError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      final string = error.toString();
      expect(string, contains('TEST_ERROR'));
      expect(string, contains('Test error message'));
    });

    test('RampLog creation from json', () {
      final logJson = {
        'level': 'info',
        'message': 'Test log message',
        'data': {'key': 'value'}
      };

      final log = RampLog.fromJson(logJson);

      expect(log.level, LogLevel.info);
      expect(log.message, 'Test log message');
      expect(log.data, {'key': 'value'});
    });
  });
}