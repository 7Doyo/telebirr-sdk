# Telebirr Pure Dart CLI Example

A command-line application demonstrating the `telebirr_sdk_core` Dart SDK.

## Setup

```bash
dart pub get
dart run bin/main.dart
```

## Configuration

Set environment variables before running:

```bash
export TELEBIRR_ENVIRONMENT=SANDBOX
export TELEBIRR_FABRIC_APP_ID=your-fabric-app-id
export TELEBIRR_MERCHANT_APP_ID=your-merchant-app-id
export TELEBIRR_MERCHANT_CODE=your-merchant-code
export TELEBIRR_API_KEY=your-api-key
export TELEBIRR_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
export TELEBIRR_SHORT_CODE=220311
export TELEBIRR_TIMEOUT=120m
export TELEBIRR_NOTIFY_URL=https://your-domain.com/webhook
```

## What It Does

1. Prompts for payment amount and title
2. Creates a payment order via `telebirr.payments.charge()`
3. Prints the prepay ID and receive code
4. Builds the receive code using `telebirr.payments.buildReceiveCode()`

## Notes

- All signing and token management is handled internally by the SDK.
- The `receiveCode` format is `TELEBIRR$BUYGOODS{shortCode}{amount}{prepay_id}%{timeout}`.
