import { createSign, randomBytes } from 'node:crypto';
import { SigningError } from './exceptions.js';

/**
 * Fields excluded from the signing string, per the Telebirr specification.
 */
const EXCLUDED_FIELDS = [
  'sign',
  'sign_type',
  'header',
  'refund_info',
  'openType',
  'raw_request',
  'biz_content',
];

/**
 * Signs a Telebirr API request body using SHA256withRSA-PSS.
 *
 * Builds a canonical signing string from the request fields, then signs it
 * with the provided PKCS8 PEM private key using a 32-byte salt.
 *
 * @param request - The full request object (including `biz_content`).
 * @param privateKeyPem - PKCS8 PEM-encoded RSA private key.
 * @returns Base64-encoded signature string to set as the `sign` field.
 *
 * @example
 * ```ts
 * const sign = signRequest(
 *   { nonce_str: 'ABC', method: 'payment.preorder', biz_content: { appid: '123' } },
 *   privateKeyPem,
 * );
 * ```
 */
export function signRequest(
  request: Record<string, unknown>,
  privateKeyPem: string,
): string {
  const signString = buildSignString(request);
  return sha256PssSign(signString, privateKeyPem);
}

/**
 * Builds the canonical key=value signing string for a Telebirr request.
 *
 * Flattens top-level fields and `biz_content` inner fields, excludes
 * non-signable fields, sorts keys lexicographically, and joins as
 * `key=value&key=value`.
 *
 * @param request - The full request object.
 * @returns Sorted `key=value` pair string.
 *
 * @example
 * ```ts
 * buildSignString({ b: '2', a: '1', biz_content: { z: '9', m: '5' } });
 * // "a=1&b=2&m=5&z=9"
 * ```
 */
export function buildSignString(request: Record<string, unknown>): string {
  const fieldMap: Record<string, string> = {};
  const fields: string[] = [];

  for (const key of Object.keys(request)) {
    if (EXCLUDED_FIELDS.includes(key)) continue;
    fields.push(key);
    fieldMap[key] = String(request[key]);
  }

  const bizContent = request.biz_content as
    | Record<string, unknown>
    | undefined;
  if (bizContent && typeof bizContent === 'object') {
    for (const key of Object.keys(bizContent)) {
      if (EXCLUDED_FIELDS.includes(key)) continue;
      fields.push(key);
      fieldMap[key] = String(bizContent[key]);
    }
  }

  fields.sort();
  return fields.map((k) => `${k}=${fieldMap[k]}`).join('&');
}

/**
 * Signs a UTF-8 string with SHA256withRSA-PSS (32-byte salt).
 *
 * @param data - The plaintext string to sign.
 * @param privateKeyPem - PKCS8 PEM-encoded RSA private key.
 * @returns Base64-encoded signature.
 * @throws {SigningError} If the signing operation fails.
 *
 * @example
 * ```ts
 * const sig = sha256PssSign('appid=123&amount=100', privateKeyPem);
 * ```
 */
export function sha256PssSign(data: string, privateKeyPem: string): string {
  try {
    const sign = createSign('SHA256');
    sign.update(data);
    sign.end();
    const signature = sign.sign(
      {
        key: privateKeyPem,
        padding: 1, // RSA_PKCS1_PSS_PADDING
        saltLength: 32,
      },
      'base64',
    );
    return signature;
  } catch (err) {
    throw new SigningError(
      `Signing failed: ${err instanceof Error ? err.message : String(err)}`,
    );
  }
}

/**
 * Generates a random 32-character uppercase hexadecimal nonce string.
 *
 * Uses `crypto.randomBytes(16)` to produce 16 random bytes, converts
 * them to hex, and takes the first 32 characters.
 *
 * @returns A 32-character uppercase alphanumeric string.
 *
 * @example
 * ```ts
 * generateNonceStr(); // "A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6"
 * ```
 */
export function generateNonceStr(): string {
  return randomBytes(16)
    .toString('hex')
    .toUpperCase()
    .slice(0, 32);
}
