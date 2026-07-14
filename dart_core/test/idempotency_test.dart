import 'package:telebirr_sdk_core/src/idempotency.dart';
import 'package:test/test.dart';

void main() {
  group('generateIdempotencyKey', () {
    test('returns a 64-char hex string', () {
      final key = generateIdempotencyKey('order-123');
      expect(key.length, 64);
      expect(RegExp(r'^[0-9A-F]+$').hasMatch(key), isTrue);
    });

    test('returns same key for same orderId', () {
      final key1 = generateIdempotencyKey('order-123');
      final key2 = generateIdempotencyKey('order-123');
      expect(key1, key2);
    });

    test('returns different keys for different orderIds', () {
      final key1 = generateIdempotencyKey('order-123');
      final key2 = generateIdempotencyKey('order-456');
      expect(key1, isNot(key2));
    });
  });
}
