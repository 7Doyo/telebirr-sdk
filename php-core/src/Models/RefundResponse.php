<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Response from a refund API call.
 *
 * Contains the gateway response code, refund order ID, refund status, and raw response data.
 */
class RefundResponse
{
    /**
     * Create a new RefundResponse instance.
     *
     * @param string $code Response code from the gateway ("0" indicates success)
     * @param string|null $message Optional human-readable message from the gateway
     * @param string|null $refundOrderId Gateway-assigned refund order identifier
     * @param string|null $refundStatus Refund processing status (e.g. "SUCCESS")
     * @param array<string, mixed> $rawResponse The complete raw response from the gateway
     */
    public function __construct(
        public readonly string $code,
        public readonly ?string $message,
        public readonly ?string $refundOrderId,
        public readonly ?string $refundStatus,
        public readonly array $rawResponse,
    ) {}

    /**
     * Check if the refund request was accepted successfully.
     *
     * @return bool True if the response code is "0"
     */
    public function isSuccessful(): bool
    {
        return $this->code === '0';
    }
}
