'use client';
import { usePayment } from '../hooks/use-payment.js';
import type {
  CreateOrderParams,
  CreateOrderResponse,
} from '@telebirr-sdk/sdk-core';

/** Props accepted by the {@link CheckoutElement} render-prop component. */
interface CheckoutElementProps {
  /** Order parameters forwarded to `Telebirr.payments.charge()`. */
  params: CreateOrderParams;
  /** Called with the API response after a successful charge. */
  onSuccess?: (response: CreateOrderResponse) => void;
  /** Called with the error if the charge fails. */
  onError?: (error: Error) => void;
  /**
   * Render-prop receiving `{ charge, loading, error }` so consumers can build
   * their own checkout UI.
   */
  children: (args: {
    /** Triggers the Telebirr payment flow for the given params. */
    charge: () => Promise<void>;
    /** Whether the payment request is in flight. */
    loading: boolean;
    /** The last error that occurred, or `null`. */
    error: Error | null;
  }) => React.ReactNode;
}

/**
 * Render-prop component for creating a Telebirr checkout.
 *
 * Delegates to `usePayment()` and wraps the `charge` call with the params and
 * callbacks provided as props. Does **not** render any DOM elements itself,
 * leaving full visual control to the consumer via the `children` render-prop.
 *
 * @example
 * ```tsx
 * <CheckoutElement params={orderParams} onSuccess={handleSuccess}>
 *   {({ charge, loading }) => (
 *     <button onClick={charge} disabled={loading}>
 *       {loading ? 'Processing…' : 'Pay with Telebirr'}
 *     </button>
 *   )}
 * </CheckoutElement>
 * ```
 */
export function CheckoutElement({
  params,
  onSuccess,
  onError,
  children,
}: CheckoutElementProps) {
  const { charge, loading, error } = usePayment();

  const handleCharge = async () => {
    try {
      const result = await charge(params);
      onSuccess?.(result);
    } catch (e) {
      onError?.(e instanceof Error ? e : new Error(String(e)));
    }
  };

  return <>{children({ charge: handleCharge, loading, error })}</>;
}
