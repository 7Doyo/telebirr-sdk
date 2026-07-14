# @telebirr-sdk/sdk-core

Headless TypeScript SDK for the Ethio Telecom Telebirr payment gateway.

Zero external runtime dependencies. Built on Node.js native `crypto` and `fetch`.

## Features

- Create, query, and refund orders via the Telebirr payment gateway
- SHA256withRSA-PSS request signing with 32-byte salt
- Webhook notification signature verification
- Receive code builder for in-app payment flows
- In-memory token caching with 50-minute TTL
- SHA-256 idempotency key generation
- Retry with exponential backoff for transient failures
- Environment guard preventing test/live key mismatches

## Installation

```bash
npm install @telebirr-sdk/sdk-core
```

Requires Node.js >= 18.

## Quick Start

```typescript
import { Telebirr, PaymentStatus } from '@telebirr-sdk/sdk-core';

const client = new Telebirr({
  environment: 'SANDBOX',
  fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
  merchantAppId: '12345',
  merchantCode: 'TEST_MERCHANT',
  appSecret: 'sk_test_xxx',
  privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
  shortCode: '220311',
  timeout: '120m',
  notifyUrl: 'https://your-server.com/webhook',
});

// Create an order
const order = await client.payments.charge({
  amount: '100',
  title: 'Test Order',
});

console.log(order.prepayId);
console.log(order.receiveCode);

// Query the order
const result = await client.payments.query({
  merchOrderId: 'ORD1719000000ABCDEF',
});

if (result.status === PaymentStatus.SUCCESS) {
  // Payment confirmed
}
```

## API Reference

### `Telebirr`

The main client class. Instantiate with a `TelebirrConfig` object.

```typescript
import { Telebirr } from '@telebirr-sdk/sdk-core';

const client = new Telebirr(config);
```

The constructor validates that the `fabricAppId` is compatible with the selected environment and throws an `EnvironmentError` on mismatch.

#### `client.payments`

All payment operations are accessed through `client.payments`.

---

### `TelebirrConfig`

```typescript
interface TelebirrConfig {
  environment: 'SANDBOX' | 'PRODUCTION';
  fabricAppId: string;
  merchantAppId: string;
  merchantCode: string;
  appSecret: string;
  privateKeyPem: string;
  shortCode: string;
  timeout: string;
  notifyUrl: string;
  baseUrl?: string;
}
```

| Property | Required | Description |
|----------|----------|-------------|
| `environment` | Yes | Target environment. Determines the base URL. |
| `fabricAppId` | Yes | UUID-format app ID from the Telebirr developer portal. |
| `merchantAppId` | Yes | Numeric merchant application ID. |
| `merchantCode` | Yes | Merchant code. |
| `appSecret` | Yes | Application secret (used to obtain bearer tokens). |
| `privateKeyPem` | Yes | PKCS#8 PEM-encoded private key for request signing. |
| `shortCode` | Yes | Merchant short code (e.g. `220311`). |
| `timeout` | Yes | Payment timeout expression (e.g. `120m`). |
| `notifyUrl` | Yes | Webhook URL for payment notifications. |
| `baseUrl` | No | Override the default base URL for the selected environment. |

---

### `client.payments.charge()`

Creates a new payment order.

```typescript
async charge(
  params: CreateOrderParams,
  tradeType?: TradeType,
): Promise<CreateOrderResponse>
```

#### `CreateOrderParams`

```typescript
interface CreateOrderParams {
  amount: string;
  title: string;
  orderId?: string;
  redirectUrl?: string;
  callbackInfo?: string;
}
```

| Property | Required | Description |
|----------|----------|-------------|
| `amount` | Yes | Payment amount in ETB. Must be a positive number. |
| `title` | Yes | Order title displayed to the user. |
| `orderId` | No | Custom order ID. Auto-generated if omitted. |
| `redirectUrl` | No | URL to redirect after payment. |
| `callbackInfo` | No | Arbitrary callback data passed through to the webhook. |

#### `CreateOrderResponse`

```typescript
interface CreateOrderResponse {
  code: string;
  message?: string;
  prepayId: string;
  receiveCode: string;
  rawResponse: Record<string, unknown>;
}
```

#### `TradeType`

```typescript
type TradeType =
  | 'InApp'
  | 'Cross-App'
  | 'WebCheckout'
  | 'PWA'
  | 'QrCode'
  | 'QuickPay'
  | 'BankTrade';
```

Defaults to `'InApp'` when omitted from `charge()`.

---

### `client.payments.query()`

Queries the status of an existing order.

```typescript
async query(params: QueryOrderParams): Promise<QueryOrderResponse>
```

#### `QueryOrderParams`

```typescript
interface QueryOrderParams {
  merchOrderId: string;
}
```

#### `QueryOrderResponse`

```typescript
interface QueryOrderResponse {
  code: string;
  status: PaymentStatus;
  rawResponse: Record<string, unknown>;
}
```

The raw Telebirr `trade_status` is mapped to a unified `PaymentStatus` enum (see below).

---

### `client.payments.refund()`

Refunds an existing order.

```typescript
async refund(params: RefundParams): Promise<RefundResponse>
```

#### `RefundParams`

```typescript
interface RefundParams {
  merchOrderId: string;
  refundRequestNo: string;
  refundAmount: string;
  refundReason?: string;
}
```

| Property | Required | Description |
|----------|----------|-------------|
| `merchOrderId` | Yes | Original order ID to refund. |
| `refundRequestNo` | Yes | Unique refund request identifier. |
| `refundAmount` | Yes | Amount to refund. Must be a positive number. |
| `refundReason` | No | Reason for the refund. |

#### `RefundResponse`

```typescript
interface RefundResponse {
  code: string;
  message?: string;
  refundOrderId?: string;
  refundStatus?: string;
  rawResponse: Record<string, unknown>;
}
```

---

### `PaymentStatus`

Unified enum returned by `query()`. Maps raw Telebirr statuses to a consistent set of values.

```typescript
enum PaymentStatus {
  SUCCESS = 'SUCCESS',
  FAIL = 'FAIL',
  TIMEOUT = 'TIMEOUT',
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  REFUNDING = 'REFUNDING',
  REFUND_SUCCESS = 'REFUND_SUCCESS',
  REFUND_FAILED = 'REFUND_FAILED',
}
```

| Telebirr Status | PaymentStatus |
|-----------------|---------------|
| `PAY_SUCCESS` | `SUCCESS` |
| `PAY_FAILED` | `FAIL` |
| `ORDER_CLOSED` | `TIMEOUT` |
| `WAIT_PAY` | `PENDING` |
| `PAYING` | `PENDING` |
| `ACCEPTED` | `ACCEPTED` |
| `REFUNDING` | `REFUNDING` |
| `REFUND_SUCCESS` | `REFUND_SUCCESS` |
| `REFUND_FAILED` | `REFUND_FAILED` |

Unknown statuses default to `PENDING`.

---

### Webhook Verification

Verify incoming webhook notification signatures.

```typescript
import { verifyNotification, NotificationTradeStatus } from '@telebirr-sdk/sdk-core';

const isValid = verifyNotification(payload, publicKeyPem);
```

`verifyNotification(payload, publicKeyPem)` returns `true` if the signature is valid. The payload is a `NotificationPayload` object representing the raw webhook JSON body.

Note that webhook `trade_status` values use camelCase, distinct from query order responses:

| Webhook Status | PaymentStatus Equivalent |
|----------------|--------------------------|
| `Completed` | `SUCCESS` |
| `Failure` | `FAIL` |
| `Expired` | `TIMEOUT` |
| `Pending` | `PENDING` |
| `Paying` | `PENDING` |

#### `NotificationTradeStatus`

```typescript
enum NotificationTradeStatus {
  PAYING = 'Paying',
  EXPIRED = 'Expired',
  PENDING = 'Pending',
  COMPLETED = 'Completed',
  FAILURE = 'Failure',
}
```

---

### `buildReceiveCode()`

Constructs the receive code string for in-app payment flows.

```typescript
import { buildReceiveCode } from '@telebirr-sdk/sdk-core';

const code = buildReceiveCode(shortCode, amount, prepayId, timeout);
// => "TELEBIRR$BUYGOODS220311100PREPAY123%120m"
```

Format: `TELEBIRR$BUYGOODS{shortCode}{amount}{prepayId}%{timeout}`

Also available as `client.payments.buildReceiveCode(prepayId)` which uses the config's `shortCode` and `timeout`.

---

### Utilities

#### `generateIdempotencyKey()`

Generates a SHA-256 hex digest from an order ID for idempotent requests.

```typescript
import { generateIdempotencyKey } from '@telebirr-sdk/sdk-core';

const key = generateIdempotencyKey('ORD1719000000ABCDEF');
```

#### `withRetry()`

Wraps an async function with exponential backoff retry logic.

```typescript
import { withRetry } from '@telebirr-sdk/sdk-core';

const result = await withRetry(
  () => client.payments.charge({ amount: '100', title: 'Order' }),
  {
    maxAttempts: 3,
    baseDelayMs: 1000,
    maxDelayMs: 10000,
    retryOn: (error) => error instanceof NetworkError,
  },
);
```

| Option | Default | Description |
|--------|---------|-------------|
| `maxAttempts` | `3` | Maximum number of attempts (including the first). |
| `baseDelayMs` | `1000` | Initial delay between retries in milliseconds. |
| `maxDelayMs` | `10000` | Maximum delay cap. |
| `retryOn` | Retries on `NETWORK_ERROR` and `TOKEN_FAILED` | Predicate to decide if an error is retryable. |

Delays follow the pattern `baseDelayMs * 2^(attempt - 1)`, capped at `maxDelayMs`.

#### `generateNonceStr()`

Generates a 32-character uppercase alphanumeric random string for use as `nonce_str`.

```typescript
import { generateNonceStr } from '@telebirr-sdk/sdk-core';

const nonce = generateNonceStr();
```

#### `TokenCache`

In-memory token cache with configurable TTL (default 50 minutes).

```typescript
import { TokenCache } from '@telebirr-sdk/sdk-core';

const cache = new TokenCache({ ttlMs: 30 * 60 * 1000 });
cache.set('token-value');
cache.get(); // => 'token-value' or null if expired
cache.clear();
```

## Signing Algorithm

All API requests are signed using **SHA256withRSA-PSS** with a **32-byte salt length**.

### Process

1. Collect all top-level fields from the request object.
2. Flatten `biz_content` inner fields into the same level.
3. Exclude the following keys: `sign`, `sign_type`, `header`, `refund_info`, `openType`, `raw_request`, `biz_content`.
4. Sort all remaining keys lexicographically (ASCII byte order).
5. Join as `key=value` pairs with `&`.
6. Sign the resulting string with SHA256withRSA-PSS (salt length 32 bytes).
7. Base64-encode the signature.

### Example Signing String

```
appid=12345&business_type=BuyGoods&merch_code=TEST_MERCHANT&merch_order_id=1719000000&notify_url=https://example.com/webhook&payee_identifier=220311&payee_identifier_type=04&payee_type=5000&timeout_express=120m&title=Test+Order&total_amount=100&trade_type=InApp&trans_currency=ETB
```

The low-level signing functions are exported for advanced use:

```typescript
import { buildSignString, sha256PssSign, signRequest } from '@telebirr-sdk/sdk-core';
```

## Error Handling

All SDK errors extend `TelebirrError`:

```typescript
class TelebirrError extends Error {
  code: string;
}
```

| Error Class | `code` | When |
|-------------|--------|------|
| `ValidationError` | `VALIDATION_ERROR` | Invalid input parameters (missing fields, non-positive amounts). |
| `SigningError` | `SIGNING_ERROR` | RSA-PSS signing failed (bad key, crypto error). |
| `NetworkError` | `NETWORK_ERROR` | HTTP request failed or returned a non-2xx status. |
| `EnvironmentError` | `ENVIRONMENT_ERROR` | Test key used with production or vice versa. |
| `TelebirrError` | API error code | Telebirr API returned a non-zero code. |

```typescript
import { TelebirrError, NetworkError, EnvironmentError } from '@telebirr-sdk/sdk-core';

try {
  await client.payments.charge({ amount: '100', title: 'Order' });
} catch (error) {
  if (error instanceof NetworkError) {
    // Retry or log
  } else if (error instanceof TelebirrError) {
    console.error(error.code, error.message);
  }
}
```

## Environment Guard

The client validates `fabricAppId` prefixes against the selected environment at construction time:

| Key Prefix | Allowed Environment | Error |
|------------|---------------------|-------|
| `sk_test_*` | `SANDBOX` | Throws `EnvironmentError` if used with `PRODUCTION` |
| `sk_live_*` | `PRODUCTION` | Throws `EnvironmentError` if used with `SANDBOX` |

## Base URLs

| Environment | Base URL |
|-------------|----------|
| `SANDBOX` | `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway` |
| `PRODUCTION` | `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway` |

Override with `baseUrl` in `TelebirrConfig` if needed.

## Testing

```bash
npm install
npm test
```

Type-check without emitting:

```bash
npm run lint
```

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
