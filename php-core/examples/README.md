# Telebirr PHP Slim Example

A Slim 4 application demonstrating the `telebirr/sdk-core` PHP SDK.

## Setup

```bash
cp .env.example .env
# Edit .env with your Telebirr developer credentials

composer install
php -S localhost:8000 -t public
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/charge` | Create a payment order |
| `POST` | `/query` | Query order status |
| `POST` | `/refund` | Refund an order |
| `POST` | `/webhook` | Receive payment notifications |
| `GET` | `/receive-code/{prepayId}` | Build a receive code |

## Example Requests

### Charge

```bash
curl -X POST http://localhost:8000/charge \
  -H "Content-Type: application/json" \
  -d '{"amount": "100", "title": "Test Order"}'
```

### Query

```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"orderId": "ORD1719000000ABC123"}'
```

## Notes

- The `Dependencies` class registers the SDK in the Slim container.
- Environment variables are loaded directly from `.env` (use `vlucas/phpdotenv` in production).
- The `telebirr()` helper function provides a shorthand for accessing the SDK instance.
