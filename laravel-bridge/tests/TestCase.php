<?php

declare(strict_types=1);

namespace Telebirr\Laravel\Tests;

use Orchestra\Testbench\TestCase as BaseTestCase;
use Telebirr\Laravel\TelebirrServiceProvider;

abstract class TestCase extends BaseTestCase
{
    protected function getPackageProviders($app): array
    {
        return [TelebirrServiceProvider::class];
    }

    protected function getEnvironmentSetUp($app): void
    {
        $app['config']->set('telebirr.environment', 'SANDBOX');
        $app['config']->set('telebirr.fabric_app_id', 'test-fabric-app-id');
        $app['config']->set('telebirr.merchant_app_id', '12345');
        $app['config']->set('telebirr.merchant_code', 'TEST_MERCHANT');
        $app['config']->set('telebirr.api_key', 'sk_test_key');
        $app['config']->set('telebirr.private_key', 'test-private-key');
        $app['config']->set('telebirr.short_code', '220311');
        $app['config']->set('telebirr.timeout', '120m');
        $app['config']->set('telebirr.notify_url', 'https://example.com/webhook');
    }
}
