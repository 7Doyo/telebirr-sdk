# Telebirr Laravel Bridge

<details>
<summary>🚧 <strong>Project Status: In Development</strong></summary>
<br>
This project is currently active and under heavy development. Things are changing rapidly, and not all features are fully functional yet. Check back often for updates!
</details>

Laravel integration for the [Telebirr Payment Gateway](https://developerportal.ethiotelebirr.et/). Wraps the headless [`telebirr/sdk-core`](../php-core/README.md) package with Laravel-native service providers, facades, helper functions, route registration, event dispatching, and localization.

## Requirements

| Dependency | Version |
|---|---|
| PHP | >= 8.1 |
| Laravel | 10.x, 11.x, or 12.x |
| `telebirr/sdk-core` | ^0.1.0 (installed automatically) |

## Installation

```bash
composer require telebirr/laravel-bridge
```

The service provider and facade are auto-discovered by Laravel. No manual registration is required.

### Publish Assets

```bash
# Publish configuration file to config/telebirr.php
php artisan vendor:publish --tag=telebirr-config

# Publish translation files to lang/vendor/telebirr/
php artisan vendor:publish --tag=telebirr-lang
```

## Configuration

Add the following variables to your `.env` file:

```env
TELEBIRR_ENVIRONMENT=SANDBOX
TELEBIRR_FABRIC_APP_ID=5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c
TELEBIRR_MERCHANT_APP_ID=12345
TELEBIRR_MERCHANT_CODE=TEST_MERCHANT
TELEBIRR_API_KEY=sk_test_xxxxxxxxxxxxxxxx
TELEBIRR_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEv..."
TELEBIRR_SHORT_CODE=220311
TELEBIRR_TIMEOUT=120m
TELEBIRR_NOTIFY_URL=https://your-app.com/telebirr/webhook
```

### Configuration Reference

| Key | Env Variable | Default | Description |
|---|---|---|---|
| `environment` | `TELEBIRR_ENVIRONMENT` | `SANDBOX` | `SANDBOX` or `PRODUCTION` |
| `fabric_app_id` | `TELEBIRR_FABRIC_APP_ID` | `''` | UUID from the Telebirr developer portal |
| `merchant_app_id` | `TELEBIRR_MERCHANT_APP_ID` | `''` | Numeric merchant application ID |
| `merchant_code` | `TELEBIRR_MERCHANT_CODE` | `''` | Merchant code |
| `api_key` | `TELEBIRR_API_KEY` | `''` | Application secret (appSecret) |
| `private_key` | `TELEBIRR_PRIVATE_KEY` | `''` | PKCS#8 PEM-formatted private key for signing |
| `short_code` | `TELEBIRR_SHORT_CODE` | `220311` | Payee short code |
| `timeout` | `TELEBIRR_TIMEOUT` | `120m` | Order timeout expression |
| `notify_url` | `TELEBIRR_NOTIFY_URL` | `''` | Webhook callback URL |
| `base_url` | `TELEBIRR_BASE_URL` | `null` | Override API base URL (optional) |
| `locale` | `TELEBIRR_LOCALE` | `app.locale` | Active locale for trans() strings |
| `fallback_locale` | `TELEBIRR_FALLBACK_LOCALE` | `app.fallback_locale` | Fallback locale |
| `listeners` | -- | `[]` | Event-to-listener mappings (see below) |

### Environment Guard

Keys prefixed with `sk_test_` are restricted to the `SANDBOX` environment. Keys prefixed with `sk_live_` are restricted to `PRODUCTION`. Using a key in the wrong environment throws a RuntimeException at boot.

## Route Registration

The service provider registers two routes automatically during `boot()`:

| Method | URI | Name | Handler |
|---|---|---|---|
| `POST` | `/telebirr/webhook` | `telebirr.webhook` | `WebhookController` |
| `POST` | `/telebirr/refund` | `telebirr.refund` | `RefundController::store` |

To register routes under an `api` prefix instead, call the static helper in your `routes/api.php`:

```php
use Telebirr\Laravel\Routes\WebhookRoutes;

WebhookRoutes::registerApi();
```

This produces `/api/telebirr/webhook` and `/api/telebirr/refund`.

## Webhook Handling

### How It Works

1. Telebirr sends a `POST` request to your webhook URL.
2. `WebhookController` verifies the RSA signature against the configured private key.
3. If valid, a `WebhookReceived` event is dispatched with the full payload array.
4. The controller returns `{ "status": "ok" }` with a `200` response.

If signature verification fails, a `401` response is returned and no event is dispatched.

### Events

| Event | Properties | Description |
|---|---|---|
| `WebhookReceived` | `payload: array` | Fired for every valid webhook. Contains the raw Telebirr payload. |
| `PaymentSucceeded` | `orderId: string`, `response: array` | Fired when `trade_status` indicates a completed payment. |
| `PaymentFailed` | `orderId: string`, `error: string` | Fired when `trade_status` indicates a failed payment. |

### Registering Listeners

#### Via Config

Add listeners to the `listeners` array in `config/telebirr.php`:

```php
'listeners' => [
    \Telebirr\Laravel\Events\PaymentSucceeded::class => [
        \App\Listeners\HandleSuccessfulPayment::class,
    ],
    \Telebirr\Laravel\Events\PaymentFailed::class => [
        \App\Listeners\HandleFailedPayment::class,
    ],
],
```

#### Via EventServiceProvider

```php
protected $listen = [
    \Telebirr\Laravel\Events\PaymentSucceeded::class => [
        \App\Listeners\HandleSuccessfulPayment::class,
    ],
];
```

### Listener Example

```php
<?php

declare(strict_types=1);

namespace App\Listeners;

use Telebirr\Laravel\Events\PaymentSucceeded;

class HandleSuccessfulPayment
{
    public function handle(PaymentSucceeded $event): void
    {
        $orderId = $event->orderId;
        $payload = $event->response;

        // Update order status, send confirmation email, etc.
        \App\Models\Order::where('merch_order_id', $orderId)->update([
            'status' => 'paid',
        ]);
    }
}
```

### Manual Webhook Verification

Outside of the controller, use the helper function:

```php
$payload = request()->all();

if (telebirr_verify_webhook($payload)) {
    // Signature is valid
}
```

## Refund API

### HTTP Endpoint

Send a `POST` request to `/telebirr/refund` with a JSON body:

```json
{
    "merch_order_id": "order-123",
    "refund_request_no": "refund-001",
    "refund_amount": "100",
    "refund_reason": "Customer requested cancellation"
}
```

| Field | Required | Description |
|---|---|---|
| `merch_order_id` | Yes | Original order ID to refund |
| `refund_request_no` | Yes | Unique refund request identifier |
| `refund_amount` | Yes | Amount to refund (string, in ETB) |
| `refund_reason` | No | Reason for the refund |

**Response (success):**

```json
{
    "status": "success",
    "code": "0",
    "message": "...",
    "refund_order_id": "...",
    "refund_status": "SUCCESS"
}
```

### Helper Function

```php
$response = telebirr_refund(
    merchOrderId: 'order-123',
    refundRequestNo: 'refund-001',
    refundAmount: '100',
    refundReason: 'Customer requested cancellation',
);

if ($response->isSuccessful()) {
    // Refund succeeded
}
```

## Facade Usage

The `Telebirr` facade proxies all methods on the underlying `Telebirr\Sdk\Core\Telebirr` singleton.

```php
use Telebirr\Laravel\Facades\Telebirr;

// Create a payment order
$response = Telebirr()->payments->charge(new \Telebirr\Sdk\Core\Models\CreateOrderParams(
    orderId: 'order-123',
    amount: '100',
    title: 'Product Purchase',
));

// Refund a payment
$response = Telebirr()->payments->refund(new \Telebirr\Sdk\Core\Models\RefundParams(
    merchOrderId: 'order-123',
    refundRequestNo: 'refund-001',
    refundAmount: '100',
));

// Get the prepay ID for QR code flows
$prepayId = $response->prepayId;
```

## Helper Functions

All helpers are globally available and defined in `src/helpers.php`.

### `telebirr()`

Returns the underlying `Telebirr\Sdk\Core\Telebirr` client instance.

```php
$client = telebirr();
```

### `telebirr_charge(string $amount, string $title, ?string $orderId = null)`

Shortcut for creating a payment order. Generates a unique order ID if none is provided.

```php
$response = telebirr_charge('100', 'Product Purchase');
$response = telebirr_charge('250', 'Subscription', 'order-abc-123');
```

### `telebirr_receive_code(string $amount, string $prepayId)`

Builds a receive code string for QR code payment flows.

```php
$code = telebirr_receive_code('100', $prepayId);
// Returns: TELEBIRR$BUYGOODS220311100PREPAY...%120m
```

### `telebirr_refund(string $merchOrderId, string $refundRequestNo, string $refundAmount, ?string $refundReason = null)`

Processes a refund against an existing order.

```php
$response = telebirr_refund('order-123', 'refund-001', '100', 'Customer request');
```

### `telebirr_verify_webhook(array $payload)`

Verifies the signature of an incoming webhook payload. Returns `false` if the private key is not configured.

```php
if (telebirr_verify_webhook(request()->all())) {
    // Valid webhook
}
```

## Localization

Translation files are provided in five locales under `lang/`:

| Locale | Language |
|---|---|
| `en` | English |
| `am` | Amharic |
| `ar` | Arabic |
| `om` | Oromo |
| `ti` | Tigrinya |

Use the `telebirr` translation domain with `trans()`:

```php
// With default locale
echo trans('telebirr::messages.pay_now');

// Switch locale
app()->setLocale('am');
echo trans('telebirr::messages.status_success');
```

After publishing, translation files are located at `lang/vendor/telebirr/{locale}/messages.php`.

### Available Translation Keys

`pay_now`, `processing`, `test_mode`, `status_success`, `status_fail`, `status_timeout`, `status_pending`, `status_accepted`, `status_refunding`, `status_refund_success`, `status_refund_failed`, `refund`, `refund_confirm`, `refund_processing`, `refund_success`, `refund_failed`, `retry`, `retry_countdown`, `retry_failed`, `error_generic`, `error_network`, `error_timeout`, `error_auth`, `error_validation`, `error_dismiss`, `webhook_verification_failed`.

## Testing

```bash
cd laravel-bridge
composer install
vendor/bin/phpunit
```

The test suite uses [Orchestra Testbench](https://github.com/orchestral/testbench) to bootstrap a Laravel application instance. Tests cover the service provider, facade resolution, webhook controller signature verification, and refund controller request handling.

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
