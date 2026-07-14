<?php

declare(strict_types=1);

use Telebirr\Laravel\TelebirrFacade;
use Telebirr\Sdk\Core\Models\RefundParams;
use Telebirr\Sdk\Core\ReceiveCode;
use Telebirr\Sdk\Core\Webhook;

if (!function_exists('telebirr')) {
    /**
     * Resolve the Telebirr SDK instance from the service container.
     *
     * This is the primary entry-point for all helper functions. It
     * resolves the {@see Telebirr} singleton registered by
     * {@see TelebirrServiceProvider}.
     *
     * @return \Telebirr\Sdk\Core\Telebirr The resolved SDK instance.
     */
    function telebirr(): \Telebirr\Sdk\Core\Telebirr
    {
        return TelebirrFacade::getFacadeRoot();
    }
}

if (!function_exists('telebirr_charge')) {
    /**
     * Create a Telebirr payment order and return the order response.
     *
     * A convenience wrapper around {@code Telebirr::payments()->charge()}
     * that constructs the {@see \Telebirr\Sdk\Core\Models\CreateOrderParams}
     * from simple scalar arguments. If no order ID is provided, a unique
     * identifier is generated automatically using {@code uniqid()}.
     *
     * @param string      $amount  The payment amount in ETB (e.g. "100.00").
     * @param string      $title   A human-readable title for the order (e.g. "Coffee Purchase").
     * @param string|null $orderId A unique order identifier. When {@code null}, a
     *                             prefixed unique ID is generated automatically.
     *
     * @return \Telebirr\Sdk\Core\Models\CreateOrderResponse The API response
     *         containing the prepay ID and order details.
     */
    function telebirr_charge(string $amount, string $title, ?string $orderId = null): \Telebirr\Sdk\Core\Models\CreateOrderResponse
    {
        return telebirr()->payments->charge(new \Telebirr\Sdk\Core\Models\CreateOrderParams(
            orderId: $orderId ?? uniqid('tlb_', true),
            amount: $amount,
            title: $title,
        ));
    }
}

if (!function_exists('telebirr_receive_code')) {
    /**
     * Build a Telebirr receive code string for a specific order.
     *
     * The receive code encodes the short code, amount, prepay ID, and
     * timeout into a single string that can be rendered as a QR code
     * or passed to the mobile SDK for in-app payment.
     *
     * Format: {@code TELEBIRR$BUYGOODS{shortCode}{amount}{prepay_id}%{timeout}}
     *
     * @param string $amount   The payment amount in ETB.
     * @param string $prepayId The prepay ID returned from {@see telebirr_charge()}.
     *
     * @return string The formatted receive code string.
     */
    function telebirr_receive_code(string $amount, string $prepayId): string
    {
        $config = config('telebirr');
        return ReceiveCode::build(
            shortCode: $config['short_code'],
            amount: $amount,
            prepayId: $prepayId,
            timeout: $config['timeout'],
        );
    }
}

if (!function_exists('telebirr_refund')) {
    /**
     * Submit a refund request for a previously completed payment.
     *
     * Constructs a {@see \Telebirr\Sdk\Core\Models\RefundParams} from the
     * provided arguments and forwards it to
     * {@code Telebirr::payments()->refund()}.
     *
     * @param string      $merchOrderId   The original merchant order ID to refund.
     * @param string      $refundRequestNo A unique identifier for this refund request.
     * @param string      $refundAmount   The amount to refund in ETB (e.g. "50.00").
     * @param string|null $refundReason   An optional human-readable reason for the refund.
     *
     * @return \Telebirr\Sdk\Core\Models\RefundResponse The API response
     *         containing the refund status and details.
     */
    function telebirr_refund(
        string $merchOrderId,
        string $refundRequestNo,
        string $refundAmount,
        ?string $refundReason = null,
    ): \Telebirr\Sdk\Core\Models\RefundResponse {
        $params = new RefundParams(
            merchOrderId: $merchOrderId,
            refundRequestNo: $refundRequestNo,
            refundAmount: $refundAmount,
            refundReason: $refundReason,
        );

        return telebirr()->payments->refund($params);
    }
}

if (!function_exists('telebirr_verify_webhook')) {
    /**
     * Verify the cryptographic signature of an incoming Telebirr webhook payload.
     *
     * Uses the configured private key to validate that the payload was
     * signed by Telebirr's servers. Returns {@code false} immediately
     * if the private key is not configured.
     *
     * @param array<string, mixed> $payload The raw webhook request body as an associative array.
     *
     * @return bool {@code true} if the signature is valid, {@code false} otherwise.
     */
    function telebirr_verify_webhook(array $payload): bool
    {
        $privateKey = config('telebirr.private_key', '');

        if ($privateKey === '') {
            return false;
        }

        return Webhook::verify($payload, $privateKey);
    }
}
