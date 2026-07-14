<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core;

use Telebirr\Sdk\Core\Exceptions\EnvironmentException;
use Telebirr\Sdk\Core\Models\Config;

/**
 * Main entry point for the Telebirr SDK.
 *
 * Validates environment configuration and provides access to the payments subsystem.
 */
class Telebirr
{
    /** @var Payments Payment operations handler */
    public readonly Payments $payments;

    /** @var Config SDK configuration */
    private Config $config;

    /**
     * Create a new Telebirr SDK instance.
     *
     * Validates that the API key matches the target environment and initializes the payments handler.
     *
     * @param Config $config SDK configuration containing credentials and environment settings
     *
     * @throws EnvironmentException If the API key does not match the target environment
     */
    public function __construct(Config $config)
    {
        $this->validateEnvironment($config);
        $this->config = $config;
        $this->payments = new Payments($config);
    }

    /**
     * Validate that the API key is appropriate for the target environment.
     *
     * Prevents test keys from being used in production and live keys from being used in sandbox.
     *
     * @param Config $config SDK configuration to validate
     *
     * @throws EnvironmentException If a test key is used with production or a live key with sandbox
     */
    private function validateEnvironment(Config $config): void
    {
        $apiKey = $config->apiKey;
        $env = $config->environment;

        if (str_starts_with($apiKey, 'sk_test_') && $env === Config::ENV_PRODUCTION) {
            throw new EnvironmentException('Test key cannot be used with production environment');
        }

        if (str_starts_with($apiKey, 'sk_live_') && $env === Config::ENV_SANDBOX) {
            throw new EnvironmentException('Live key cannot be used with sandbox environment');
        }
    }
}
