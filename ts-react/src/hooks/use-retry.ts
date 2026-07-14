'use client';
import { useState, useCallback, useRef, useEffect } from 'react';
import { useTelebirr } from './use-telebirr.js';
import type { CreateOrderParams, CreateOrderResponse } from '@telebirr-sdk/sdk-core';

/** Configuration for the retry-with-backoff behaviour. */
interface RetryConfig {
  /** Maximum number of charge attempts (default: 3). */
  maxAttempts?: number;
  /** Base delay in milliseconds for the exponential backoff (default: 1000). */
  baseDelayMs?: number;
  /** Maximum delay in milliseconds cap (default: 30000). */
  maxDelayMs?: number;
}

/** Return value of the {@link useRetry} hook. */
interface UseRetryResult {
  /**
   * Charges with automatic retry and exponential backoff. Re-throws after
   * all attempts are exhausted or the user cancels.
   */
  chargeWithRetry: (
    params: CreateOrderParams,
    config?: RetryConfig,
  ) => Promise<CreateOrderResponse>;
  /** Whether a charge or retry is currently in flight. */
  loading: boolean;
  /** The last error that occurred after exhausting retries, or `null`. */
  error: Error | null;
  /** The last successful charge response, or `null`. */
  data: CreateOrderResponse | null;
  /** Current attempt number (1-based). */
  attempt: number;
  /** Maximum number of configured attempts. */
  maxAttempts: number;
  /** Seconds remaining in the current backoff delay. */
  countdown: number;
  /** Whether the hook is currently waiting before the next retry. */
  isRetrying: boolean;
  /** Cancels an in-progress retry sequence. */
  cancel: () => void;
  /** Resets all state to initial values. */
  reset: () => void;
}

/**
 * Hook for charging with automatic retry and exponential backoff.
 *
 * Doubles the delay between each retry attempt, capped by `maxDelayMs`.
 * Supports cancellation and exposes a countdown for UI display.
 *
 * @example
 * ```tsx
 * const { chargeWithRetry, loading, attempt, countdown, isRetrying, cancel } = useRetry();
 *
 * const handlePay = async () => {
 *   try {
 *     await chargeWithRetry(orderParams, { maxAttempts: 5 });
 *   } catch {
 *     // all retries exhausted
 *   }
 * };
 * ```
 */
export function useRetry(): UseRetryResult {
  const { client } = useTelebirr();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [data, setData] = useState<CreateOrderResponse | null>(null);
  const [attempt, setAttempt] = useState(0);
  const [maxAttempts, setMaxAttempts] = useState(1);
  const [countdown, setCountdown] = useState(0);
  const [isRetrying, setIsRetrying] = useState(false);
  const cancelledRef = useRef(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  const cancel = useCallback(() => {
    cancelledRef.current = true;
    if (timerRef.current) clearTimeout(timerRef.current);
    setIsRetrying(false);
    setCountdown(0);
    setLoading(false);
  }, []);

  const chargeWithRetry = useCallback(
    async (
      params: CreateOrderParams,
      config?: RetryConfig,
    ): Promise<CreateOrderResponse> => {
      const max = config?.maxAttempts ?? 3;
      const base = config?.baseDelayMs ?? 1000;
      const maxDelay = config?.maxDelayMs ?? 30000;

      cancelledRef.current = false;
      setMaxAttempts(max);
      setAttempt(0);
      setError(null);
      setData(null);
      setLoading(true);

      for (let i = 1; i <= max; i++) {
        if (cancelledRef.current) break;

        setAttempt(i);

        try {
          const result = await client.payments.charge(params);
          setData(result);
          setLoading(false);
          return result;
        } catch (e) {
          if (i === max || cancelledRef.current) {
            const err = e instanceof Error ? e : new Error(String(e));
            setError(err);
            setLoading(false);
            throw err;
          }

          const delay = Math.min(base * Math.pow(2, i - 1), maxDelay);
          setIsRetrying(true);
          setCountdown(Math.ceil(delay / 1000));

          await new Promise<void>((resolve) => {
            let remaining = delay;
            timerRef.current = setInterval(() => {
              remaining -= 1000;
              if (cancelledRef.current || remaining <= 0) {
                if (timerRef.current) clearInterval(timerRef.current);
                setIsRetrying(false);
                setCountdown(0);
                resolve();
              } else {
                setCountdown(Math.ceil(remaining / 1000));
              }
            }, 1000) as unknown as ReturnType<typeof setTimeout>;
          });
        }
      }

      setLoading(false);
      throw new Error('Max retries exceeded');
    },
    [client],
  );

  const reset = useCallback(() => {
    setData(null);
    setError(null);
    setAttempt(0);
    setCountdown(0);
    setIsRetrying(false);
  }, []);

  return {
    chargeWithRetry,
    loading,
    error,
    data,
    attempt,
    maxAttempts,
    countdown,
    isRetrying,
    cancel,
    reset,
  };
}
