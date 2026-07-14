<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Response from a createOrder API call.
 *
 * Contains the gateway response code, prepay ID, receive code, and raw response data.
 */
class CreateOrderResponse
{
    /**
     * Create a new CreateOrderResponse instance.
     *
     * @param string $code Response code from the gateway ("0" indicates success)
     * @param string|null $message Optional human-readable message from the gateway
     * @param string $prepayId Prepay ID used for payment collection
     * @param string $receiveCode Machine-readable receive code for QR codes or deep links
     * @param array<string, mixed> $rawResponse The complete raw response from the gateway
     */
    public function __construct(
        public readonly string $code,
        public readonly ?string $message,
        public readonly string $prepayId,
        public readonly string $receiveCode,
        public readonly array $rawResponse,
    ) {}

    /**
     * Check if the order was created successfully.
     *
     * @return bool True if the response code is "0" (success)
     */
    public function isSuccessful(): bool
    {
        return $this->code === '0';
    }
}
