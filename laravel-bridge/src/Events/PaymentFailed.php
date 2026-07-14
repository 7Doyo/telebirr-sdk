<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Event dispatched when a Telebirr payment attempt fails.
 *
 * Listeners can use this event to log failures, notify customers,
 * or revert any provisional state changes made during checkout.
 * The event is serialisable for queue-based listeners.
 */
class PaymentFailed
{
    use Dispatchable, SerializesModels;

    /**
     * Create a new payment-failed event instance.
     *
     * @param string $orderId The merchant order ID whose payment failed.
     * @param string $error   A human-readable description of the failure reason
     *                        returned by the Telebirr API.
     */
    public function __construct(
        public readonly string $orderId,
        public readonly string $error,
    ) {}
}
