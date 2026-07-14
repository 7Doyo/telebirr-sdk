import { createHash } from 'node:crypto';

/**
 * Generates a deterministic idempotency key from an order ID.
 *
 * Produces a SHA-256 hash of the order ID, returned as an uppercase
 * hexadecimal string. This ensures that identical order IDs always
 * produce the same key, preventing duplicate order creation on retries.
 *
 * @param orderId - The unique merchant order identifier.
 * @returns Uppercase hex-encoded SHA-256 hash of the order ID.
 *
 * @example
 * ```ts
 * generateIdempotencyKey('ORD1719000000ABC');
 * // "3A5F8C...6B2E1D" (64-char uppercase hex)
 * ```
 */
export function generateIdempotencyKey(orderId: string): string {
  return createHash('sha256').update(orderId).digest('hex').toUpperCase();
}
