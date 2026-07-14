<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

use Telebirr\Sdk\Core\Models\Config;
use Telebirr\Sdk\Core\Models\CreateOrderParams;
use Telebirr\Sdk\Core\Models\CreateOrderResponse;
use Telebirr\Sdk\Core\Models\PaymentStatus;
use Telebirr\Sdk\Core\Models\QueryOrderParams;
use Telebirr\Sdk\Core\Models\QueryOrderResponse;
use Telebirr\Sdk\Core\Models\RefundParams;
use Telebirr\Sdk\Core\Models\RefundResponse;

/**
 * Handles all payment operations against the Telebirr payment gateway.
 *
 * Supports creating orders, querying order status, and processing refunds.
 * Manages fabric token acquisition and caching automatically.
 */
class Payments
{
    /** @var Config SDK configuration */
    private Config $config;

    /** @var TokenCache In-memory token cache with TTL */
    private TokenCache $tokenCache;

    /**
     * Create a new Payments handler.
     *
     * @param Config $config SDK configuration containing credentials and endpoint settings
     */
    public function __construct(Config $config)
    {
        $this->config = $config;
        $this->tokenCache = new TokenCache();
    }

    /**
     * Create a new payment order on the Telebirr gateway.
     *
     * Builds a signed createOrder request with the provided parameters, sends it to the gateway,
     * and returns the response including a prepay ID and receive code.
     *
     * @param CreateOrderParams $params Order creation parameters including orderId, title, and amount
     *
     * @return CreateOrderResponse Response containing prepayId, receiveCode, and raw gateway response
     *
     * @throws \Telebirr\Sdk\Core\Exceptions\SigningException If request signing fails
     * @throws \Telebirr\Sdk\Core\Exceptions\NetworkException If the HTTP request fails
     * @throws \JsonException If JSON encoding/decoding fails
     */
    public function charge(CreateOrderParams $params): CreateOrderResponse
    {
        $token = $this->getFabricToken();

        $nonceStr = $this->generateNonceStr();
        $timestamp = (string) time();

        $bizContent = [
            'notify_url' => $params->notifyUrl ?? $this->config->notifyUrl,
            'business_type' => 'BuyGoods',
            'trade_type' => $params->tradeType ?? 'InApp',
            'appid' => $this->config->merchantAppId,
            'merch_code' => $this->config->merchantCode,
            'merch_order_id' => $params->orderId,
            'title' => $params->title,
            'total_amount' => $params->amount,
            'trans_currency' => 'ETB',
            'timeout_express' => $this->config->timeout,
            'payee_identifier' => $this->config->shortCode,
            'payee_identifier_type' => '04',
            'payee_type' => '5000',
        ];

        if ($params->redirectUrl !== null) {
            $bizContent['redirect_url'] = $params->redirectUrl;
        }
        if ($params->callbackInfo !== null) {
            $bizContent['callback_info'] = $params->callbackInfo;
        }

        $requestBody = [
            'nonce_str' => $nonceStr,
            'method' => 'payment.preorder',
            'timestamp' => $timestamp,
            'version' => '1.0',
            'sign_type' => 'SHA256WithRSA',
            'biz_content' => $bizContent,
        ];

        $requestBody['sign'] = Signer::sign($requestBody, $this->config->privateKeyPem);

        $url = $this->config->getBaseUrl() . '/payment/v1/merchant/inapp/createOrder';
        $response = HttpClient::postJson($url, $requestBody, [
            'X-APP-Key: ' . $this->config->fabricAppId,
            'Authorization: ' . $token,
        ]);

        $prepayId = $response['biz_content']['prepay_id'] ?? '';
        $receiveCode = '';
        if ($prepayId !== '') {
            $receiveCode = ReceiveCode::build($this->config->shortCode, $params->amount, $prepayId, $this->config->timeout);
        }

        return new CreateOrderResponse(
            code: $response['code'] ?? '',
            message: $response['message'] ?? $response['biz_content']['message'] ?? null,
            prepayId: $prepayId,
            receiveCode: $receiveCode,
            rawResponse: $response,
        );
    }

    /**
     * Query the status of an existing order.
     *
     * Sends a signed queryOrder request and maps the Telebirr trade_status to a PaymentStatus enum.
     *
     * @param QueryOrderParams $params Query parameters including the merchant order ID
     *
     * @return QueryOrderResponse Response containing the normalized payment status and raw gateway response
     *
     * @throws \Telebirr\Sdk\Core\Exceptions\SigningException If request signing fails
     * @throws \Telebirr\Sdk\Core\Exceptions\NetworkException If the HTTP request fails
     * @throws \JsonException If JSON encoding/decoding fails
     */
    public function query(QueryOrderParams $params): QueryOrderResponse
    {
        $token = $this->getFabricToken();

        $nonceStr = $this->generateNonceStr();
        $timestamp = (string) time();

        $requestBody = [
            'nonce_str' => $nonceStr,
            'method' => 'payment.queryorder',
            'timestamp' => $timestamp,
            'version' => '1.0',
            'sign_type' => 'SHA256WithRSA',
            'biz_content' => [
                'appid' => $this->config->merchantAppId,
                'merch_code' => $this->config->merchantCode,
                'merch_order_id' => $params->merchOrderId,
            ],
        ];

        $requestBody['sign'] = Signer::sign($requestBody, $this->config->privateKeyPem);

        $url = $this->config->getBaseUrl() . '/payment/v1/merchant/queryOrder';
        $response = HttpClient::postJson($url, $requestBody, [
            'X-APP-Key: ' . $this->config->fabricAppId,
            'Authorization: ' . $token,
        ]);

        $rawStatus = $response['biz_content']['trade_status'] ?? '';

        return new QueryOrderResponse(
            code: $response['code'] ?? '',
            message: $response['message'] ?? null,
            status: PaymentStatus::fromTelebirr($rawStatus),
            rawResponse: $response,
        );
    }

    /**
     * Request a refund for an existing order.
     *
     * Validates refund parameters, builds a signed refund request, and sends it to the gateway.
     *
     * @param RefundParams $params Refund parameters including order ID, refund request number, and amount
     *
     * @return RefundResponse Response containing refund status and raw gateway response
     *
     * @throws \Telebirr\Sdk\Core\Exceptions\ValidationException If required parameters are missing or invalid
     * @throws \Telebirr\Sdk\Core\Exceptions\SigningException If request signing fails
     * @throws \Telebirr\Sdk\Core\Exceptions\NetworkException If the HTTP request fails
     * @throws \JsonException If JSON encoding/decoding fails
     */
    public function refund(RefundParams $params): RefundResponse
    {
        if ($params->merchOrderId === '') {
            throw new \Telebirr\Sdk\Core\Exceptions\ValidationException('merchOrderId is required');
        }
        if ($params->refundRequestNo === '') {
            throw new \Telebirr\Sdk\Core\Exceptions\ValidationException('refundRequestNo is required');
        }
        if ($params->refundAmount === '' || (float) $params->refundAmount <= 0) {
            throw new \Telebirr\Sdk\Core\Exceptions\ValidationException('refundAmount must be a positive number');
        }

        $token = $this->getFabricToken();

        $nonceStr = $this->generateNonceStr();
        $timestamp = (string) time();

        $bizContent = [
            'appid' => $this->config->merchantAppId,
            'merch_code' => $this->config->merchantCode,
            'merch_order_id' => $params->merchOrderId,
            'refund_request_no' => $params->refundRequestNo,
            'refund_amount' => $params->refundAmount,
        ];

        if ($params->refundReason !== null) {
            $bizContent['refund_reason'] = $params->refundReason;
        }

        $requestBody = [
            'nonce_str' => $nonceStr,
            'method' => 'payment.refund',
            'timestamp' => $timestamp,
            'version' => '1.0',
            'sign_type' => 'SHA256WithRSA',
            'biz_content' => $bizContent,
        ];

        $requestBody['sign'] = Signer::sign($requestBody, $this->config->privateKeyPem);

        $url = $this->config->getBaseUrl() . '/payment/v1/merchant/refund';
        $response = HttpClient::postJson($url, $requestBody, [
            'X-APP-Key: ' . $this->config->fabricAppId,
            'Authorization: ' . $token,
        ]);

        return new RefundResponse(
            code: $response['code'] ?? '',
            message: $response['message'] ?? $response['biz_content']['message'] ?? null,
            refundOrderId: $response['biz_content']['refund_order_id'] ?? null,
            refundStatus: $response['biz_content']['refund_status'] ?? null,
            rawResponse: $response,
        );
    }

    /**
     * Obtain a fabric token from the Telebirr gateway.
     *
     * Returns a cached token if still valid; otherwise requests a new one via the token endpoint
     * and caches it for subsequent use.
     *
     * @return string The fabric token, or an empty string if token acquisition failed
     *
     * @throws \Telebirr\Sdk\Core\Exceptions\NetworkException If the token request fails
     * @throws \JsonException If JSON encoding/decoding fails
     */
    public function getFabricToken(): string
    {
        $cached = $this->tokenCache->get();
        if ($cached !== null) {
            return $cached;
        }

        $url = $this->config->getBaseUrl() . '/payment/v1/token';
        $response = HttpClient::postJson($url, [
            'appSecret' => $this->config->apiKey,
        ], [
            'X-APP-Key: ' . $this->config->fabricAppId,
        ]);

        $token = $response['token'] ?? '';
        if ($token !== '') {
            $this->tokenCache->set($token);
        }

        return $token;
    }

    /**
     * Generate a cryptographically secure 32-character random nonce string.
     *
     * Produces an uppercase alphanumeric string (0-9, A-Z) suitable for API request signing.
     *
     * @return string A 32-character random uppercase alphanumeric string
     */
    private function generateNonceStr(): string
    {
        $chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $str = '';
        $max = strlen($chars) - 1;
        for ($i = 0; $i < 32; $i++) {
            $str .= $chars[random_int(0, $max)];
        }
        return $str;
    }
}
