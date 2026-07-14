<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

/**
 * Builds the receiveCode string used in Telebirr payment flows.
 *
 * The receiveCode encodes payment parameters in a machine-readable format
 * for use in QR codes or deep links.
 */
class ReceiveCode
{
    /**
     * Build a receiveCode string from payment parameters.
     *
     * Format: TELEBIRR$BUYGOODS{shortCode}{amount}{prepayId}%{timeout}
     * Example: TELEBIRR$BUYGOODS220311100PREPAY123%120m
     *
     * @param string $shortCode The merchant short code (e.g. "220311")
     * @param string $amount The payment amount in ETB (e.g. "100")
     * @param string $prepayId The prepay ID returned from createOrder
     * @param string $timeout The payment timeout expression (e.g. "120m")
     *
     * @return string The formatted receiveCode string
     */
    public static function build(string $shortCode, string $amount, string $prepayId, string $timeout): string
    {
        return "TELEBIRR\$BUYGOODS{$shortCode}{$amount}{$prepayId}%{$timeout}";
    }
}
