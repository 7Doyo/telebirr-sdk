<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Exceptions;

/**
 * Exception thrown when the environment configuration is invalid.
 *
 * Raised when an API key does not match the target environment (e.g. test key
 * used with production, or live key used with sandbox).
 */
class EnvironmentException extends TelebirrException
{
    /**
     * Create a new EnvironmentException.
     *
     * @param string $message Human-readable description of the environment mismatch
     * @param \Throwable|null $previous The previous exception if this was triggered by another
     */
    public function __construct(string $message, ?\Throwable $previous = null)
    {
        parent::__construct($message, 'ENVIRONMENT_ERROR', $previous);
    }
}
