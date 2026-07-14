'use client';
import { useTranslation } from 'react-i18next';
import { useTelebirr } from '../hooks/use-telebirr.js';

/** Props accepted by the {@link TestModeBadge} component. */
interface TestModeBadgeProps {
  /** Additional CSS class names applied to the badge. */
  className?: string;
}

/**
 * Conditionally renders a yellow "Test Mode" badge when the SDK environment
 * is set to `SANDBOX`. Returns `null` in production mode.
 *
 * @example
 * ```tsx
 * <TestModeBadge className="mb-2" />
 * ```
 */
export function TestModeBadge({ className = '' }: TestModeBadgeProps) {
  const { config } = useTelebirr();
  const { t } = useTranslation('telebirr');

  if (config.environment !== 'SANDBOX') return null;

  return (
    <span
      className={`inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800 ${className}`}
      data-testid="test-mode-badge"
    >
      {t('testMode')}
    </span>
  );
}
