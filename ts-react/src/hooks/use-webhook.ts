'use client';
import { useState, useCallback } from 'react';
import { useTelebirr } from './use-telebirr.js';
import {
  verifyNotification,
  type NotificationPayload,
} from '@telebirr/sdk-core';

/** Return value of the {@link useWebhook} hook. */
interface UseWebhookResult {
  /**
   * Verifies a webhook notification payload against the configured private
   * key. Updates `lastResult` and `lastPayload` as a side-effect.
   */
  verify: (payload: NotificationPayload) => boolean;
  /** The verification result of the last call to `verify()`, or `null`. */
  lastResult: boolean | null;
  /** The payload that was last passed to `verify()`, or `null`. */
  lastPayload: NotificationPayload | null;
}

/**
 * Hook for verifying Telebirr webhook notifications.
 *
 * Uses the private key from the provider configuration to verify the
 * notification signature. Stores the last verified payload and result for
 * convenient access in the UI.
 *
 * @example
 * ```tsx
 * const { verify, lastResult, lastPayload } = useWebhook();
 *
 * useEffect(() => {
 *   const isValid = verify(incomingPayload);
 *   if (isValid) {
 *     // process the webhook
 *   }
 * }, [incomingPayload]);
 * ```
 */
export function useWebhook(): UseWebhookResult {
  const { config } = useTelebirr();
  const [lastResult, setLastResult] = useState<boolean | null>(null);
  const [lastPayload, setLastPayload] = useState<NotificationPayload | null>(
    null,
  );

  const verify = useCallback(
    (payload: NotificationPayload) => {
      const result = verifyNotification(payload, config.privateKeyPem);
      setLastResult(result);
      setLastPayload(payload);
      return result;
    },
    [config.privateKeyPem],
  );

  return { verify, lastResult, lastPayload };
}
