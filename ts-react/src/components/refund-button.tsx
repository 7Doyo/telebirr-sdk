'use client';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useRefund } from '../hooks/use-refund.js';

/** Props accepted by the {@link RefundButton} component. */
interface RefundButtonProps {
  /** Parameters for the refund request. */
  refundParams: { merchOrderId: string; refundRequestNo: string; refundAmount: string; refundReason?: string };
  /** Called after the refund completes successfully. */
  onSuccess?: () => void;
  /** Called with the error if the refund fails. */
  onError?: (error: Error) => void;
  /** Additional CSS class names applied to the button. */
  className?: string;
  /** When `true`, the initial button is disabled. */
  disabled?: boolean;
  /** Custom label text; falls back to the translated "Refund" string. */
  children?: React.ReactNode;
}

/**
 * Two-step refund button with a confirmation prompt.
 *
 * First click shows a confirmation UI with "Yes" / "Cancel" actions.
 * The actual refund is only dispatched after the user confirms.
 *
 * @example
 * ```tsx
 * <RefundButton
 *   refundParams={{ merchOrderId: '123', refundRequestNo: 'R001', refundAmount: '50' }}
 *   onSuccess={() => alert('Refunded')}
 * />
 * ```
 */
export function RefundButton({
  refundParams,
  onSuccess,
  onError,
  className = '',
  disabled = false,
  children,
}: RefundButtonProps) {
  const { refund, loading, error } = useRefund();
  const { t } = useTranslation('telebirr');
  const [showConfirm, setShowConfirm] = useState(false);

  const handleRefund = async () => {
    try {
      await refund(refundParams);
      setShowConfirm(false);
      onSuccess?.();
    } catch (e) {
      onError?.(e instanceof Error ? e : new Error(String(e)));
    }
  };

  if (showConfirm) {
    return (
      <div className="flex items-center gap-sms rounded-lg border border-yellow-200 bg-yellow-50 p-sm" data-testid="refund-confirm">
        <span className="flex-1 text-sm text-yellow-800">{t('refundConfirm')}</span>
        <button
          type="button"
          onClick={handleRefund}
          disabled={loading}
          className="rounded bg-red-600 px-3 py-1 text-sm text-white hover:bg-red-700 disabled:opacity-50"
          data-testid="refund-confirm-yes"
        >
          {loading ? t('refundProcessing') : t('refund')}
        </button>
        <button
          type="button"
          onClick={() => setShowConfirm(false)}
          className="rounded bg-gray-200 px-3 py-1 text-sm text-gray-800 hover:bg-gray-300"
          data-testid="refund-confirm-no"
        >
          {t('errorDismiss')}
        </button>
      </div>
    );
  }

  return (
    <button
      type="button"
      onClick={() => setShowConfirm(true)}
      disabled={disabled || loading}
      className={className}
      data-testid="refund-button"
    >
      {children ?? t('refund')}
    </button>
  );
}
