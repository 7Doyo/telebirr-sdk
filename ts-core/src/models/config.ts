/** Target environment for the Telebirr API. */
export type Environment = 'SANDBOX' | 'PRODUCTION';

/**
 * Configuration for the Telebirr SDK client.
 *
 * @example
 * ```ts
 * const config: TelebirrConfig = {
 *   environment: 'SANDBOX',
 *   fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
 *   merchantAppId: '12345',
 *   merchantCode: 'TEST_MERCHANT',
 *   appSecret: 'sk_test_xxx',
 *   privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...',
 *   shortCode: '220311',
 *   timeout: '120m',
 *   notifyUrl: 'https://example.com/webhook',
 * };
 * ```
 */
export interface TelebirrConfig {
  /** Target environment: `SANDBOX` or `PRODUCTION`. */
  environment: Environment;

  /** UUID-format application ID from the Telebirr developer portal. */
  fabricAppId: string;

  /** Numeric merchant application ID. */
  merchantAppId: string;

  /** Merchant code assigned by Telebirr. */
  merchantCode: string;

  /** Application secret (API key) used to obtain a fabric token. */
  appSecret: string;

  /** PKCS8 PEM-encoded private key used to sign requests. */
  privateKeyPem: string;

  /** Short code identifying the payee (e.g. `"220311"`). */
  shortCode: string;

  /** Payment timeout expression (e.g. `"120m"` for 120 minutes). */
  timeout: string;

  /** URL that receives asynchronous webhook notifications from Telebirr. */
  notifyUrl: string;

  /**
   * Override the default base URL for the environment.
   * If omitted, the SDK uses the standard Telebirr endpoint for the selected environment.
   */
  baseUrl?: string;
}
