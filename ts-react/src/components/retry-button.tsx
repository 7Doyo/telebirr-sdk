'use client';
import { useTranslation } from 'react-i18next';
import type { CreateOrderParams, CreateOrderResponse } from '@telebirr-sdk/sdk-core';
import { useRetry } from '../hooks/use-retry.js';

/** Props accepted by the {@link RetryButton} component. */
interface RetryButtonProps {
  /** Order parameters forwarded to the charge-with-retry flow. */
  params: CreateOrderParams;
  /** Optional overrides for retry configuration (max attempts, delays). */
  retryConfig?: { maxAttempts?: number; baseDelayMs?: number; maxDelayMs?: number };
  /** Called with the API response after a successful charge. */
  onSuccess?: (response: CreateOrderResponse) => void;
  /** Called with the error after all retries are exhausted. */
  onError?: (error: Error) => void;
  /** Additional CSS class names applied to the button. */
  className?: string;
  /** Custom label text; falls back to the translated "Retry" string. */
  children?: React.ReactNode;
}

/**
 * Button that charges with automatic retry and exponential backoff.
 *
 * Shows a countdown UI during retry intervals and displays attempt
 * progress. Delegates to `useRetry()` for the retry logic.
 *
 * @example
 * ```tsx
 * <RetryButton
 *   params={orderParams}
 *   retryConfig={{ maxAttempts: 5, baseDelayMs: 2000 }}
 *   onSuccess={handleSuccess}
 * />
 * ```
 */
export function RetryButton({
  params,
  retryConfig,
  onSuccess,
  onError,
  className = '',
  children,
}: RetryButtonProps) {
  const {
    chargeWithRetry, loading, attempt, maxAttempts,
    countdown, isRetrying, cancel,
  } = useRetry();
  const { t } = useTranslation('telebirr');

  const handleRetry = async () => {
    try {
      const result = await chargeWithRetry(params, retryConfig);
      onSuccess?.(result);
    } catch (e) {
      onError?.(e instanceof Error ? e : new Error(String(e)));
    }
  };

  if (isRetrying) {
    return (
      <div className="flex items-center gap-sms" data-testid="retry-countdown">
        <span className="text-sm text-gray-600">
          {t('retryCountdown', { seconds: countdown })}
        </span>
        <span className="text-xs text-gray-400">
          ({attempt}/{maxAttempts})
        </span>
        <button
          type="button"
          onClick={cancel}
          className="text-sm text-red-600 hover:text-red-800"
          data-testid="retry-cancel"
        >
          {t('errorDismiss')}
        </button>
      </div>
    );
  }

  return (
    <button
      type="button"
      onClick={handleRetry}
      disabled={loading}
      className={className}
      data-testid="retry-button"
    >
      {loading ? t('processing') : (children ?? t('retry'))}
    </button>
  );
}
