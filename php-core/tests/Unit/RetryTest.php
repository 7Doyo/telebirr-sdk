<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\Exceptions\NetworkException;
use Telebirr\Sdk\Core\Exceptions\ValidationException;
use Telebirr\Sdk\Core\Retry;

class RetryTest extends TestCase
{
    public function testReturnsResultOnSuccess(): void
    {
        $result = Retry::withRetry(fn () => 'ok');
        $this->assertSame('ok', $result);
    }

    public function testRetriesOnRetryableError(): void
    {
        $attempts = 0;
        $result = Retry::withRetry(
            function () use (&$attempts) {
                $attempts++;
                if ($attempts < 3) {
                    throw new NetworkException('fail');
                }
                return 'ok';
            },
            ['maxAttempts' => 3, 'baseDelayMs' => 1],
        );
        $this->assertSame('ok', $result);
        $this->assertSame(3, $attempts);
    }

    public function testThrowsAfterMaxAttempts(): void
    {
        $this->expectException(NetworkException::class);
        Retry::withRetry(
            fn () => throw new NetworkException('fail'),
            ['maxAttempts' => 2, 'baseDelayMs' => 1],
        );
    }

    public function testDoesNotRetryOnNonRetryableError(): void
    {
        $attempts = 0;
        try {
            Retry::withRetry(
                function () use (&$attempts) {
                    $attempts++;
                    throw new ValidationException('fail');
                },
                ['maxAttempts' => 3, 'baseDelayMs' => 1],
            );
        } catch (ValidationException $e) {
            // expected
        }
        $this->assertSame(1, $attempts);
    }
}
