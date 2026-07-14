<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

/**
 * In-memory token cache with configurable time-to-live (TTL).
 *
 * Stores a fabric token in memory and automatically invalidates it
 * after the configured TTL expires.
 */
class TokenCache
{
    /** @var string|null The cached fabric token, or null if not cached */
    private ?string $token = null;

    /** @var int Unix timestamp (seconds) when the cached token expires */
    private int $expiresAt = 0;

    /** @var int Time-to-live in milliseconds */
    private readonly int $ttlMs;

    /**
     * Create a new TokenCache with the specified TTL.
     *
     * @param int $ttlMs Time-to-live in milliseconds (default: 3000000, i.e. 50 minutes)
     */
    public function __construct(int $ttlMs = 3000000)
    {
        $this->ttlMs = $ttlMs;
    }

    /**
     * Retrieve the cached token if it is still valid.
     *
     * Returns the token if cached and not expired; otherwise returns null
     * and clears the internal cache state.
     *
     * @return string|null The cached fabric token, or null if expired or not set
     */
    public function get(): ?string
    {
        if ($this->token === null || time() >= $this->expiresAt) {
            $this->token = null;
            return null;
        }
        return $this->token;
    }

    /**
     * Store a token in the cache with the configured TTL.
     *
     * @param string $token The fabric token to cache
     *
     * @return void
     */
    public function set(string $token): void
    {
        $this->token = $token;
        $this->expiresAt = time() + ($this->ttlMs / 1000);
    }

    /**
     * Clear the cached token and reset the expiry.
     *
     * @return void
     */
    public function clear(): void
    {
        $this->token = null;
        $this->expiresAt = 0;
    }
}
