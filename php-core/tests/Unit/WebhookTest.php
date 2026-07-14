<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\Webhook;

class WebhookTest extends TestCase
{
    public function testBuildSignStringExcludesSignAndSignType(): void
    {
        $payload = [
            'merch_order_id' => 'order-123',
            'payment_order_id' => 'pay-456',
            'trade_status' => 'Completed',
            'sign' => 'some-signature',
            'sign_type' => 'SHA256WithRSA',
        ];

        $result = Webhook::buildSignString($payload);

        $this->assertStringContainsString('merch_order_id=order-123', $result);
        $this->assertStringContainsString('payment_order_id=pay-456', $result);
        $this->assertStringContainsString('trade_status=Completed', $result);
        $this->assertStringNotContainsString('sign=', $result);
        $this->assertStringNotContainsString('sign_type=', $result);
    }

    public function testBuildSignStringSortsKeys(): void
    {
        $payload = [
            'zebra' => 'z',
            'alpha' => 'a',
            'middle' => 'm',
        ];

        $result = Webhook::buildSignString($payload);
        $this->assertSame('alpha=a&middle=m&zebra=z', $result);
    }

    public function testVerifyReturnsFalseWhenSignIsMissing(): void
    {
        $payload = [
            'merch_order_id' => 'order-123',
            'trade_status' => 'Completed',
        ];

        $this->assertFalse(Webhook::verify($payload, 'fake-public-key'));
    }

    public function testVerifyReturnsFalseWithInvalidKey(): void
    {
        $payload = [
            'merch_order_id' => 'order-123',
            'trade_status' => 'Completed',
            'sign' => 'invalid-signature',
            'sign_type' => 'SHA256WithRSA',
        ];

        $this->assertFalse(Webhook::verify($payload, 'fake-public-key'));
    }
}
