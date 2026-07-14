/**
 * Parameters for refunding a Telebirr order.
 *
 * @example
 * ```ts
 * const params: RefundParams = {
 *   merchOrderId: 'ORD1719000000ABC123',
 *   refundRequestNo: 'RFD1719000001DEF456',
 *   refundAmount: '100',
 *   refundReason: 'Customer requested refund',
 * };
 * ```
 */
export interface RefundParams {
  /** The original merchant order ID to refund. */
  merchOrderId: string;

  /** Unique refund request identifier (must be unique per refund attempt). */
  refundRequestNo: string;

  /** Amount to refund in ETB. Must be a positive number as a string. */
  refundAmount: string;

  /** Optional human-readable reason for the refund. */
  refundReason?: string;
}

/**
 * Response from a refund API call.
 */
export interface RefundResponse {
  /** Telebirr response code (`'0'` indicates success). */
  code: string;

  /** Human-readable message from Telebirr. */
  message?: string;

  /** Telebirr-assigned refund order ID. */
  refundOrderId?: string;

  /** Refund status string (e.g. `'SUCCESS'`). */
  refundStatus?: string;

  /** Raw JSON response from the Telebirr API for debugging or advanced use. */
  rawResponse: Record<string, unknown>;
}
