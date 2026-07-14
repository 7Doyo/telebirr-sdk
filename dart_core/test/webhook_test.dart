import 'package:telebirr_sdk_core/src/webhook.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationTradeStatus', () {
    test('has correct values', () {
      expect(NotificationTradeStatus.paying.value, 'Paying');
      expect(NotificationTradeStatus.expired.value, 'Expired');
      expect(NotificationTradeStatus.pending.value, 'Pending');
      expect(NotificationTradeStatus.completed.value, 'Completed');
      expect(NotificationTradeStatus.failure.value, 'Failure');
    });
  });

  group('buildNotificationSignString', () {
    test('excludes sign and sign_type', () {
      final payload = {
        'merch_order_id': 'order-123',
        'payment_order_id': 'pay-456',
        'trade_status': 'Completed',
        'sign': 'some-signature',
        'sign_type': 'SHA256WithRSA',
      };

      final result = buildNotificationSignString(payload);

      expect(result, contains('merch_order_id=order-123'));
      expect(result, contains('payment_order_id=pay-456'));
      expect(result, contains('trade_status=Completed'));
      expect(result, isNot(contains('sign=')));
      expect(result, isNot(contains('sign_type=')));
    });

    test('sorts keys lexicographically', () {
      final payload = {
        'zebra': 'z',
        'alpha': 'a',
        'middle': 'm',
      };

      final result = buildNotificationSignString(payload);
      expect(result, 'alpha=a&middle=m&zebra=z');
    });
  });

  group('NotificationPayload', () {
    test('accesses fields correctly', () {
      final raw = {
        'merch_order_id': 'order-123',
        'payment_order_id': 'pay-456',
        'trade_status': 'Completed',
        'total_amount': '100',
      };

      final payload = NotificationPayload(raw);

      expect(payload.merchOrderId, 'order-123');
      expect(payload.paymentOrderId, 'pay-456');
      expect(payload.tradeStatus, 'Completed');
      expect(payload.totalAmount, '100');
    });
  });

  group('verifyNotification', () {
    test('returns false when sign is missing', () {
      final payload = NotificationPayload({
        'merch_order_id': 'order-123',
        'trade_status': 'Completed',
      });

      expect(verifyNotification(payload, 'fake-public-key'), isFalse);
    });
  });
}
