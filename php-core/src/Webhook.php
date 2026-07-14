<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

/**
 * Webhook notification handler for the Telebirr payment gateway.
 *
 * Provides utilities to build signing strings from webhook payloads and verify
 * webhook signatures using RSA public key verification.
 */
class Webhook
{
    /**
     * Telebirr webhook trade status: payment in progress.
     *
     * @var string
     */
    public const TRADE_PAYING = 'Paying';

    /**
     * Telebirr webhook trade status: payment expired.
     *
     * @var string
     */
    public const TRADE_EXPIRED = 'Expired';

    /**
     * Telebirr webhook trade status: awaiting payment.
     *
     * @var string
     */
    public const TRADE_PENDING = 'Pending';

    /**
     * Telebirr webhook trade status: payment completed successfully.
     *
     * @var string
     */
    public const TRADE_COMPLETED = 'Completed';

    /**
     * Telebirr webhook trade status: payment failed.
     *
     * @var string
     */
    public const TRADE_FAILURE = 'Failure';

    /**
     * Field names to exclude from the webhook signing string.
     *
     * @var list<string>
     */
    private const EXCLUDE_FIELDS = ['sign', 'sign_type'];

    /**
     * Build the canonical signing string from a webhook payload.
     *
     * Excludes 'sign' and 'sign_type' fields and null values, sorts the remaining
     * keys lexicographically, and joins as key=value pairs with '&'.
     *
     * @param array<string, mixed> $payload The webhook notification payload
     *
     * @return string The canonical key=value&... signing string
     */
    public static function buildSignString(array $payload): string
    {
        $fields = [];
        $fieldMap = [];

        foreach ($payload as $key => $value) {
            if (in_array($key, self::EXCLUDE_FIELDS, true)) {
                continue;
            }
            if ($value === null) {
                continue;
            }
            $fields[] = $key;
            $fieldMap[$key] = (string) $value;
        }

        sort($fields, SORT_STRING);

        $parts = [];
        foreach ($fields as $field) {
            $parts[] = $field . '=' . $fieldMap[$field];
        }

        return implode('&', $parts);
    }

    /**
     * Verify the signature of a webhook notification payload.
     *
     * Builds the signing string from the payload (excluding 'sign' and 'sign_type'),
     * then verifies the Base64-decoded signature against the provided PEM-encoded
     * RSA public key using SHA-256.
     *
     * @param array<string, mixed> $payload The webhook notification payload (must include 'sign' key)
     * @param string $publicKeyPem PEM-encoded RSA public key for signature verification
     *
     * @return bool True if the signature is valid, false otherwise
     */
    public static function verify(array $payload, string $publicKeyPem): bool
    {
        $sign = $payload['sign'] ?? null;
        if ($sign === null || $sign === '') {
            return false;
        }

        $signString = self::buildSignString($payload);
        $key = openssl_pkey_get_public($publicKeyPem);
        if ($key === false) {
            return false;
        }

        $result = openssl_verify($signString, base64_decode($sign, true), $key, \OPENSSL_ALGO_SHA256);
        openssl_pkey_free($key);

        return $result === 1;
    }
}
