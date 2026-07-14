<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\TokenCache;

class TokenCacheTest extends TestCase
{
    public function testReturnsNullWhenEmpty(): void
    {
        $cache = new TokenCache();
        $this->assertNull($cache->get());
    }

    public function testReturnsCachedToken(): void
    {
        $cache = new TokenCache();
        $cache->set('test-token');
        $this->assertSame('test-token', $cache->get());
    }

    public function testClearsToken(): void
    {
        $cache = new TokenCache();
        $cache->set('test-token');
        $cache->clear();
        $this->assertNull($cache->get());
    }

    public function testReturnsTokenBeforeTtlExpires(): void
    {
        $cache = new TokenCache(60000);
        $cache->set('test-token');
        $this->assertSame('test-token', $cache->get());
    }
}
