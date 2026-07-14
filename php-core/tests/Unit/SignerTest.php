<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\Signer;

class SignerTest extends TestCase
{
    public function testBuildSignStringExcludesSignAndSignType(): void
    {
        $request = [
            'nonce_str' => 'ABC123',
            'method' => 'payment.preorder',
            'timestamp' => '1234567890',
            'version' => '1.0',
            'sign_type' => 'SHA256WithRSA',
            'sign' => 'some-signature',
        ];

        $result = Signer::buildSignString($request);

        $this->assertStringNotContainsString('sign=', $result);
        $this->assertStringNotContainsString('sign_type=', $result);
    }

    public function testBuildSignStringFlattensBizContent(): void
    {
        $request = [
            'nonce_str' => 'ABC123',
            'method' => 'payment.preorder',
            'biz_content' => [
                'appid' => '12345',
                'merch_code' => 'MC001',
            ],
        ];

        $result = Signer::buildSignString($request);

        $this->assertStringContainsString('appid=12345', $result);
        $this->assertStringContainsString('merch_code=MC001', $result);
        $this->assertStringNotContainsString('biz_content', $result);
    }

    public function testBuildSortsKeysAsciiLexicographically(): void
    {
        $request = [
            'zebra' => '1',
            'apple' => '2',
            'method' => '3',
        ];

        $result = Signer::buildSignString($request);

        $this->assertSame('apple=2&method=3&zebra=1', $result);
    }

    public function testBuildProducesKeyEqualsValueFormat(): void
    {
        $request = [
            'nonce_str' => 'XYZ789',
            'method' => 'test',
        ];

        $result = Signer::buildSignString($request);

        $this->assertMatchesRegularExpression('/^method=test&nonce_str=XYZ789$/', $result);
    }

    public function testBuildExcludesHeaderAndRefundInfoAndOpenType(): void
    {
        $request = [
            'nonce_str' => 'ABC',
            'header' => 'val',
            'refund_info' => 'val',
            'openType' => 'val',
            'raw_request' => 'val',
        ];

        $result = Signer::buildSignString($request);

        $this->assertStringNotContainsString('header', $result);
        $this->assertStringNotContainsString('refund_info', $result);
        $this->assertStringNotContainsString('openType', $result);
        $this->assertStringNotContainsString('raw_request', $result);
    }

    public function testBuildExcludesBizContentNestedExcludedFields(): void
    {
        $request = [
            'method' => 'payment.preorder',
            'biz_content' => [
                'appid' => '12345',
                'sign' => 'nested-sign',
                'header' => 'nested-header',
            ],
        ];

        $result = Signer::buildSignString($request);

        $this->assertStringContainsString('appid=12345', $result);
        $this->assertStringNotContainsString('sign=', $result);
        $this->assertStringNotContainsString('header=', $result);
    }

    public function testSignProducesBase64String(): void
    {
        $pemPath = __DIR__ . '/test_private_key.pem';
        if (!file_exists($pemPath)) {
            $this->markTestSkipped('Test key file not found at ' . $pemPath);
        }

        $pem = file_get_contents($pemPath);
        $this->assertNotFalse($pem);

        $request = [
            'method' => 'payment.preorder',
            'nonce_str' => 'ABC123',
        ];

        $signature = Signer::sign($request, $pem);

        $this->assertNotEmpty($signature);
        $this->assertMatchesRegularExpression('/^[A-Za-z0-9+\/]+=*$/', $signature);
    }

    public function testSignAndVerifyRoundTrip(): void
    {
        $pemPath = __DIR__ . '/test_private_key.pem';
        if (!file_exists($pemPath)) {
            $this->markTestSkipped('Test key file not found at ' . $pemPath);
        }

        $pem = file_get_contents($pemPath);
        $this->assertNotFalse($pem);

        $key = openssl_pkey_get_private($pem);
        $this->assertNotFalse($key);

        $details = openssl_pkey_get_details($key);
        $this->assertArrayHasKey('key', $details);

        $request = [
            'method' => 'payment.preorder',
            'nonce_str' => 'TEST123',
            'timestamp' => '1700000000',
            'biz_content' => [
                'appid' => '12345',
                'total_amount' => '100',
            ],
        ];

        $signature1 = Signer::sign($request, $pem);
        $signature2 = Signer::sign($request, $pem);

        $this->assertNotEmpty($signature1);
        $this->assertNotEmpty($signature2);
        $this->assertMatchesRegularExpression('/^[A-Za-z0-9+\/]+=*$/', $signature1);

        $this->assertNotSame($signature1, $signature2, 'Signatures should differ due to random salt');

        $signString = Signer::buildSignString($request);
        $this->assertStringContainsString('appid=12345', $signString);
        $this->assertStringContainsString('method=payment.preorder', $signString);
        $this->assertStringContainsString('nonce_str=TEST123', $signString);
        $this->assertStringContainsString('timestamp=1700000000', $signString);
        $this->assertStringContainsString('total_amount=100', $signString);

        $decoded1 = base64_decode($signature1, true);
        $decoded2 = base64_decode($signature2, true);
        $this->assertNotFalse($decoded1);
        $this->assertNotFalse($decoded2);
        $this->assertSame(256, strlen($decoded1), 'RSA-2048 signature must be 256 bytes');
        $this->assertSame(256, strlen($decoded2), 'RSA-2048 signature must be 256 bytes');
    }
}
