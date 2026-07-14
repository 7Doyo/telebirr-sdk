# Telebirr Laravel Example

A Laravel 12 application demonstrating the `telebirr/laravel-bridge` package.

## Setup

```bash
cp .env.example .env
# Edit .env with your Telebirr developer credentials

composer install
php artisan serve
```

## Configuration

Publish the config file:

```bash
php artisan vendor:publish --tag=telebirr-config
```

This copies `config/telebirr.php` to your app's `config/` directory.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/charge` | Create a payment order |
| `POST` | `/query` | Query order status |
| `POST` | `/refund` | Refund an order |
| `POST` | `/webhook` | Receive payment notifications (auto-registered by the bridge) |
| `GET` | `/receive-code/{prepayId}` | Build a receive code |

## Example Requests

### Charge

```bash
curl -X POST http://localhost:8000/charge \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"amount": 100, "title": "Test Order"}'
```

### Query

```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"orderId": "ORD1719000000ABC123"}'
```

## Using the Helper

The bridge provides global helper functions:

```php
// Charge
$response = telebirr_charge('100', 'Test Order');

// Refund
$response = telebirr_refund('ORDER_ID', 'REFUND_001', '50', 'Customer request');

// Build receive code
$code = telebirr_receive_code('100', $prepayId);

// Verify webhook
$isValid = telebirr_verify_webhook($payload);

// Access the full SDK
$sdk = telebirr();
$sdk->payments->charge(...);
```

## Events

The bridge fires events you can listen to:

```php
// In app/Providers/EventServiceProvider.php
use Telebirr\Laravel\Events\PaymentSucceeded;
use Telebirr\Laravel\Events\PaymentFailed;
use Telebirr\Laravel\Events\WebhookReceived;

protected $listen = [
    WebhookReceived::class => [
        App\Listeners\HandleTelebirrWebhook::class,
    ],
];
```
