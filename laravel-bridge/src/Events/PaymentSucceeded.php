<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Event dispatched when a Telebirr payment completes successfully.
 *
 * Listeners can use this event to fulfill orders, update database
 * records, send confirmation emails, or trigger any post-payment
 * business logic. The event is serialisable for queue-based listeners.
 */
class PaymentSucceeded
{
    use Dispatchable, SerializesModels;

    /**
     * Create a new payment-succeeded event instance.
     *
     * @param string $orderId  The merchant order ID that was successfully paid.
     * @param array  $response The full Telebirr API response payload for the
     *                         completed payment, including status and amounts.
     */
    public function __construct(
        public readonly string $orderId,
        public readonly array $response,
    ) {}
}
