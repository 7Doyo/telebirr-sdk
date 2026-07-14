<?php

declare(strict_types=1);

namespace App;

use Telebirr\Sdk\Core\Telebirr;
use Telebirr\Sdk\Core\Models\Config;

class Dependencies
{
    public static function register(\Slim\App $app): void
    {
        $container = $app->getContainer();

        if ($container === null) {
            return;
        }

        $container->set('telebirr', function (): Telebirr {
            $config = new Config(
                environment: $_ENV['TELEBIRR_ENVIRONMENT'] ?? 'SANDBOX',
                fabricAppId: $_ENV['TELEBIRR_FABRIC_APP_ID'] ?? '',
                merchantAppId: $_ENV['TELEBIRR_MERCHANT_APP_ID'] ?? '',
                merchantCode: $_ENV['TELEBIRR_MERCHANT_CODE'] ?? '',
                apiKey: $_ENV['TELEBIRR_API_KEY'] ?? '',
                privateKeyPem: $_ENV['TELEBIRR_PRIVATE_KEY'] ?? '',
                shortCode: $_ENV['TELEBIRR_SHORT_CODE'] ?? '220311',
                timeout: $_ENV['TELEBIRR_TIMEOUT'] ?? '120m',
                notifyUrl: $_ENV['TELEBIRR_NOTIFY_URL'] ?? '',
            );

            return new Telebirr($config);
        });
    }
}

if (!function_exists('telebirr')) {
    function telebirr(): \Telebirr\Sdk\Core\Telebirr
    {
        global $app;
        $container = $app->getContainer();
        return $container->get('telebirr');
    }
}

if (!function_exists('config')) {
    function config(string $key, mixed $default = null): mixed
    {
        $configs = [
            'telebirr.short_code' => $_ENV['TELEBIRR_SHORT_CODE'] ?? '220311',
            'telebirr.timeout' => $_ENV['TELEBIRR_TIMEOUT'] ?? '120m',
        ];

        return $configs[$key] ?? $default;
    }
}
