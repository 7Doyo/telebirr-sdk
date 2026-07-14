'use client';
import { useState, useCallback } from 'react';
import { useTelebirr } from './use-telebirr.js';
import type {
  CreateOrderParams,
  CreateOrderResponse,
} from '@telebirr-sdk/sdk-core';

/** Return value of the {@link usePayment} hook. */
interface UsePaymentResult {
  /** Executes a payment charge. Sets `loading` and `data`/`error` state. */
  charge: (params: CreateOrderParams) => Promise<CreateOrderResponse>;
  /** Whether a charge request is currently in flight. */
  loading: boolean;
  /** The last error that occurred, or `null`. */
  error: Error | null;
  /** The last successful charge response, or `null`. */
  data: CreateOrderResponse | null;
  /** Resets `data` and `error` to their initial state. */
  reset: () => void;
}

/**
 * Hook for initiating Telebirr payments and tracking their state.
 *
 * Returns a memoized `charge` function and reactive `loading`, `error`, and
 * `data` values. The `reset` function clears previous results so the UI can
 * return to its initial state.
 *
 * @example
 * ```tsx
 * const { charge, loading, error, data } = usePayment();
 *
 * const handlePay = async () => {
 *   try {
 *     const result = await charge(orderParams);
 *     console.log('Payment created:', result);
 *   } catch (err) {
 *     // error already set in state
 *   }
 * };
 * ```
 */
export function usePayment(): UsePaymentResult {
  const { client } = useTelebirr();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [data, setData] = useState<CreateOrderResponse | null>(null);

  const charge = useCallback(
    async (params: CreateOrderParams) => {
      setLoading(true);
      setError(null);
      try {
        const result = await client.payments.charge(params);
        setData(result);
        return result;
      } catch (e) {
        const err = e instanceof Error ? e : new Error(String(e));
        setError(err);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [client],
  );

  const reset = useCallback(() => {
    setData(null);
    setError(null);
  }, []);

  return { charge, loading, error, data, reset };
}
