<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Exceptions;

/**
 * Exception thrown when request signing fails.
 *
 * Raised when the RSA private key cannot be loaded, key details cannot be read,
 * or the PSS signing operation fails.
 */
class SigningException extends TelebirrException
{
    /**
     * Create a new SigningException.
     *
     * @param string $message Human-readable description of the signing failure
     * @param \Throwable|null $previous The previous exception if this was triggered by another
     */
    public function __construct(string $message, ?\Throwable $previous = null)
    {
        parent::__construct($message, 'SIGNING_ERROR', $previous);
    }
}
