<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

/**
 * Event dispatched after a Telebirr webhook notification has been verified and accepted.
 *
 * The raw payload is passed through unmodified so that listeners can
 * inspect the payment status, order details, or any other fields
 * present in the notification. This event is serialisable for
 * queue-based listeners.
 */
class WebhookReceived
{
    use Dispatchable, SerializesModels;

    /**
     * Create a new webhook-received event instance.
     *
     * @param array<string, mixed> $payload The full verified webhook request body
     *                                      as an associative array. Common keys
     *                                      include {@code trade_status}, {@code merch_order_id},
     *                                      and {@code biz_content}.
     */
    public function __construct(
        public readonly array $payload,
    ) {}
}
