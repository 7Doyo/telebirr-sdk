'use client';
import { useTranslation } from 'react-i18next';

/** Props accepted by the {@link ErrorDisplay} component. */
interface ErrorDisplayProps {
  /** The error to display, or `null` to hide the component. */
  error: Error | null;
  /** Optional callback fired when the user clicks the dismiss button. */
  onDismiss?: () => void;
  /** Additional CSS class names applied to the alert container. */
  className?: string;
}

const ERROR_KEY_MAP: Record<string, string> = {
  NetworkError: 'errorNetwork',
  TimeoutError: 'errorTimeout',
  EnvironmentError: 'errorAuth',
  ValidationError: 'errorValidation',
};

/**
 * Displays a localized error alert with an optional dismiss button.
 *
 * Maps error `name` properties to i18n keys for human-readable messages.
 * Returns `null` when `error` is `null`.
 *
 * @example
 * ```tsx
 * <ErrorDisplay error={error} onDismiss={() => setError(null)} />
 * ```
 */
export function ErrorDisplay({ error, onDismiss, className = '' }: ErrorDisplayProps) {
  const { t } = useTranslation('telebirr');

  if (!error) return null;

  const key = ERROR_KEY_MAP[error.name] ?? 'errorGeneric';
  const message = t(key);

  return (
    <div
      role="alert"
      className={`flex items-start gap-sms rounded-lg border border-red-200 bg-red-50 p-sm text-red-800 ${className}`}
      data-testid="error-display"
    >
      <span className="flex-1 text-sm">{message}</span>
      {onDismiss && (
        <button
          type="button"
          onClick={onDismiss}
          className="ms-auto flex-shrink-0 text-red-600 hover:text-red-800"
          aria-label={t('errorDismiss')}
          data-testid="error-dismiss"
        >
          ✕
        </button>
      )}
    </div>
  );
}
