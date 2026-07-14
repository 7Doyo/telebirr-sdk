<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Tests\Unit;

use Telebirr\Laravel\TelebirrFacade;
use Telebirr\Laravel\Tests\TestCase;
use Telebirr\Sdk\Core\Telebirr;

class FacadeTest extends TestCase
{
    public function test_facade_returns_telebirr_instance(): void
    {
        $this->assertInstanceOf(Telebirr::class, TelebirrFacade::getFacadeRoot());
    }
}
