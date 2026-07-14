/**
 * Unified payment status values returned by the SDK.
 *
 * These normalise both query-order (`UPPER_CASE`) and webhook (`camelCase`)
 * trade statuses into a single set of values.
 */
export enum PaymentStatus {
  /** Payment completed successfully. */
  SUCCESS = 'SUCCESS',
  /** Payment failed. */
  FAIL = 'FAIL',
  /** Order expired or was closed without payment. */
  TIMEOUT = 'TIMEOUT',
  /** Awaiting payment or payment in progress. */
  PENDING = 'PENDING',
  /** Order accepted, awaiting processing. */
  ACCEPTED = 'ACCEPTED',
  /** Refund is in progress. */
  REFUNDING = 'REFUNDING',
  /** Refund completed successfully. */
  REFUND_SUCCESS = 'REFUND_SUCCESS',
  /** Refund failed. */
  REFUND_FAILED = 'REFUND_FAILED',
}

/** Maps raw Telebirr query-order `trade_status` values to the unified {@link PaymentStatus}. */
const TELEBIRR_STATUS_MAP: Record<string, PaymentStatus> = {
  PAY_SUCCESS: PaymentStatus.SUCCESS,
  PAY_FAILED: PaymentStatus.FAIL,
  ORDER_CLOSED: PaymentStatus.TIMEOUT,
  WAIT_PAY: PaymentStatus.PENDING,
  PAYING: PaymentStatus.PENDING,
  ACCEPTED: PaymentStatus.ACCEPTED,
  REFUNDING: PaymentStatus.REFUNDING,
  REFUND_SUCCESS: PaymentStatus.REFUND_SUCCESS,
  REFUND_FAILED: PaymentStatus.REFUND_FAILED,
};

/**
 * Maps a raw Telebirr `trade_status` string to the unified {@link PaymentStatus} enum.
 *
 * Unrecognised statuses default to `PENDING`.
 *
 * @param rawStatus - The raw `trade_status` value from the Telebirr API.
 * @returns The corresponding {@link PaymentStatus}.
 *
 * @example
 * ```ts
 * mapTelebirrStatus('PAY_SUCCESS'); // PaymentStatus.SUCCESS
 * mapTelebirrStatus('UNKNOWN');     // PaymentStatus.PENDING
 * ```
 */
export function mapTelebirrStatus(rawStatus: string): PaymentStatus {
  return TELEBIRR_STATUS_MAP[rawStatus] ?? PaymentStatus.PENDING;
}

/**
 * Parameters for querying an existing Telebirr order.
 */
export interface QueryOrderParams {
  /** The merchant order ID originally passed when creating the order. */
  merchOrderId: string;
}

/**
 * Response from a query-order API call.
 */
export interface QueryOrderResponse {
  /** Telebirr response code (`'0'` indicates success). */
  code: string;

  /** Normalised payment status. */
  status: PaymentStatus;

  /** Raw JSON response from the Telebirr API for debugging or advanced use. */
  rawResponse: Record<string, unknown>;
}
