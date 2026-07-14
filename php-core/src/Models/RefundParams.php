<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Parameters for requesting a refund on an existing order.
 *
 * Contains the order ID, unique refund request number, refund amount, and optional reason.
 */
class RefundParams
{
    /**
     * Create a new RefundParams instance.
     *
     * @param string $merchOrderId The original merchant order ID to refund
     * @param string $refundRequestNo Unique identifier for this refund request (must be unique per order)
     * @param string $refundAmount Amount to refund in ETB (e.g. "100" or "99.99")
     * @param string|null $refundReason Optional human-readable reason for the refund
     */
    public function __construct(
        public readonly string $merchOrderId,
        public readonly string $refundRequestNo,
        public readonly string $refundAmount,
        public readonly ?string $refundReason = null,
    ) {}
}
