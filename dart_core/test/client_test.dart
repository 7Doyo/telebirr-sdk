import 'package:telebirr_sdk_core/src/client.dart';
import 'package:telebirr_sdk_core/src/exceptions.dart';
import 'package:telebirr_sdk_core/src/models/config.dart';
import 'package:telebirr_sdk_core/src/models/query_order.dart';
import 'package:test/test.dart';

void main() {
  group('Telebirr', () {
    test('constructs successfully with valid sandbox config', () {
      final config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_test_abc123',
        privateKeyPem:
            '-----BEGIN PRIVATE KEY-----\nMIIB...\n-----END PRIVATE KEY-----',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      final telebirr = Telebirr(config);
      expect(telebirr.payments, isA<Payments>());
    });

    test('constructs successfully with live key in production', () {
      final config = TelebirrConfig(
        environment: Environment.production,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_live_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      final telebirr = Telebirr(config);
      expect(telebirr.payments, isA<Payments>());
    });

    test('throws EnvironmentException when test key used in production', () {
      final config = TelebirrConfig(
        environment: Environment.production,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_test_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(
        () => Telebirr(config),
        throwsA(
          isA<TelebirrException>().having(
            (e) => e.code,
            'code',
            'ENVIRONMENT',
          ),
        ),
      );
    });

    test('throws EnvironmentException when live key used in sandbox', () {
      final config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_live_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(
        () => Telebirr(config),
        throwsA(
          isA<TelebirrException>().having(
            (e) => e.code,
            'code',
            'ENVIRONMENT',
          ),
        ),
      );
    });

    test('does not throw with generic key in sandbox', () {
      final config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'generic-secret',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(() => Telebirr(config), returnsNormally);
    });

    test('does not throw with generic key in production', () {
      final config = TelebirrConfig(
        environment: Environment.production,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'generic-secret',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(() => Telebirr(config), returnsNormally);
    });
  });

  group('TelebirrConfig', () {
    test('effectiveBaseUrl returns sandbox URL for sandbox environment', () {
      final config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_test_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(
        config.effectiveBaseUrl,
        'https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway',
      );
    });

    test('effectiveBaseUrl returns production URL for production environment',
        () {
      final config = TelebirrConfig(
        environment: Environment.production,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_live_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
      );

      expect(
        config.effectiveBaseUrl,
        'https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway',
      );
    });

    test('effectiveBaseUrl uses custom baseUrl when provided', () {
      final config = TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '00000000-0000-0000-0000-000000000000',
        merchantAppId: '12345',
        merchantCode: 'MC001',
        appSecret: 'sk_test_abc123',
        privateKeyPem: 'key',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://example.com/hook',
        baseUrl: 'https://custom.example.com/gateway',
      );

      expect(config.effectiveBaseUrl, 'https://custom.example.com/gateway');
    });
  });

  group('PaymentStatus', () {
    test('has correct enum values', () {
      expect(PaymentStatus.success.name, 'success');
      expect(PaymentStatus.fail.name, 'fail');
      expect(PaymentStatus.timeout.name, 'timeout');
      expect(PaymentStatus.pending.name, 'pending');
      expect(PaymentStatus.accepted.name, 'accepted');
      expect(PaymentStatus.refunding.name, 'refunding');
      expect(PaymentStatus.refundSuccess.name, 'refundSuccess');
      expect(PaymentStatus.refundFailed.name, 'refundFailed');
    });
  });

  group('mapTelebirrStatus', () {
    test('maps PAY_SUCCESS to success', () {
      expect(mapTelebirrStatus('PAY_SUCCESS'), PaymentStatus.success);
    });

    test('maps PAY_FAILED to fail', () {
      expect(mapTelebirrStatus('PAY_FAILED'), PaymentStatus.fail);
    });

    test('maps ORDER_CLOSED to timeout', () {
      expect(mapTelebirrStatus('ORDER_CLOSED'), PaymentStatus.timeout);
    });

    test('maps WAIT_PAY to pending', () {
      expect(mapTelebirrStatus('WAIT_PAY'), PaymentStatus.pending);
    });

    test('maps PAYING to pending', () {
      expect(mapTelebirrStatus('PAYING'), PaymentStatus.pending);
    });

    test('maps ACCEPTED to accepted', () {
      expect(mapTelebirrStatus('ACCEPTED'), PaymentStatus.accepted);
    });

    test('maps REFUNDING to refunding', () {
      expect(mapTelebirrStatus('REFUNDING'), PaymentStatus.refunding);
    });

    test('maps REFUND_SUCCESS to refundSuccess', () {
      expect(mapTelebirrStatus('REFUND_SUCCESS'), PaymentStatus.refundSuccess);
    });

    test('maps REFUND_FAILED to refundFailed', () {
      expect(mapTelebirrStatus('REFUND_FAILED'), PaymentStatus.refundFailed);
    });

    test('returns pending for unknown status', () {
      expect(mapTelebirrStatus('UNKNOWN'), PaymentStatus.pending);
    });
  });
}
