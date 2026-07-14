/**
 * Configuration for the retry wrapper.
 */
export interface RetryConfig {
  /** Maximum number of attempts (including the first call). Defaults to `3`. */
  maxAttempts?: number;

  /** Initial delay in milliseconds before the first retry. Defaults to `1000`. */
  baseDelayMs?: number;

  /** Maximum delay in milliseconds between retries. Defaults to `10000`. */
  maxDelayMs?: number;

  /**
   * Predicate that determines whether a failed attempt should be retried.
   * Receives the caught error and returns `true` to retry.
   * Defaults to retrying on `NETWORK_ERROR` and `TOKEN_FAILED` error codes.
   */
  retryOn?: (error: unknown) => boolean;
}

/**
 * Default retry predicate — retries on `NETWORK_ERROR` and `TOKEN_FAILED` error codes.
 */
const DEFAULT_RETRY_ON = (error: unknown): boolean => {
  if (error && typeof error === 'object' && 'code' in error) {
    const code = (error as { code: string }).code;
    return code === 'NETWORK_ERROR' || code === 'TOKEN_FAILED';
  }
  return false;
};

/**
 * Wraps an async function with retry logic using exponential backoff.
 *
 * On each failed attempt where `retryOn` returns `true`, the function is
 * retried after a delay of `baseDelayMs * 2^(attempt-1)`, capped at `maxDelayMs`.
 *
 * @typeParam T - Return type of the wrapped function.
 * @param fn - Async function to execute with retry.
 * @param config - Optional retry configuration.
 * @returns The result of `fn` on the first successful attempt.
 * @throws The last error if all attempts fail.
 *
 * @example
 * ```ts
 * const result = await withRetry(
 *   () => telebirr.payments.charge({ amount: '100', title: 'Test' }),
 *   { maxAttempts: 5, baseDelayMs: 500 },
 * );
 * ```
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  config?: RetryConfig,
): Promise<T> {
  const maxAttempts = config?.maxAttempts ?? 3;
  const baseDelayMs = config?.baseDelayMs ?? 1000;
  const maxDelayMs = config?.maxDelayMs ?? 10000;
  const retryOn = config?.retryOn ?? DEFAULT_RETRY_ON;

  let lastError: unknown;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (attempt >= maxAttempts || !retryOn(error)) {
        throw error;
      }
      const delay = Math.min(baseDelayMs * 2 ** (attempt - 1), maxDelayMs);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }
  throw lastError;
}
