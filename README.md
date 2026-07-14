# Telebirr SDK

<details>
<summary>🚧 <strong>Project Status: In Development</strong></summary>
<br>
This project is currently active and under heavy development. Things are changing rapidly, and not all features are fully functional yet. Check back often for updates!
</details>

A multi-language payment SDK for Ethio Telecom's Telebirr payment gateway. Provides headless core libraries and optional UI wrappers for TypeScript, Dart, PHP, React, Flutter, and Laravel.

## Packages

| Package | Path | Registry | Description |
|---------|------|----------|-------------|
| TS Core | `ts-core/` | npm: `@telebirr-sdk/sdk-core` | Headless TypeScript SDK |
| Dart Core | `dart_core/` | pub.dev: `telebirr_sdk_core` | Headless Dart SDK |
| PHP Core | `php-core/` | packagist: `telebirr/sdk-core` | Headless PHP SDK |
| React Elements | `ts-react/` | npm: `@telebirr-sdk/react-elements` | React 19 UI components |
| Flutter Elements | `flutter_wrapper/` | pub.dev: `telebirr_flutter_elements` | Flutter widgets |
| Laravel Bridge | `laravel-bridge/` | packagist: `telebirr/laravel-bridge` | Laravel integration |

## Architecture

The SDK follows a three-layer architecture:

```
CI/CD (GitHub Actions)
    |
    v
Wrapper Layer (React Elements, Flutter Elements, Laravel Bridge)
    |
    v
Core Layer (TS Core, Dart Core, PHP Core)
```

- **Core Layer** -- Headless SDKs with zero external runtime dependencies. Handle authentication, signing, order creation, order queries, refunds, and webhook verification. All core packages expose a uniform API: `sdk.payments.charge()`.
- **Wrapper Layer** -- Optional UI components and framework integrations built on top of the core SDKs. Provide pre-built payment forms, status indicators, and platform-specific helpers.
- **CI/CD Layer** -- GitHub Actions workflows for building, testing, and publishing each package independently.

## Quick Start

### TypeScript

```bash
npm install @telebirr-sdk/sdk-core
```

```typescript
import { TelebirrSDK } from '@telebirr-sdk/sdk-core';

const sdk = new TelebirrSDK({
  environment: 'SANDBOX',
  fabricAppId: 'your-fabric-app-id',
  merchantAppId: 'your-merchant-app-id',
  merchantCode: 'your-merchant-code',
  appSecret: 'your-app-secret',
  privateKey: 'your-pkcs8-pem-private-key',
});

const result = await sdk.payments.charge({
  amount: '100',
  title: 'Order Payment',
  notifyUrl: 'https://your-server.com/webhook',
});
```

### Dart

```bash
dart add telebirr_sdk_core
```

```dart
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

final sdk = TelebirrSDK(
  environment: Environment.sandbox,
  fabricAppId: 'your-fabric-app-id',
  merchantAppId: 'your-merchant-app-id',
  merchantCode: 'your-merchant-code',
  appSecret: 'your-app-secret',
  privateKey: 'your-pkcs8-pem-private-key',
);

final result = await sdk.payments.charge(
  amount: '100',
  title: 'Order Payment',
  notifyUrl: 'https://your-server.com/webhook',
);
```

### PHP

```bash
composer require telebirr/sdk-core
```

```php
use Telebirr\SDKCore\TelebirrSDK;

$sdk = new TelebirrSDK([
    'environment'      => 'SANDBOX',
    'fabric_app_id'    => 'your-fabric-app-id',
    'merchant_app_id'  => 'your-merchant-app-id',
    'merchant_code'    => 'your-merchant-code',
    'app_secret'       => 'your-app-secret',
    'private_key'      => 'your-pkcs8-pem-private-key',
]);

$result = $sdk->payments()->charge([
    'amount'      => '100',
    'title'       => 'Order Payment',
    'notify_url'  => 'https://your-server.com/webhook',
]);
```

### React

```bash
npm install @telebirr-sdk/react-elements
```

```tsx
import { PaymentButton } from '@telebirr-sdk/react-elements';

function Checkout() {
  return (
    <PaymentButton
      amount="100"
      title="Order Payment"
      onSuccess={(result) => console.log('Payment successful', result)}
    />
  );
}
```

### Flutter

```bash
flutter pub add telebirr_flutter_elements
```

```dart
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

// Use TelebirrPaymentButton or other widgets
```

### Laravel

```bash
composer require telebirr/laravel-bridge
```

```php
// Publish config
php artisan vendor:publish --tag=telebirr-config

// Use the facade
use Telebirr\LaravelBridge\Facades\Telebirr;

$result = Telebirr::charge([
    'amount'     => '100',
    'title'      => 'Order Payment',
    'notify_url' => 'https://your-server.com/webhook',
]);
```

## Environments

| Environment | Base URL |
|-------------|----------|
| SANDBOX | `https://developerportal.ethiotelebirr.et:38443/apiaccess/payment/gateway` |
| PRODUCTION | `https://telebirrappcube.ethiomobilemoney.et:38443/apiaccess/payment/gateway` |

All core SDKs accept an `environment` parameter that selects the appropriate base URL. The SDK also enforces key-environment matching:

- Keys starting with `sk_test_` are only allowed in SANDBOX.
- Keys starting with `sk_live_` are only allowed in PRODUCTION.

## Localization

The SDK supports 5 locales for payment interfaces:

| Code | Language |
|------|----------|
| `en` | English |
| `am` | Amharic |
| `om` | Oromo |
| `ti` | Tigrinya |
| `ar` | Arabic |

## Testing

### TypeScript

```bash
cd ts-core && npm install && npm test
cd ts-react && npm install && npm test
```

### Dart

```bash
cd dart_core && dart pub get && dart test
```

### PHP

```bash
cd php-core && composer install && vendor/bin/phpunit
cd laravel-bridge && composer install && vendor/bin/phpunit
```

### Flutter

```bash
cd flutter_wrapper && flutter test
```

## CI/CD Workflows

Three GitHub Actions workflows run tests and builds for each language stack:

| Workflow | Packages | Runtime Versions |
|----------|----------|-----------------|
| `typescript.yml` | ts-core, ts-react | Node 18, 20 |
| `dart.yml` | dart_core, flutter_wrapper | Dart stable |
| `php.yml` | php-core, laravel-bridge | PHP 8.1, 8.2, 8.3 |

## Requirements

| Language | Minimum Version |
|----------|----------------|
| TypeScript/Node.js | >= 18 |
| PHP | >= 8.1 |
| Dart | >= 3.0 |
| Flutter | >= 3.10 |

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
