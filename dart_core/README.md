# telebirr_sdk_core

Headless Dart SDK for the Ethio Telecom Telebirr payment gateway. Zero UI dependencies -- build your own integration on top of a clean, typed API.

## Features

- Create, query, and refund payment orders
- SHA256withRSA-PSS request signing (32-byte salt) via the `cryptography` package
- Automatic token caching with configurable TTL
- Idempotency key generation to prevent duplicate orders
- Retry with exponential backoff for transient failures
- Webhook notification verification and status parsing
- Receive code builder for prepay flows
- Environment guard that rejects mismatched key/environment combinations
- Type-safe models and enums for all Telebirr API concepts

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  telebirr_sdk_core: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

void main() async {
  final telebirr = Telebirr(TelebirrConfig(
    environment: Environment.sandbox,
    fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
    merchantAppId: '12345',
    merchantCode: 'TEST_MERCHANT',
    appSecret: 'sk_test_xxx',
    privateKeyPem: privateKey, // PKCS#8 PEM string
    shortCode: '220311',
    timeout: '120m',
    notifyUrl: 'https://your-server.com/webhook',
  ));

  // Create an order
  final order = await telebirr.payments.charge(CreateOrderParams(
    amount: '100',
    title: 'Test Order',
  ));

  print('Prepay ID: ${order.prepayId}');
  print('Receive code: ${order.receiveCode}');

  // Query the order
  final status = await telebirr.payments.query(QueryOrderParams(
    merchOrderId: 'order-id-from-charge',
  ));

  print('Status: ${status.status}'); // PaymentStatus.success, etc.
}
```

## API Reference

### Telebirr

The top-level client. Validates the environment/key combination on construction.

```dart
final telebirr = Telebirr(config);
```

| Property  | Type     | Description                          |
| --------- | -------- | ------------------------------------ |
| `payments` | `Payments` | Access to payment operations.      |

### TelebirrConfig

| Field           | Type          | Required | Description                                                    |
| --------------- | ------------- | -------- | -------------------------------------------------------------- |
| `environment`   | `Environment` | Yes      | `Environment.sandbox` or `Environment.production`.             |
| `fabricAppId`   | `String`      | Yes      | UUID-format app ID from the Telebirr developer portal.         |
| `merchantAppId` | `String`      | Yes      | Numeric merchant application ID.                               |
| `merchantCode`  | `String`      | Yes      | Merchant code.                                                 |
| `appSecret`     | `String`      | Yes      | API secret (appSecret). Prefixed `sk_test_` or `sk_live_`.    |
| `privateKeyPem` | `String`      | Yes      | PKCS#8 PEM-formatted RSA private key for request signing.      |
| `shortCode`     | `String`      | Yes      | Payee short code (e.g. `220311`).                              |
| `timeout`       | `String`      | Yes      | Order timeout expression (e.g. `120m`).                        |
| `notifyUrl`     | `String`      | Yes      | Webhook callback URL.                                          |
| `baseUrl`       | `String`      | No       | Override the default base URL for the target environment.      |

**Effective base URLs:**

| Environment  | Base URL                                                                       |
| ------------ | ------------------------------------------------------------------------------ |
| SANDBOX      | `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway`    |
| PRODUCTION   | `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway` |

### Payments

Accessed via `telebirr.payments`. Handles token management, request signing, and HTTP calls internally.

#### `charge(CreateOrderParams, {TradeType tradeType})`

Creates a payment order. Returns a `CreateOrderResponse`.

| Parameter | Type               | Required | Description                      |
| --------- | ------------------ | -------- | -------------------------------- |
| `amount`  | `String`           | Yes      | Amount in ETB (e.g. `"100"`).    |
| `title`   | `String`           | Yes      | Order title / description.       |
| `orderId` | `String?`          | No       | Custom order ID. Auto-generated if omitted. |
| `redirectUrl` | `String?`      | No       | Redirect URL after payment.      |
| `callbackInfo` | `String?`     | No       | Arbitrary callback metadata.     |

Optional `tradeType` parameter (defaults to `TradeType.inApp`).

**CreateOrderResponse:**

| Field         | Type                          | Description                |
| ------------- | ----------------------------- | -------------------------- |
| `code`        | `String`                      | Response code (`"0"` = success). |
| `message`     | `String?`                     | Error message if any.      |
| `prepayId`    | `String`                      | Prepay ID for the order.   |
| `receiveCode` | `String`                      | Formatted receive code.    |
| `rawResponse` | `Map<String, dynamic>`        | Full API response body.    |

#### `query(QueryOrderParams)`

Queries the status of an existing order. Returns a `QueryOrderResponse`.

| Field           | Type               | Required | Description            |
| --------------- | ------------------ | -------- | ---------------------- |
| `merchOrderId`  | `String`           | Yes      | Original order ID.     |

**QueryOrderResponse:**

| Field         | Type                          | Description                   |
| ------------- | ----------------------------- | ----------------------------- |
| `code`        | `String`                      | Response code.                |
| `status`      | `PaymentStatus`               | Parsed payment status enum.   |
| `rawResponse` | `Map<String, dynamic>`        | Full API response body.       |

#### `refund(RefundParams)`

Refunds a completed order. Returns a `RefundResponse`.

| Field              | Type       | Required | Description                  |
| ------------------ | ---------- | -------- | ---------------------------- |
| `merchOrderId`     | `String`   | Yes      | Original order ID.           |
| `refundRequestNo`  | `String`   | Yes      | Unique refund request ID.    |
| `refundAmount`     | `String`   | Yes      | Refund amount in ETB.        |
| `refundReason`     | `String?`  | No       | Reason for the refund.       |

**RefundResponse:**

| Field           | Type                          | Description                    |
| --------------- | ----------------------------- | ------------------------------ |
| `code`          | `String`                      | Response code.                 |
| `message`       | `String?`                     | Error message if any.          |
| `refundOrderId` | `String?`                     | Refund order ID.              |
| `refundStatus`  | `String?`                     | Refund status string.         |
| `rawResponse`   | `Map<String, dynamic>`        | Full API response body.       |

#### `buildReceiveCodeForPrepayId(String prepayId)`

Builds a receive code string for a known prepay ID using the configured short code and timeout.

### Enums

#### `PaymentStatus`

Unified payment status across query and webhook responses.

| Value            | Description                                      |
| ---------------- | ------------------------------------------------ |
| `success`        | Payment completed successfully.                  |
| `fail`           | Payment failed.                                  |
| `timeout`        | Order expired or was closed.                     |
| `pending`        | Awaiting payment or payment in progress.         |
| `accepted`       | Order accepted, awaiting processing.             |
| `refunding`      | Refund in progress.                              |
| `refundSuccess`  | Refund completed.                                |
| `refundFailed`   | Refund failed.                                   |

#### `TradeType`

| Value          | Wire value    | Description                    |
| -------------- | ------------- | ------------------------------ |
| `inApp`        | `InApp`       | In-app payment (mobile SDK).   |
| `crossApp`     | `Cross-App`   | Cross-app payment.             |
| `webCheckout`  | `WebCheckout` | Web checkout flow.             |
| `pwa`          | `PWA`         | Progressive Web App payment.   |
| `qrCode`       | `QrCode`      | QR code scan payment.          |
| `quickPay`     | `QuickPay`    | Quick pay flow.                |
| `bankTrade`    | `BankTrade`   | Bank trade payment.            |

#### `Environment`

| Value          | Description                     |
| -------------- | ------------------------------- |
| `sandbox`      | Sandbox / testing environment.  |
| `production`   | Production environment.         |

#### `NotificationTradeStatus`

Webhook-specific trade status values (camelCase from the API).

| Value       | Wire value  | Maps to           |
| ----------- | ----------- | ----------------- |
| `paying`    | `Paying`    | `PaymentStatus.pending` |
| `expired`   | `Expired`   | `PaymentStatus.pending` |
| `pending`   | `Pending`   | `PaymentStatus.pending` |
| `completed` | `Completed` | `PaymentStatus.success` |
| `failure`   | `Failure`   | `PaymentStatus.fail`    |

### Webhooks

The SDK provides helpers for parsing and verifying incoming webhook notifications.

```dart
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

// Parse the raw webhook body into a typed payload
final payload = NotificationPayload(webhookBodyMap);

// Access fields
print(payload.merchOrderId);
print(payload.tradeStatus);
print(payload.totalAmount);

// Parse trade status into the enum
final status = parseNotificationTradeStatus('Completed');
// status == NotificationTradeStatus.completed

// Build the sign string for external verification
final signString = buildNotificationSignString(webhookBodyMap);

// Verify signature (requires the public key PEM)
final valid = verifyNotification(payload, publicKeyPem);
```

### Receive Code

The receive code encodes payment details for QR code or deeplink flows:

```
TELEBIRR$BUYGOODS{shortCode}{amount}{prepayId}%{timeout}
```

Example: `TELEBIRR$BUYGOODS220311100PREPAY123%120m`

Use `buildReceiveCodeForPrepayId` to construct it from a known prepay ID, or `buildReceiveCode` directly for full control.

### Token Caching

Tokens are cached in memory with a default 50-minute TTL. A fresh token is requested automatically when the cached one expires. Pass a custom TTL via `TokenCache(ttl: Duration(...))` if needed.

### Retry with Exponential Backoff

Wrap any async operation with the `withRetry` utility:

```dart
final result = await withRetry(
  () => telebirr.payments.charge(params),
  config: RetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(milliseconds: 10000),
    retryOn: (error) => error is NetworkException,
  ),
);
```

### Idempotency

Generate a deterministic idempotency key from an order ID:

```dart
final key = generateIdempotencyKey('my-order-123');
// SHA-256 hash of the order ID, uppercased
```

## Error Handling

The SDK throws typed exceptions that extend `TelebirrException`:

```dart
try {
  await telebirr.payments.charge(params);
} on ValidationException catch (e) {
  print('Validation error: ${e.message} (code: ${e.code})');
} on SigningException catch (e) {
  print('Signing error: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on EnvironmentException catch (e) {
  print('Environment mismatch: ${e.message}');
} on TelebirrException catch (e) {
  print('Telebirr API error: ${e.message} (code: ${e.code})');
}
```

| Exception            | Code          | Cause                                      |
| -------------------- | ------------- | ------------------------------------------ |
| `ValidationException` | `VALIDATION` | Invalid input parameters.                  |
| `SigningException`    | `SIGNING`    | RSA-PSS signing failure.                   |
| `NetworkException`    | `NETWORK`    | HTTP errors or token request failures.     |
| `EnvironmentException` | `ENVIRONMENT` | Key prefixed `sk_test_` used in production or vice versa. |
| `TelebirrException`   | `UNKNOWN`    | API returned a non-zero code or other errors. |

## Testing

```bash
dart test
```

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
