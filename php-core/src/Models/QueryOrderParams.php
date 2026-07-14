<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Parameters for querying the status of an existing order.
 *
 * Contains the merchant order ID needed to look up the order status.
 */
class QueryOrderParams
{
    /**
     * Create a new QueryOrderParams instance.
     *
     * @param string $merchOrderId The merchant order ID to query
     */
    public function __construct(
        public readonly string $merchOrderId,
    ) {}
}
