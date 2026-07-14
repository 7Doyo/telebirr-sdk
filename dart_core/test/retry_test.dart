import 'package:telebirr_sdk_core/src/retry.dart';
import 'package:test/test.dart';

void main() {
  group('withRetry', () {
    test('returns result on success', () async {
      final result = await withRetry(() async => 'ok');
      expect(result, 'ok');
    });

    test('retries on retryable error', () async {
      var attempts = 0;
      final result = await withRetry(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('Network error');
          return 'ok';
        },
        config: RetryConfig(
          maxAttempts: 3,
          baseDelay: Duration(milliseconds: 1),
          retryOn: (e) => true,
        ),
      );
      expect(result, 'ok');
      expect(attempts, 3);
    });

    test('throws after max attempts', () async {
      expect(
        () => withRetry(
          () async {
            throw Exception('fail');
          },
          config: RetryConfig(
            maxAttempts: 2,
            baseDelay: Duration(milliseconds: 1),
            retryOn: (e) => true,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('does not retry on non-retryable error', () async {
      var attempts = 0;
      expect(
        () => withRetry(
          () async {
            attempts++;
            throw Exception('Validation error');
          },
          config: RetryConfig(
            maxAttempts: 3,
            baseDelay: Duration(milliseconds: 1),
          ),
        ),
        throwsA(isA<Exception>()),
      );
      expect(attempts, 1);
    });
  });
}
