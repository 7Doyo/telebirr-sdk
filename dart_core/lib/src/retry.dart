/// A predicate function that determines whether an error is retryable.
///
/// Returns `true` if the given [error] should trigger a retry attempt.
typedef RetryPredicate = bool Function(Object error);

/// Configuration for the retry mechanism.
///
/// Controls how many times a failed operation is retried and the delay
/// between attempts using exponential backoff.
///
/// Example:
/// ```dart
/// final config = RetryConfig(
///   maxAttempts: 5,
///   baseDelay: Duration(milliseconds: 500),
///   maxDelay: Duration(seconds: 30),
///   retryOn: (error) => error is NetworkException,
/// );
/// final result = await withRetry(() => apiCall(), config: config);
/// ```
class RetryConfig {
  /// The maximum number of total attempts (including the initial call).
  ///
  /// Defaults to `3`.
  final int maxAttempts;

  /// The base delay between retries.
  ///
  /// The actual delay doubles with each attempt (exponential backoff),
  /// up to [maxDelay]. Defaults to 1000ms.
  final Duration baseDelay;

  /// The maximum delay between retries.
  ///
  /// Caps the exponential backoff calculation. Defaults to 10000ms.
  final Duration maxDelay;

  /// A predicate that determines whether an error is retryable.
  ///
  /// Only errors for which this returns `true` will trigger a retry.
  /// Defaults to retrying errors whose runtime type contains `'Network'`.
  final RetryPredicate retryOn;

  /// Creates a [RetryConfig] with the given retry behavior.
  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 1000),
    this.maxDelay = const Duration(milliseconds: 10000),
    this.retryOn = _defaultRetryOn,
  });
}

/// Default retry predicate that retries errors whose type name contains `'Network'`.
bool _defaultRetryOn(Object error) {
  if (error is Exception) {
    // In Dart, network exceptions are the retryable ones
    return error.runtimeType.toString().contains('Network');
  }
  return false;
}

/// Executes [fn] with automatic retry and exponential backoff.
///
/// On failure, checks [RetryConfig.retryOn] to decide if the error is
/// retryable. If so, waits for `baseDelay * 2^(attempt-1)` (capped at
/// [RetryConfig.maxDelay]) before retrying.
///
/// [fn] is the async operation to execute.
/// [config] is the optional retry configuration. Uses [RetryConfig] defaults
/// if not provided.
///
/// Returns the result of [fn] on success.
///
/// Throws the last error from [fn] if all attempts fail or the error is
/// not retryable.
///
/// Example:
/// ```dart
/// final result = await withRetry(
///   () => payments.charge(params),
///   config: RetryConfig(maxAttempts: 3),
/// );
/// ```
Future<T> withRetry<T>(
  Future<T> Function() fn, {
  RetryConfig? config,
}) async {
  final cfg = config ?? const RetryConfig();
  Object? lastError;

  for (var attempt = 1; attempt <= cfg.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (attempt >= cfg.maxAttempts || !cfg.retryOn(error)) {
        rethrow;
      }
      final delayMs = cfg.baseDelay.inMilliseconds * (1 << (attempt - 1));
      final cappedDelay = delayMs > cfg.maxDelay.inMilliseconds
          ? cfg.maxDelay
          : Duration(milliseconds: delayMs);
      await Future<void>.delayed(cappedDelay);
    }
  }
  throw lastError!;
}
