import { createVerify } from 'node:crypto';

/**
 * Trade status values returned in webhook notifications.
 *
 * These use **camelCase** (e.g. `Completed`) unlike the UPPER_CASE values
 * returned by the query-order endpoint.
 */
export enum NotificationTradeStatus {
  /** Payment is in progress. */
  PAYING = 'Paying',
  /** Payment expired without completion. */
  EXPIRED = 'Expired',
  /** Awaiting payment from the user. */
  PENDING = 'Pending',
  /** Payment completed successfully. */
  COMPLETED = 'Completed',
  /** Payment failed. */
  FAILURE = 'Failure',
}

/**
 * Payload received from a Telebirr webhook notification.
 *
 * Telebirr sends additional properties beyond the well-known fields,
 * so the interface includes an index signature.
 */
export interface NotificationPayload {
  /** Allows arbitrary extra properties from Telebirr. */
  [key: string]: unknown;

  /** The notification callback URL. */
  notify_url?: string;

  /** Merchant application ID. */
  appid?: string;

  /** Timestamp of the notification (ISO 8601). */
  notify_time?: string;

  /** Merchant code. */
  merch_code?: string;

  /** Merchant order ID that was created via createOrder. */
  merch_order_id?: string;

  /** Telebirr-assigned payment order ID. */
  payment_order_id?: string;

  /** Payment amount in ETB. */
  total_amount?: string;

  /** Transaction currency (e.g. `"ETB"`). */
  trans_currency?: string;

  /** Trade status string (see {@link NotificationTradeStatus}). */
  trade_status?: string;

  /** Transaction end timestamp. */
  trans_end_time?: string;

  /** Callback info originally passed during order creation. */
  callback_info?: string;

  /** Base64-encoded signature for verification. */
  sign?: string;

  /** Signing algorithm identifier (e.g. `"SHA256WithRSA"`). */
  sign_type?: string;
}

/**
 * Verifies the authenticity of a Telebirr webhook notification by checking
 * its RSA signature.
 *
 * @param payload - The full notification payload (including `sign`).
 * @param publicKeyPem - PEM-encoded public key matching the merchant's private key.
 * @returns `true` if the signature is valid, `false` otherwise.
 *
 * @example
 * ```ts
 * app.post('/webhook', (req, res) => {
 *   const valid = verifyNotification(req.body, publicKeyPem);
 *   if (!valid) return res.status(401).send('Invalid signature');
 *   // process notification...
 * });
 * ```
 */
export function verifyNotification(
  payload: NotificationPayload,
  publicKeyPem: string,
): boolean {
  const sign = payload.sign;
  if (!sign || typeof sign !== 'string') return false;

  const signString = buildNotificationSignString(payload);
  const verify = createVerify('SHA256');
  verify.update(signString);
  verify.end();
  return verify.verify(publicKeyPem, sign, 'base64');
}

/**
 * Builds the canonical signing string from a webhook notification payload.
 *
 * Excludes `sign` and `sign_type`, skips `undefined`/`null` values,
 * sorts keys lexicographically, and joins as `key=value` pairs.
 *
 * @param payload - The notification payload (without the signature).
 * @returns Sorted `key=value` pair string.
 */
function buildNotificationSignString(
  payload: NotificationPayload,
): string {
  const exclude = new Set(['sign', 'sign_type']);
  const fields: string[] = [];
  const fieldMap: Record<string, string> = {};

  for (const [key, value] of Object.entries(payload)) {
    if (exclude.has(key)) continue;
    if (value === undefined || value === null) continue;
    fields.push(key);
    fieldMap[key] = String(value);
  }

  fields.sort();
  return fields.map((k) => `${k}=${fieldMap[k]}`).join('&');
}
