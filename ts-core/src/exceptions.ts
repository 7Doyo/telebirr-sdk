/**
 * Base error class for all Telebirr SDK errors.
 *
 * All SDK-specific exceptions extend this class, making it easy to
 * catch any SDK error with a single `instanceof` check.
 *
 * @example
 * ```ts
 * try {
 *   await telebirr.payments.charge(params);
 * } catch (err) {
 *   if (err instanceof TelebirrError) {
 *     console.error(err.code, err.message);
 *   }
 * }
 * ```
 */
export class TelebirrError extends Error {
  /** Machine-readable error code (e.g. `'VALIDATION_ERROR'`, `'NETWORK_ERROR'`). */
  code: string;

  /**
   * @param message - Human-readable error description.
   * @param code - Machine-readable error code. Defaults to `'UNKNOWN'`.
   */
  constructor(message: string, code: string = 'UNKNOWN') {
    super(message);
    this.name = 'TelebirrError';
    this.code = code;
  }
}

/**
 * Thrown when input validation fails (e.g. missing required fields, invalid amounts).
 *
 * @example
 * ```ts
 * // Throws ValidationError: "Amount must be a positive number"
 * await telebirr.payments.charge({ amount: '-5', title: 'Test' });
 * ```
 */
export class ValidationError extends TelebirrError {
  /** @param message - Description of the validation failure. */
  constructor(message: string) {
    super(message, 'VALIDATION_ERROR');
    this.name = 'ValidationError';
  }
}

/**
 * Thrown when request signing or signature verification fails.
 *
 * Typically caused by an invalid or mismatched private key.
 */
export class SigningError extends TelebirrError {
  /** @param message - Description of the signing failure. */
  constructor(message: string) {
    super(message, 'SIGNING_ERROR');
    this.name = 'SigningError';
  }
}

/**
 * Thrown when an HTTP request to the Telebirr API fails,
 * including network-level errors and non-2xx responses.
 *
 * @example
 * ```ts
 * try {
 *   await telebirr.payments.query({ merchOrderId: '123' });
 * } catch (err) {
 *   if (err instanceof NetworkError) {
 *     console.error('HTTP failure:', err.message);
 *   }
 * }
 * ```
 */
export class NetworkError extends TelebirrError {
  /** @param message - Description of the network failure. */
  constructor(message: string) {
    super(message, 'NETWORK_ERROR');
    this.name = 'NetworkError';
  }
}

/**
 * Thrown when the SDK detects a mismatch between the key and environment,
 * such as using a test key with the production endpoint or vice versa.
 *
 * @example
 * ```ts
 * // Throws EnvironmentError: "Test key cannot be used with PRODUCTION environment"
 * new Telebirr({ ...config, environment: 'PRODUCTION', fabricAppId: 'sk_test_xxx' });
 * ```
 */
export class EnvironmentError extends TelebirrError {
  /** @param message - Description of the environment mismatch. */
  constructor(message: string) {
    super(message, 'ENVIRONMENT_ERROR');
    this.name = 'EnvironmentError';
  }
}
