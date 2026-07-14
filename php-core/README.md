# telebirr/sdk-core

Headless PHP SDK for the Ethio Telecom Telebirr payment gateway.

Zero external runtime dependencies -- uses only `curl` and `openssl` from the PHP standard library.

## Requirements

- PHP 8.1+
- `curl` extension
- `openssl` extension

## Installation

```bash
composer require telebirr/sdk-core
```

## Quick Start

```php
<?php

use Telebirr\Sdk\Core\Telebirr;
use Telebirr\Sdk\Core\Models\Config;
use Telebirr\Sdk\Core\Models\CreateOrderParams;

$config = new Config(
    environment: 'SANDBOX',
    fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
    merchantAppId: '12345',
    merchantCode: 'TEST_MERCHANT',
    apiKey: 'sk_test_your_app_secret',
    privateKeyPem: file_get_contents('/path/to/private-key.pem'),
    shortCode: '220311',
    timeout: '120m',
    notifyUrl: 'https://your-server.com/webhook',
);

$telebirr = new Telebirr($config);

// Create an order
$response = $telebirr->payments()->charge(new CreateOrderParams(
    orderId: 'ORDER-001',
    title: 'Test Order',
    amount: '100',
));

if ($response->isSuccessful()) {
    echo "Prepay ID: " . $response->prepayId . "\n";
    echo "Receive Code: " . $response->receiveCode . "\n";
}
```

## Configuration

### Constructor

```php
new Config(
    environment: 'SANDBOX',        // 'SANDBOX' or 'PRODUCTION'
    fabricAppId: '...',            // UUID from developer portal
    merchantAppId: '...',          // Numeric merchant app ID
    merchantCode: '...',           // Merchant code
    apiKey: '...',                 // appSecret (sk_test_... or sk_live_...)
    privateKeyPem: '...',          // PKCS8 PEM private key content
    shortCode: '220311',           // Payee short code
    timeout: '120m',               // Order timeout
    notifyUrl: '...',              // Webhook callback URL
    baseUrl: null,                 // Optional URL override
);
```

### Environment Guard

The SDK validates that test keys (`sk_test_`) are not used with the production environment, and live keys (`sk_live_`) are not used with the sandbox. An `EnvironmentException` is thrown on mismatch.

### Environments

| Environment | Base URL |
|-------------|----------|
| SANDBOX | `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway` |
| PRODUCTION | `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway` |

## API Reference

### `Telebirr`

Entry point. Accepts a `Config` instance.

```php
$telebirr = new Telebirr($config);
$payments = $telebirr->payments;
```

### `Payments::charge(CreateOrderParams): CreateOrderResponse`

Create a payment order.

```php
use Telebirr\Sdk\Core\Models\CreateOrderParams;

$response = $telebirr->payments()->charge(new CreateOrderParams(
    orderId: 'ORDER-001',
    title: 'Order Title',
    amount: '100',                          // Amount in ETB
    notifyUrl: 'https://example.com/hook',  // Optional, falls back to config
    redirectUrl: 'https://example.com/ok',  // Optional
    callbackInfo: 'extra-data',             // Optional
    tradeType: 'InApp',                     // Optional, default: 'InApp'
));

$response->isSuccessful();  // bool
$response->prepayId;        // string
$response->receiveCode;     // string
$response->rawResponse;     // array - full API response
```

### `Payments::query(QueryOrderParams): QueryOrderResponse`

Query the status of an order.

```php
use Telebirr\Sdk\Core\Models\QueryOrderParams;

$response = $telebirr->payments()->query(new QueryOrderParams(
    merchOrderId: 'ORDER-001',
));

$response->isSuccessful();   // bool
$response->status;           // PaymentStatus enum
$response->shouldRetry();    // true if PENDING
$response->rawResponse;      // array
```

### `Payments::refund(RefundParams): RefundResponse`

Refund a completed order.

```php
use Telebirr\Sdk\Core\Models\RefundParams;

$response = $telebirr->payments()->refund(new RefundParams(
    merchOrderId: 'ORDER-001',
    refundRequestNo: 'REFUND-001',
    refundAmount: '100',
    refundReason: 'Customer request',  // Optional
));

$response->isSuccessful();    // bool
$response->refundOrderId;     // ?string
$response->refundStatus;      // ?string
$response->rawResponse;       // array
```

### `ReceiveCode::build()`

Build a Telebirr receive code string.

```php
use Telebirr\Sdk\Core\ReceiveCode;

$code = ReceiveCode::build('220311', '100', 'PREPAY123', '120m');
// "TELEBIRR$BUYGOODS220311100PREPAY123%120m"
```

### `Webhook::verify()`

Verify an incoming webhook signature.

```php
use Telebirr\Sdk\Core\Webhook;

$valid = Webhook::verify($payload, $publicKeyPem);
// $payload is the decoded JSON webhook body as an array
```

Webhook `trade_status` values use camelCase:

| Status | Meaning |
|--------|---------|
| `Completed` | Payment successful |
| `Failure` | Payment failed |
| `Expired` | Payment expired |
| `Pending` | Awaiting payment |
| `Paying` | Payment in progress |

### `Idempotency::generateKey()`

Generate a SHA-256 idempotency key from an order ID.

```php
use Telebirr\Sdk\Core\Idempotency;

$key = Idempotency::generateKey('ORDER-001');
```

### `Retry::withRetry()`

Execute a callable with exponential backoff retry logic.

```php
use Telebirr\Sdk\Core\Retry;

$result = Retry::withRetry(fn () => $telebirr->payments()->charge($params), [
    'maxAttempts'  => 3,
    'baseDelayMs'  => 1000,
    'maxDelayMs'   => 10000,
    'retryOn'      => fn ($error) => in_array($error->getCode(), ['NETWORK_ERROR', 'TOKEN_FAILED']),
]);
```

## Payment Status

The `PaymentStatus` enum normalizes Telebirr's raw status strings:

| Raw Status | Enum Value | Terminal? |
|------------|------------|-----------|
| `PAY_SUCCESS` | `SUCCESS` | Yes |
| `PAY_FAILED` | `FAIL` | Yes |
| `ORDER_CLOSED` | `TIMEOUT` | Yes |
| `WAIT_PAY` | `PENDING` | No |
| `PAYING` | `PENDING` | No |

## Error Handling

All SDK exceptions extend `TelebirrException` which extends `RuntimeException`.

| Exception | Code | When |
|-----------|------|------|
| `EnvironmentException` | `ENVIRONMENT_ERROR` | API key does not match environment |
| `ValidationException` | `VALIDATION_ERROR` | Missing or invalid parameters |
| `SigningException` | `SIGNING_ERROR` | Private key failure or signing error |
| `NetworkException` | `NETWORK_ERROR` | HTTP request failed |

```php
use Telebirr\Sdk\Core\Exceptions\TelebirrException;

try {
    $response = $telebirr->payments()->charge($params);
} catch (TelebirrException $e) {
    echo $e->getCode() . ': ' . $e->getMessage() . "\n";
}
```

## Token Caching

Fabric tokens are cached in memory with a 50-minute TTL. Tokens are fetched automatically on the first API call and refreshed on expiry. No manual token management is required.

## Testing

```bash
composer install
vendor/bin/phpunit
```

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
