<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

/**
 * Generic retry utility with exponential backoff.
 *
 * Wraps a callable and retries it on transient failures using exponential
 * backoff with configurable maximum attempts and delay.
 */
class Retry
{
    /**
     * Execute a callable with automatic retry and exponential backoff.
     *
     * Retries the callable on failure up to the specified maximum attempts.
     * Delay between attempts doubles each time (exponential backoff) and is
     * capped at the maximum delay. By default, retries on NETWORK_ERROR or
     * TOKEN_FAILED error codes, but a custom retry condition can be provided.
     *
     * @template T Return type of the callable
     *
     * @param callable(): T $fn The callable to execute with retry logic
     * @param array<string, mixed> $config Optional retry configuration
     * @param int $config['maxAttempts'] Maximum number of attempts (default: 3)
     * @param int $config['baseDelayMs'] Base delay in milliseconds between retries (default: 1000)
     * @param int $config['maxDelayMs'] Maximum delay cap in milliseconds (default: 10000)
     * @param callable(\Throwable): bool|null $config['retryOn'] Custom retry condition; receives the exception and returns true to retry
     *
     * @return T The return value of the callable on success
     *
     * @throws \Throwable Re-throws the last exception if all attempts fail or the error is not retryable
     */
    public static function withRetry(callable $fn, array $config = []): mixed
    {
        $maxAttempts = $config['maxAttempts'] ?? 3;
        $baseDelayMs = $config['baseDelayMs'] ?? 1000;
        $maxDelayMs = $config['maxDelayMs'] ?? 10000;
        $retryOn = $config['retryOn'] ?? null;

        $lastError = null;

        for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {
            try {
                return $fn();
            } catch (\Throwable $error) {
                $lastError = $error;
                $shouldRetry = $retryOn !== null ? $retryOn($error) : in_array(
                    $error->getCode(),
                    ['NETWORK_ERROR', 'TOKEN_FAILED'],
                    true,
                );
                if ($attempt >= $maxAttempts || !$shouldRetry) {
                    throw $error;
                }
                $delay = min($baseDelayMs * (1 << ($attempt - 1)), $maxDelayMs);
                usleep($delay * 1000);
            }
        }

        throw $lastError;
    }
}
