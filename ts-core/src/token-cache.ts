/**
 * A cached fabric token and its expiry timestamp.
 */
export interface CachedToken {
  /** The fabric token string. */
  token: string;

  /** Absolute timestamp (ms) at which the token expires. */
  expiresAt: number;
}

/**
 * Configuration for the in-memory token cache.
 */
export interface TokenCacheConfig {
  /** Time-to-live in milliseconds. Defaults to 50 minutes (3,000,000 ms). */
  ttlMs?: number;
}

/**
 * In-memory token cache with configurable TTL.
 *
 * Stores a single fabric token and automatically invalidates it once
 * the TTL expires. Used internally by the SDK to avoid redundant
 * token requests within the same process.
 *
 * @example
 * ```ts
 * const cache = new TokenCache({ ttlMs: 5 * 60 * 1000 });
 * cache.set('my-fabric-token');
 * cache.get(); // 'my-fabric-token'
 * ```
 */
export class TokenCache {
  private cached: CachedToken | null = null;
  private readonly ttlMs: number;

  /**
   * @param config - Optional cache configuration.
   */
  constructor(config?: TokenCacheConfig) {
    this.ttlMs = config?.ttlMs ?? 50 * 60 * 1000;
  }

  /**
   * Returns the cached token if it exists and has not expired.
   *
   * @returns The cached token string, or `null` if unavailable or expired.
   */
  get(): string | null {
    if (!this.cached) return null;
    if (Date.now() >= this.cached.expiresAt) {
      this.cached = null;
      return null;
    }
    return this.cached.token;
  }

  /**
   * Stores a token in the cache with a TTL-relative expiry.
   *
   * @param token - The fabric token string to cache.
   */
  set(token: string): void {
    this.cached = {
      token,
      expiresAt: Date.now() + this.ttlMs,
    };
  }

  /**
   * Clears the cached token, forcing a fresh token request on next access.
   */
  clear(): void {
    this.cached = null;
  }
}
