'use client';
import { useTranslation } from 'react-i18next';
import { usePayment } from '../hooks/use-payment.js';
import type {
  CreateOrderParams,
  CreateOrderResponse,
} from '@telebirr/sdk-core';

/** Props accepted by the {@link PaymentButton} component. */
interface PaymentButtonProps {
  /** Order parameters forwarded to `Telebirr.payments.charge()`. */
  params: CreateOrderParams;
  /** Called with the API response after a successful charge. */
  onSuccess?: (response: CreateOrderResponse) => void;
  /** Called with the error if the charge fails. */
  onError?: (error: Error) => void;
  /** When `true`, the button is disabled (unless a charge is in flight). */
  disabled?: boolean;
  /** Additional CSS class names applied to the `<button>` element. */
  className?: string;
  /** Custom label text; falls back to the translated "Pay Now" string. */
  children?: React.ReactNode;
}

/**
 * Ready-made payment button that triggers a Telebirr charge on click.
 *
 * Disables itself while a request is in flight and shows a translated
 * "Processing…" label. Requires a parent {@link TelebirrProvider}.
 *
 * @example
 * ```tsx
 * <PaymentButton
 *   params={orderParams}
 *   onSuccess={(res) => console.log('paid', res)}
 *   onError={(err) => console.error(err)}
 * />
 * ```
 */
export function PaymentButton({
  params,
  onSuccess,
  onError,
  disabled = false,
  className = '',
  children,
}: PaymentButtonProps) {
  const { charge, loading } = usePayment();
  const { t } = useTranslation('telebirr');

  const handleClick = async () => {
    try {
      const result = await charge(params);
      onSuccess?.(result);
    } catch (e) {
      onError?.(e instanceof Error ? e : new Error(String(e)));
    }
  };

  return (
    <button
      onClick={handleClick}
      disabled={disabled || loading}
      className={className}
      data-testid="payment-button"
    >
      {loading ? t('processing') : (children ?? t('payNow'))}
    </button>
  );
}
