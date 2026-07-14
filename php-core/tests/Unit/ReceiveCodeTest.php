<?php

declare(strict_types=1);

namespace Telebirr\Sdk\Core\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Telebirr\Sdk\Core\ReceiveCode;

class ReceiveCodeTest extends TestCase
{
    public function testBuildReturnsCorrectFormat(): void
    {
        $result = ReceiveCode::build('220311', '100', 'PREPAY123', '120m');

        $this->assertSame('TELEBIRR$BUYGOODS220311100PREPAY123%120m', $result);
    }

    public function testBuildWithDifferentValues(): void
    {
        $result = ReceiveCode::build('123456', '500', 'PREPAY456', '30m');

        $this->assertSame('TELEBIRR$BUYGOODS123456500PREPAY456%30m', $result);
    }

    public function testBuildStartsWithTelebirrPrefix(): void
    {
        $result = ReceiveCode::build('000000', '1', 'P0', '1m');

        $this->assertStringStartsWith('TELEBIRR$BUYGOODS', $result);
    }

    public function testBuildContainsPercentBeforeTimeout(): void
    {
        $result = ReceiveCode::build('220311', '100', 'PREPAY123', '120m');

        $this->assertStringContainsString('%120m', $result);
    }
}
