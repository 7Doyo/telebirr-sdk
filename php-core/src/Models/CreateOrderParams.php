<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Parameters for creating a new payment order on the Telebirr gateway.
 *
 * Contains all required and optional fields needed to build a createOrder request.
 */
class CreateOrderParams
{
    /**
     * Create a new CreateOrderParams instance.
     *
     * @param string $orderId Unique merchant-generated order ID
     * @param string $title Short description of the order or goods
     * @param string $amount Payment amount in ETB (e.g. "100" or "99.99")
     * @param string|null $notifyUrl Optional webhook URL to receive payment notifications (overrides config default)
     * @param string|null $redirectUrl Optional URL to redirect the user after payment completion
     * @param string|null $callbackInfo Optional opaque callback data returned with webhook notifications
     * @param string|null $tradeType Optional trade type (e.g. "InApp", "Cross-App", "WebCheckout"). Defaults to "InApp"
     */
    public function __construct(
        public readonly string $orderId,
        public readonly string $title,
        public readonly string $amount,
        public readonly ?string $notifyUrl = null,
        public readonly ?string $redirectUrl = null,
        public readonly ?string $callbackInfo = null,
        public readonly ?string $tradeType = null,
    ) {}
}
