# Telebirr TypeScript Express Example

A minimal Express.js server demonstrating the `@telebirr/sdk-core` SDK.

## Setup

```bash
cp .env.example .env
# Edit .env with your Telebirr developer credentials

npm install
npm run dev
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/charge` | Create a payment order |
| `POST` | `/query` | Query order status |
| `POST` | `/refund` | Refund an order |
| `POST` | `/webhook` | Receive payment notifications |
| `GET` | `/receive-code/:prepayId` | Build a receive code for a prepay ID |

## Example Requests

### Charge

```bash
curl -X POST http://localhost:3000/charge \
  -H "Content-Type: application/json" \
  -d '{"amount": "100", "title": "Test Order"}'
```

### Query

```bash
curl -X POST http://localhost:3000/query \
  -H "Content-Type: application/json" \
  -d '{"orderId": "ORD1719000000ABC123"}'
```

### Refund

```bash
curl -X POST http://localhost:3000/refund \
  -H "Content-Type: application/json" \
  -d '{"orderId": "ORD1719000000ABC123", "refundRequestNo": "RFD001", "refundAmount": "50"}'
```
