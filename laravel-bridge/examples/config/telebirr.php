<?php

declare(strict_types=1);

return [
    'environment' => env('TELEBIRR_ENVIRONMENT', 'SANDBOX'),
    'fabric_app_id' => env('TELEBIRR_FABRIC_APP_ID', ''),
    'merchant_app_id' => env('TELEBIRR_MERCHANT_APP_ID', ''),
    'merchant_code' => env('TELEBIRR_MERCHANT_CODE', ''),
    'api_key' => env('TELEBIRR_API_KEY', ''),
    'private_key' => env('TELEBIRR_PRIVATE_KEY', ''),
    'short_code' => env('TELEBIRR_SHORT_CODE', '220311'),
    'timeout' => env('TELEBIRR_TIMEOUT', '120m'),
    'notify_url' => env('TELEBIRR_NOTIFY_URL', ''),
    'base_url' => env('TELEBIRR_BASE_URL', null),
];
