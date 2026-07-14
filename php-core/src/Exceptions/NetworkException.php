<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Exceptions;

/**
 * Exception thrown when an HTTP request to the Telebirr gateway fails.
 *
 * Raised on cURL transport errors, non-2xx HTTP status codes, or invalid
 * JSON responses from the gateway.
 */
class NetworkException extends TelebirrException
{
    /**
     * Create a new NetworkException.
     *
     * @param string $message Human-readable description of the network failure
     * @param \Throwable|null $previous The previous exception if this was triggered by another
     */
    public function __construct(string $message, ?\Throwable $previous = null)
    {
        parent::__construct($message, 'NETWORK_ERROR', $previous);
    }
}
