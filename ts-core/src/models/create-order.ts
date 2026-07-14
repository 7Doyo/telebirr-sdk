/**
 * Supported payment flow types.
 *
 * - `InApp` – Native in-app mobile payment.
 * - `Cross-App` – Cross-application payment.
 * - `WebCheckout` – Browser-based checkout.
 * - `PWA` – Progressive Web App payment.
 * - `QrCode` – QR code scan payment.
 * - `QuickPay` – Quick pay flow.
 * - `BankTrade` – Bank trade payment.
 */
export type TradeType =
  | 'InApp'
  | 'Cross-App'
  | 'WebCheckout'
  | 'PWA'
  | 'QrCode'
  | 'QuickPay'
  | 'BankTrade';

/**
 * Parameters for creating a new Telebirr payment order.
 *
 * @example
 * ```ts
 * const params: CreateOrderParams = {
 *   amount: '100',
 *   title: 'Coffee Shop',
 *   orderId: 'ORD1719000000ABC123',
 * };
 * ```
 */
export interface CreateOrderParams {
  /** Payment amount in ETB (Ethiopian Birr). Must be a positive number as a string. */
  amount: string;

  /** Human-readable order title shown to the payer. */
  title: string;

  /**
   * Optional unique order identifier.
   * If omitted, the SDK generates one automatically.
   */
  orderId?: string;

  /** Optional redirect URL after payment completes (used in web flows). */
  redirectUrl?: string;

  /** Optional callback info string passed through to webhook notifications. */
  callbackInfo?: string;

  /**
   * Payment flow type.
   * Defaults to `'InApp'` if omitted.
   */
  tradeType?: TradeType;
}

/**
 * Response from a successful create-order API call.
 */
export interface CreateOrderResponse {
  /** Telebirr response code (`'0'` indicates success). */
  code: string;

  /** Human-readable message from Telebirr. */
  message?: string;

  /** Prepay ID used to generate the receive code and track the order. */
  prepayId: string;

  /** Receive code string for the mobile SDK payment flow. */
  receiveCode: string;

  /** Raw JSON response from the Telebirr API for debugging or advanced use. */
  rawResponse: Record<string, unknown>;
}
