<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Exceptions;

/**
 * Exception thrown when input validation fails.
 *
 * Raised when required parameters are missing, have invalid values,
 * or fail business rule validation before sending requests to the gateway.
 */
class ValidationException extends TelebirrException
{
    /**
     * Create a new ValidationException.
     *
     * @param string $message Human-readable description of the validation failure
     * @param \Throwable|null $previous The previous exception if this was triggered by another
     */
    public function __construct(string $message, ?\Throwable $previous = null)
    {
        parent::__construct($message, 'VALIDATION_ERROR', $previous);
    }
}
