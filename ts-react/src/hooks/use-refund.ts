'use client';
import { useState, useCallback } from 'react';
import { useTelebirr } from './use-telebirr.js';
import type { RefundParams, RefundResponse } from '@telebirr-sdk/sdk-core';

/** Return value of the {@link useRefund} hook. */
interface UseRefundResult {
  /** Executes a refund request. Sets `loading` and `data`/`error` state. */
  refund: (params: RefundParams) => Promise<RefundResponse>;
  /** Whether a refund request is currently in flight. */
  loading: boolean;
  /** The last error that occurred, or `null`. */
  error: Error | null;
  /** The last successful refund response, or `null`. */
  data: RefundResponse | null;
  /** Resets `data` and `error` to their initial state. */
  reset: () => void;
}

/**
 * Hook for issuing Telebirr refunds and tracking their state.
 *
 * Mirrors the `usePayment` hook API but calls `client.payments.refund()`
 * instead of `charge()`.
 *
 * @example
 * ```tsx
 * const { refund, loading, error } = useRefund();
 *
 * const handleRefund = async () => {
 *   await refund({
 *     merchOrderId: '123',
 *     refundRequestNo: 'R001',
 *     refundAmount: '50',
 *   });
 * };
 * ```
 */
export function useRefund(): UseRefundResult {
  const { client } = useTelebirr();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [data, setData] = useState<RefundResponse | null>(null);

  const refund = useCallback(
    async (params: RefundParams) => {
      setLoading(true);
      setError(null);
      try {
        const result = await client.payments.refund(params);
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

  return { refund, loading, error, data, reset };
}
