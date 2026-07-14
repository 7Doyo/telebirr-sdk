<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Exceptions;

/**
 * Base exception class for all Telebirr SDK errors.
 *
 * Extends RuntimeException with a string error code for categorizing
 * SDK-specific error conditions.
 */
class TelebirrException extends \RuntimeException
{
    /**
     * Create a new TelebirrException.
     *
     * @param string $message Human-readable error message
     * @param string $code String error code identifying the error category (default: "UNKNOWN")
     * @param \Throwable|null $previous The previous exception if this was triggered by another
     */
    public function __construct(string $message, string $code = 'UNKNOWN', ?\Throwable $previous = null)
    {
        parent::__construct($message, 0, $previous);
        $this->code = $code;
    }
}
