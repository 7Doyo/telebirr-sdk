<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\Models\Config;

class ConfigTest extends TestCase
{
    private const SANDBOX_URL = 'https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway';
    private const PRODUCTION_URL = 'https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway';

    public function testSandboxConfigReturnsSandboxUrl(): void
    {
        $config = new Config(
            environment: Config::ENV_SANDBOX,
            fabricAppId: 'test-fabric-id',
            merchantAppId: '12345',
            merchantCode: 'MC001',
            apiKey: 'sk_test_xxx',
            privateKeyPem: 'test-key',
            shortCode: '220311',
            timeout: '120m',
            notifyUrl: 'https://example.com/notify',
        );

        $this->assertSame(self::SANDBOX_URL, $config->getBaseUrl());
    }

    public function testProductionConfigReturnsProductionUrl(): void
    {
        $config = new Config(
            environment: Config::ENV_PRODUCTION,
            fabricAppId: 'test-fabric-id',
            merchantAppId: '12345',
            merchantCode: 'MC001',
            apiKey: 'sk_live_xxx',
            privateKeyPem: 'test-key',
            shortCode: '220311',
            timeout: '120m',
            notifyUrl: 'https://example.com/notify',
        );

        $this->assertSame(self::PRODUCTION_URL, $config->getBaseUrl());
    }

    public function testCustomBaseUrlOverridesDefault(): void
    {
        $config = new Config(
            environment: Config::ENV_SANDBOX,
            fabricAppId: 'test-fabric-id',
            merchantAppId: '12345',
            merchantCode: 'MC001',
            apiKey: 'sk_test_xxx',
            privateKeyPem: 'test-key',
            shortCode: '220311',
            timeout: '120m',
            notifyUrl: 'https://example.com/notify',
            baseUrl: 'https://custom.api.test/gateway',
        );

        $this->assertSame('https://custom.api.test/gateway', $config->getBaseUrl());
    }

    public function testConfigPropertiesAreAccessible(): void
    {
        $config = new Config(
            environment: Config::ENV_SANDBOX,
            fabricAppId: 'fabric-123',
            merchantAppId: '67890',
            merchantCode: 'MC002',
            apiKey: 'sk_test_key',
            privateKeyPem: 'pem-content',
            shortCode: '999999',
            timeout: '60m',
            notifyUrl: 'https://hook.test/callback',
        );

        $this->assertSame(Config::ENV_SANDBOX, $config->environment);
        $this->assertSame('fabric-123', $config->fabricAppId);
        $this->assertSame('67890', $config->merchantAppId);
        $this->assertSame('MC002', $config->merchantCode);
        $this->assertSame('sk_test_key', $config->apiKey);
        $this->assertSame('pem-content', $config->privateKeyPem);
        $this->assertSame('999999', $config->shortCode);
        $this->assertSame('60m', $config->timeout);
        $this->assertSame('https://hook.test/callback', $config->notifyUrl);
    }

    public function testEnvConstantsAreDefined(): void
    {
        $this->assertSame('SANDBOX', Config::ENV_SANDBOX);
        $this->assertSame('PRODUCTION', Config::ENV_PRODUCTION);
    }
}
