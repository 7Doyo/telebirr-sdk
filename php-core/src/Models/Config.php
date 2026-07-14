<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Models;

/**
 * SDK configuration model containing all credentials and environment settings.
 *
 * Holds the API keys, merchant identifiers, and endpoint configuration needed
 * to interact with the Telebirr payment gateway.
 */
class Config
{
    /**
     * Sandbox environment identifier.
     *
     * @var string
     */
    public const ENV_SANDBOX = 'SANDBOX';

    /**
     * Production environment identifier.
     *
     * @var string
     */
    public const ENV_PRODUCTION = 'PRODUCTION';

    /**
     * Telebirr sandbox API base URL.
     *
     * @var string
     */
    private const SANDBOX_URL = 'https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway';

    /**
     * Telebirr production API base URL.
     *
     * @var string
     */
    private const PRODUCTION_URL = 'https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway';

    /**
     * Create a new Config instance.
     *
     * @param string $environment Target environment: Config::ENV_SANDBOX or Config::ENV_PRODUCTION
     * @param string $fabricAppId UUID-format fabric application ID from the developer portal
     * @param string $merchantAppId Numeric merchant application ID
     * @param string $merchantCode Merchant code assigned by Telebirr
     * @param string $apiKey API secret key (prefixed with 'sk_test_' or 'sk_live_')
     * @param string $privateKeyPem PEM-encoded RSA private key (PKCS#8) for request signing
     * @param string $shortCode Merchant short code (e.g. "220311")
     * @param string $timeout Payment timeout expression (e.g. "120m")
     * @param string $notifyUrl Webhook URL to receive payment notifications
     * @param string|null $baseUrl Optional override for the API base URL
     */
    public function __construct(
        public readonly string $environment,
        public readonly string $fabricAppId,
        public readonly string $merchantAppId,
        public readonly string $merchantCode,
        public readonly string $apiKey,
        public readonly string $privateKeyPem,
        public readonly string $shortCode,
        public readonly string $timeout,
        public readonly string $notifyUrl,
        public readonly ?string $baseUrl = null,
    ) {}

    /**
     * Get the API base URL for the configured environment.
     *
     * Returns the custom baseUrl if provided, otherwise returns the default
     * URL for the configured environment (sandbox or production).
     *
     * @return string The API base URL
     */
    public function getBaseUrl(): string
    {
        return $this->baseUrl
            ?? ($this->environment === self::ENV_SANDBOX ? self::SANDBOX_URL : self::PRODUCTION_URL);
    }
}
