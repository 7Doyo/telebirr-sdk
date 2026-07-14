<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\Idempotency;

class IdempotencyTest extends TestCase
{
    public function testGenerates64CharHexString(): void
    {
        $key = Idempotency::generateKey('order-123');
        $this->assertSame(64, strlen($key));
        $this->assertMatchesRegularExpression('/^[0-9A-F]+$/', $key);
    }

    public function testReturnsSameKeyForSameOrderId(): void
    {
        $key1 = Idempotency::generateKey('order-123');
        $key2 = Idempotency::generateKey('order-123');
        $this->assertSame($key1, $key2);
    }

    public function testReturnsDifferentKeysForDifferentOrderIds(): void
    {
        $key1 = Idempotency::generateKey('order-123');
        $key2 = Idempotency::generateKey('order-456');
        $this->assertNotSame($key1, $key2);
    }
}
