<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

/**
 * Idempotency key generation for duplicate request prevention.
 *
 * Produces deterministic SHA-256-based keys from order identifiers to ensure
 * that identical requests generate the same idempotency key.
 */
class Idempotency
{
    /**
     * Generate a deterministic idempotency key from an order ID.
     *
     * Produces an uppercase hexadecimal SHA-256 hash of the given order ID.
     * The same orderId always produces the same key, preventing duplicate
     * order creation on network retries.
     *
     * @param string $orderId The unique merchant order ID to generate a key for
     *
     * @return string Uppercase hexadecimal SHA-256 hash of the order ID (64 characters)
     */
    public static function generateKey(string $orderId): string
    {
        return strtoupper(hash('sha256', $orderId));
    }
}
