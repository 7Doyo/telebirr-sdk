import 'package:telebirr_sdk_core/src/token_cache.dart';
import 'package:test/test.dart';

void main() {
  group('TokenCache', () {
    test('returns null when empty', () {
      final cache = TokenCache();
      expect(cache.get(), isNull);
    });

    test('returns cached token', () {
      final cache = TokenCache();
      cache.set('test-token');
      expect(cache.get(), 'test-token');
    });

    test('returns null after TTL expires', () async {
      final cache = TokenCache(ttl: Duration(milliseconds: 1));
      cache.set('test-token');
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(cache.get(), isNull);
    });

    test('clears token', () {
      final cache = TokenCache();
      cache.set('test-token');
      cache.clear();
      expect(cache.get(), isNull);
    });
  });
}
