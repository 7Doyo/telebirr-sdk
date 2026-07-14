# telebirr_flutter_elements

<details>
<summary>🚧 <strong>Project Status: In Development</strong></summary>
<br>
This project is currently active and under heavy development. Things are changing rapidly, and not all features are fully functional yet. Check back often for updates!
</details>

Flutter UI components and utilities for the [Telebirr](https://www.telebirr.et/) payment gateway.

This package wraps [`telebirr_sdk_core`](../dart_core/) with ready-to-use Material Design widgets, state management via `ChangeNotifier`, and built-in localization. If you only need the headless API client without UI dependencies, use `telebirr_sdk_core` directly.

## Requirements

- Flutter >= 3.10.0
- Dart SDK >= 3.0.0

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  telebirr_flutter_elements:
    path: ../flutter_wrapper  # local path, or use a hosted version
```

Then run:

```bash
flutter pub get
```

All types from `telebirr_sdk_core` are re-exported through this package, so you do not need to depend on both.

## Quick Start

### 1. Wrap your app in `TelebirrProvider`

```dart
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

void main() {
  final config = TelebirrConfig(
    environment: Environment.sandbox,
    fabricAppId: 'your-fabric-app-id',
    merchantAppId: '12345',
    merchantCode: 'YOUR_MERCHANT_CODE',
    appSecret: 'sk_test_your_secret',
    privateKeyPem: privateKey,
    shortCode: '220311',
    timeout: '120',
    notifyUrl: 'https://your-server.com/webhook',
  );

  final telebirr = Telebirr(config);

  runApp(MyApp(telebirr: telebirr));
}
```

### 2. Use a payment widget

```dart
class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = PaymentNotifier(context.telebirr);

    return PaymentButton(
      notifier: notifier,
      onPressed: () {
        final params = CreateOrderParams(
          amount: '100',
          title: 'Order #1234',
        );
        notifier.charge(params);
      },
    );
  }
}
```

### 3. Add localization delegates

```dart
MaterialApp(
  localizationsDelegates: [
    TelebirrLocalizations.delegate,
    AppLocalizations.delegate,
    // your existing delegates...
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: PaymentPage(),
)
```

## API Reference

### TelebirrProvider

An `InheritedWidget` that makes the `Telebirr` instance available to the widget tree.

```dart
const TelebirrProvider({
  Key? key,
  required Telebirr telebirr,
  required Widget child,
})
```

**Static access:**

```dart
TelebirrProvider.of(context)  // returns Telebirr
```

**Extension access:**

```dart
context.telebirr  // BuildContext extension
```

---

### PaymentNotifier

A `ChangeNotifier` that manages payment state.

```dart
class PaymentNotifier extends ChangeNotifier {
  PaymentNotifier(Telebirr telebirr);
}
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `state` | `PaymentState` | Current state: `idle`, `loading`, `success`, `error` |
| `isLoading` | `bool` | `true` when state is `loading` |
| `errorMessage` | `String?` | Error message if state is `error` |
| `response` | `CreateOrderResponse?` | The response from a successful charge |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| `charge` | `Future<void> charge(CreateOrderParams params)` | Initiates a payment |
| `reset` | `void reset()` | Resets to `idle` state |

---

### RefundNotifier

A `ChangeNotifier` that manages refund state.

```dart
class RefundNotifier extends ChangeNotifier {
  RefundNotifier(Telebirr telebirr);
}
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `state` | `RefundState` | Current state: `idle`, `loading`, `success`, `error` |
| `isLoading` | `bool` | `true` when state is `loading` |
| `errorMessage` | `String?` | Error message if state is `error` |
| `response` | `RefundResponse?` | The response from a successful refund |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| `refund` | `Future<void> refund(RefundParams params)` | Initiates a refund |
| `reset` | `void reset()` | Resets to `idle` state |

---

### RetryNotifier

A `ChangeNotifier` that wraps `PaymentNotifier` with automatic retry and exponential backoff.

```dart
class RetryNotifier extends ChangeNotifier {
  RetryNotifier(
    PaymentNotifier paymentNotifier, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  });
}
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `state` | `RetryState` | Current state: `idle`, `loading`, `success`, `error` |
| `isLoading` | `bool` | `true` when state is `loading` |
| `errorMessage` | `String?` | Error message after all retries are exhausted |
| `attempt` | `int` | Current retry attempt number |

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| `chargeWithRetry` | `Future<void> chargeWithRetry(CreateOrderParams params)` | Retries `charge` up to `maxRetries` times |
| `reset` | `void reset()` | Resets retry state and the underlying `PaymentNotifier` |

---

### Widgets

#### PaymentButton

An `ElevatedButton` that disables itself and shows a loading spinner while payment is in progress.

```dart
const PaymentButton({
  Key? key,
  required PaymentNotifier notifier,
  required VoidCallback onPressed,
  String? label,  // defaults to localized "Pay Now"
})
```

#### PaymentCardForm

A Material `Card` that displays order title, amount, and a pay button. Automatically handles loading and error states from the notifier.

```dart
const PaymentCardForm({
  Key? key,
  required PaymentNotifier notifier,
  required String title,
  required String amount,
  String currency = 'ETB',
  VoidCallback? onSuccess,  // called when payment succeeds
})
```

#### PaymentStatusChip

A color-coded chip that displays a `PaymentStatus` value with a localized label.

```dart
const PaymentStatusChip({
  Key? key,
  required PaymentStatus status,
})
```

Colors are mapped as follows:

| Status | Background | Text |
|--------|-----------|------|
| `SUCCESS` | Green | Dark green |
| `FAIL` | Red | Dark red |
| `TIMEOUT` | Gray | Dark gray |
| `PENDING` | Yellow | Dark yellow |
| `ACCEPTED` | Blue | Dark blue |
| `REFUNDING` | Green | Dark green |
| `REFUND_SUCCESS` | Green | Dark green |
| `REFUND_FAILED` | Red | Dark red |

#### ErrorDisplay

Displays an error message in a dismissible banner with an icon. Renders nothing when `errorMessage` is `null`.

```dart
const ErrorDisplay({
  Key? key,
  String? errorMessage,
  VoidCallback? onDismiss,  // if provided, shows a close button
})
```

#### RefundButton

A self-contained refund flow: shows a confirm button, confirmation dialog, loading spinner, and success/error states. Manages its own `RefundNotifier` internally.

```dart
const RefundButton({
  Key? key,
  required Telebirr telebirr,
  required String merchOrderId,
  required String refundAmount,
  String? refundReason,
  VoidCallback? onSuccess,
  VoidCallback? onError,
})
```

#### RetryButton

An `ElevatedButton` with a loading spinner, designed for use with `RetryNotifier`.

```dart
const RetryButton({
  Key? key,
  required VoidCallback onPressed,
  String? label,  // defaults to localized "Retry"
  bool loading = false,
})
```

#### TestModeBadge

Displays a yellow "Test Mode" badge when running in sandbox. Renders nothing when `environment` is `Environment.production`.

```dart
const TestModeBadge({
  Key? key,
  required Environment environment,
})
```

## Localization

The package includes built-in translations for five locales:

| Locale | Language |
|--------|----------|
| `en` | English |
| `am` | Amharic |
| `om` | Oromo |
| `ti` | Tigrinya |
| `ar` | Arabic |

All strings are embedded in the binary at compile time -- no runtime file I/O is needed.

### Using TelebirrLocalizations

```dart
final l10n = TelebirrLocalizations.of(context);
Text(l10n.payNow)
```

### Custom translations

Pass a `TelebirrLocalizationsDelegate` with overrides to `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    TelebirrLocalizationsDelegate(
      customTranslations: {
        'en': {'payNow': 'Complete Payment'},
      },
    ),
    AppLocalizations.delegate,
  ],
)
```

### MaterialLocalizations subclasses

The package provides `MaterialLocalizations` implementations for Amharic, Oromo, and Tigrinya, which are not included in Flutter by default. Add their delegates to enable full Material widget localization for these locales:

```dart
MaterialApp(
  localizationsDelegates: [
    TelebirrLocalizations.delegate,
    AppLocalizations.delegate,
    AmMaterialLocalizations.delegate,
    OmMaterialLocalizations.delegate,
    TiMaterialLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
)
```

## RTL Support

Arabic (`ar`) is fully supported. The `TelebirrLocalizations.isRtl` getter returns `true` for Arabic locales, and all widgets use `EdgeInsetsDirectional` and directional layout primitives to render correctly in both LTR and RTL directions.

## Utilities

### formatAmount

Formats a payment amount with its currency code.

```dart
String formatAmount(String amount, {String currency = 'ETB'})
// formatAmount('100')           => '100 ETB'
// formatAmount('50', currency: 'USD') => '50 USD'
```

## Testing

Run all tests:

```bash
flutter test
```

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
