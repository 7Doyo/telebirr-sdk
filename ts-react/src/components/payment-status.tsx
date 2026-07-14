import { useTranslation } from 'react-i18next';
import { PaymentStatus as PaymentStatusEnum } from '@telebirr/sdk-core';

/** Props accepted by the {@link PaymentStatus} badge component. */
interface PaymentStatusProps {
  /** The payment status value to render. */
  status: PaymentStatusEnum;
  /** Additional CSS class names applied to the badge. */
  className?: string;
}

const STATUS_STYLES: Record<string, string> = {
  SUCCESS: 'bg-green-100 text-green-800',
  FAIL: 'bg-red-100 text-red-800',
  TIMEOUT: 'bg-gray-100 text-gray-800',
  PENDING: 'bg-yellow-100 text-yellow-800',
  ACCEPTED: 'bg-blue-100 text-blue-800',
  REFUNDING: 'bg-orange-100 text-orange-800',
  REFUND_SUCCESS: 'bg-emerald-100 text-emerald-800',
  REFUND_FAILED: 'bg-red-100 text-red-800',
};

const STATUS_KEYS: Record<string, string> = {
  SUCCESS: 'statusSuccess',
  FAIL: 'statusFail',
  TIMEOUT: 'statusTimeout',
  PENDING: 'statusPending',
  ACCEPTED: 'statusAccepted',
  REFUNDING: 'statusRefunding',
  REFUND_SUCCESS: 'statusRefundSuccess',
  REFUND_FAILED: 'statusRefundFailed',
};

/**
 * Renders a color-coded badge for a given payment status.
 *
 * Translates the label via the `telebirr` i18n namespace and applies
 * Tailwind colour classes based on the status value.
 *
 * @example
 * ```tsx
 * <PaymentStatus status={PaymentStatus.SUCCESS} />
 * ```
 */
export function PaymentStatus({ status, className = '' }: PaymentStatusProps) {
  const { t } = useTranslation('telebirr');
  const style = STATUS_STYLES[status] ?? 'bg-gray-100 text-gray-800';
  const label = t(STATUS_KEYS[status] ?? status);

  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${style} ${className}`}
      data-testid="payment-status"
    >
      {label}
    </span>
  );
}
