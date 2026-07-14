<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Response from a queryOrder API call.
 *
 * Contains the normalized payment status, gateway response code, and raw response data.
 */
class QueryOrderResponse
{
    /**
     * Create a new QueryOrderResponse instance.
     *
     * @param string $code Response code from the gateway ("0" indicates success)
     * @param string|null $message Optional human-readable message from the gateway
     * @param PaymentStatus $status Normalized payment status mapped from Telebirr's raw trade_status
     * @param array<string, mixed> $rawResponse The complete raw response from the gateway
     */
    public function __construct(
        public readonly string $code,
        public readonly ?string $message,
        public readonly PaymentStatus $status,
        public readonly array $rawResponse,
    ) {}

    /**
     * Check if the order payment was successful.
     *
     * @return bool True if the response code is "0" and status is SUCCESS
     */
    public function isSuccessful(): bool
    {
        return $this->code === '0' && $this->status === PaymentStatus::SUCCESS;
    }

    /**
     * Check if the query should be retried.
     *
     * @return bool True if the payment status is PENDING
     */
    public function shouldRetry(): bool
    {
        return $this->status->shouldRetry();
    }
}
