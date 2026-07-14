<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * Normalized payment status enum for the Telebirr SDK.
 *
 * Maps Telebirr's raw trade_status strings (both UPPER_CASE from queryOrder
 * and camelCase from webhooks) to a unified set of status values.
 */
enum PaymentStatus: string
{
    /** Payment completed successfully */
    case SUCCESS = 'SUCCESS';

    /** Payment failed */
    case FAIL = 'FAIL';

    /** Order expired or was closed without payment */
    case TIMEOUT = 'TIMEOUT';

    /** Payment is awaiting or currently in progress */
    case PENDING = 'PENDING';

    /** Order accepted by the gateway, awaiting processing */
    case ACCEPTED = 'ACCEPTED';

    /** Refund is currently being processed */
    case REFUNDING = 'REFUNDING';

    /** Refund completed successfully */
    case REFUND_SUCCESS = 'REFUND_SUCCESS';

    /** Refund processing failed */
    case REFUND_FAILED = 'REFUND_FAILED';

    /**
     * Mapping from Telebirr raw trade_status strings to PaymentStatus enum cases.
     *
     * Covers both queryOrder (UPPER_CASE) and webhook (camelCase) status values.
     *
     * @var array<string, PaymentStatus>
     */
    private const RAW_MAP = [
        'PAY_SUCCESS' => self::SUCCESS,
        'PAY_FAILED' => self::FAIL,
        'ORDER_CLOSED' => self::TIMEOUT,
        'WAIT_PAY' => self::PENDING,
        'PAYING' => self::PENDING,
        'ACCEPTED' => self::ACCEPTED,
        'REFUNDING' => self::REFUNDING,
        'REFUND_SUCCESS' => self::REFUND_SUCCESS,
        'REFUND_FAILED' => self::REFUND_FAILED,
    ];

    /**
     * Convert a Telebirr raw trade_status string to a PaymentStatus enum case.
     *
     * Unrecognized status strings default to PENDING.
     *
     * @param string $rawStatus The raw trade_status from Telebirr (e.g. "PAY_SUCCESS", "Completed")
     *
     * @return self The corresponding PaymentStatus enum case
     */
    public static function fromTelebirr(string $rawStatus): self
    {
        return self::RAW_MAP[$rawStatus] ?? self::PENDING;
    }

    /**
     * Check if this status represents a terminal (non-retryable) state.
     *
     * Terminal states are SUCCESS, FAIL, TIMEOUT, REFUND_SUCCESS, and REFUND_FAILED.
     *
     * @return bool True if the payment is in a terminal state
     */
    public function isTerminal(): bool
    {
        return $this === self::SUCCESS
            || $this === self::FAIL
            || $this === self::TIMEOUT
            || $this === self::REFUND_SUCCESS
            || $this === self::REFUND_FAILED;
    }

    /**
     * Check if the payment status indicates a query should be retried.
     *
     * Only PENDING status returns true, as other states are either terminal or in-progress.
     *
     * @return bool True if the payment is in PENDING status and should be re-queried
     */
    public function shouldRetry(): bool
    {
        return $this === self::PENDING;
    }
}
