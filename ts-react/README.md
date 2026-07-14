# @telebirr-sdk/react-elements

<details>
<summary>🚧 <strong>Project Status: In Development</strong></summary>
<br>
This project is currently active and under heavy development. Things are changing rapidly, and not all features are fully functional yet. Check back often for updates!
</details>

React 19 UI components and hooks for the [Telebirr](https://developerportal.ethiotelebirr.et) payment gateway.

Wraps [`@telebirr-sdk/sdk-core`](../ts-core/) with React context, hooks, and ready-to-use components. All components are client-rendered (`'use client'`) and ship with built-in i18n support for five languages.

## Installation

```bash
npm install @telebirr-sdk/react-elements @telebirr-sdk/sdk-core
```

**Peer dependencies:**

| Package | Version |
|---------|---------|
| `react` | `>=19` |
| `@telebirr-sdk/sdk-core` | latest |

`@telebirr-sdk/react-elements` also depends on `i18next` and `react-i18next`, which are installed automatically.

## Quick Start

### 1. Wrap your app in `TelebirrProvider`

```tsx
import { TelebirrProvider } from '@telebirr-sdk/react-elements';

function App() {
  return (
    <TelebirrProvider
      config={{
        environment: 'SANDBOX',
        fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
        merchantAppId: '12345',
        merchantCode: 'TEST_MERCHANT',
        appSecret: 'sk_test_xxx',
        privateKeyPem: '-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://your-domain.com/webhook',
      }}
    >
      <CheckoutPage />
    </TelebirrProvider>
  );
}
```

### 2. Use the `usePayment` hook

```tsx
import { usePayment, PaymentButton, ErrorDisplay } from '@telebirr-sdk/react-elements';

function CheckoutPage() {
  const { charge, loading, error, data, reset } = usePayment();

  const handlePay = async () => {
    const result = await charge({
      amount: '100',
      title: 'Premium Subscription',
    });
    console.log('prepay_id:', result.prepayId);
  };

  return (
    <div>
      <PaymentButton
        params={{ amount: '100', title: 'Premium Subscription' }}
        onSuccess={(res) => console.log('Paid!', res.prepayId)}
        onError={(err) => console.error(err.message)}
      />
      <ErrorDisplay error={error} onDismiss={reset} />
    </div>
  );
}
```

### 3. Render a status badge

```tsx
import { TestModeBadge, PaymentStatus } from '@telebirr-sdk/react-elements';

function Header() {
  return (
    <header>
      <TestModeBadge />
      <PaymentStatus status="SUCCESS" />
    </header>
  );
}
```

## Provider API

### `<TelebirrProvider>`

Context provider that must wrap any component using Telebirr hooks or components.

```tsx
<TelebirrProvider config={config} translations={translations}>
  {children}
</TelebirrProvider>
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `config` | `TelebirrConfig` | Yes | SDK configuration (environment, credentials, merchant details). See [`@telebirr-sdk/sdk-core` docs](../ts-core/README.md) for the full shape. |
| `children` | `ReactNode` | Yes | Application tree. |
| `translations` | `Record<string, TelebirrTranslations>` | No | Custom translation overrides keyed by locale code. Merged on top of built-in translations. |

#### Context Value

Accessible via `useTelebirr()`:

| Field | Type | Description |
|-------|------|-------------|
| `client` | `Telebirr` | Instantiated SDK client. |
| `config` | `TelebirrConfig` | The config passed to the provider. |

## Hooks API

### `useTelebirr()`

Access the Telebirr client and configuration from context.

```tsx
const { client, config } = useTelebirr();
```

| Return | Type | Description |
|--------|------|-------------|
| `client` | `Telebirr` | The SDK client instance. |
| `config` | `TelebirrConfig` | Current configuration. |

Throws if used outside a `<TelebirrProvider>`.

---

### `usePayment()`

Manage a single payment charge with automatic state tracking.

```tsx
const { charge, loading, error, data, reset } = usePayment();
```

**Parameters:** None.

| Return | Type | Description |
|--------|------|-------------|
| `charge` | `(params: CreateOrderParams) => Promise<CreateOrderResponse>` | Initiates a payment. Sets `loading` to `true` while in flight. |
| `loading` | `boolean` | `true` while a charge request is in progress. |
| `error` | `Error \| null` | The last error thrown by `charge`, if any. |
| `data` | `CreateOrderResponse \| null` | The response from the last successful charge. |
| `reset` | `() => void` | Clears `error` and `data`. |

---

### `useRefund()`

Process a refund with the same loading/error/data pattern.

```tsx
const { refund, loading, error, data, reset } = useRefund();
```

**Parameters:** None.

| Return | Type | Description |
|--------|------|-------------|
| `refund` | `(params: RefundParams) => Promise<RefundResponse>` | Initiates a refund. |
| `loading` | `boolean` | `true` while a refund request is in progress. |
| `error` | `Error \| null` | The last error thrown by `refund`, if any. |
| `data` | `RefundResponse \| null` | The response from the last successful refund. |
| `reset` | `() => void` | Clears `error` and `data`. |

---

### `useWebhook()`

Verify incoming webhook notification signatures.

```tsx
const { verify, lastResult, lastPayload } = useWebhook();
```

**Parameters:** None.

| Return | Type | Description |
|--------|------|-------------|
| `verify` | `(payload: NotificationPayload) => boolean` | Verifies the webhook signature against the private key. Returns `true` if valid. |
| `lastResult` | `boolean \| null` | The result of the last `verify()` call. |
| `lastPayload` | `NotificationPayload \| null` | The payload from the last `verify()` call. |

---

### `useRetry()`

Charge with exponential backoff retry logic. Provides live countdown and cancellation.

```tsx
const {
  chargeWithRetry, loading, error, data,
  attempt, maxAttempts, countdown, isRetrying,
  cancel, reset,
} = useRetry();
```

**Parameters:** None. Configuration is passed per-call via `RetryConfig`.

#### `RetryConfig`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `maxAttempts` | `number` | `3` | Maximum number of charge attempts. |
| `baseDelayMs` | `number` | `1000` | Base delay in ms between retries (doubles each attempt). |
| `maxDelayMs` | `number` | `30000` | Maximum delay cap in ms. |

| Return | Type | Description |
|--------|------|-------------|
| `chargeWithRetry` | `(params: CreateOrderParams, config?: RetryConfig) => Promise<CreateOrderResponse>` | Charges with automatic retries. |
| `loading` | `boolean` | `true` during any attempt or countdown. |
| `error` | `Error \| null` | The last error if all attempts fail. |
| `data` | `CreateOrderResponse \| null` | The response from a successful charge. |
| `attempt` | `number` | The current attempt number (1-indexed). |
| `maxAttempts` | `number` | The configured maximum attempts. |
| `countdown` | `number` | Seconds remaining until the next retry attempt. |
| `isRetrying` | `boolean` | `true` while waiting between retry attempts. |
| `cancel` | `() => void` | Cancels the current retry cycle. |
| `reset` | `() => void` | Clears all state. |

## Components API

### `<CheckoutElement>`

Render prop component for building custom checkout UIs. Exposes `charge`, `loading`, and `error` to the child function.

```tsx
<CheckoutElement
  params={{ amount: '100', title: 'My Product' }}
  onSuccess={(res) => console.log(res)}
  onError={(err) => console.error(err)}
>
  {({ charge, loading, error }) => (
    <button onClick={charge} disabled={loading}>
      {loading ? 'Processing...' : 'Pay Now'}
    </button>
  )}
</CheckoutElement>
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `params` | `CreateOrderParams` | Yes | Payment parameters (amount, title, etc.). |
| `onSuccess` | `(response: CreateOrderResponse) => void` | No | Called after a successful charge. |
| `onError` | `(error: Error) => void` | No | Called when the charge fails. |
| `children` | `(args: { charge, loading, error }) => ReactNode` | Yes | Render function receiving charge controls. |

---

### `<PaymentButton>`

Ready-to-use pay button with loading state and i18n labels.

```tsx
<PaymentButton
  params={{ amount: '100', title: 'My Product' }}
  onSuccess={(res) => console.log('Paid!')}
  onError={(err) => console.error(err)}
  className="my-custom-class"
>
  Buy for 100 ETB
</PaymentButton>
```

#### Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `params` | `CreateOrderParams` | Yes | -- | Payment parameters. |
| `onSuccess` | `(response: CreateOrderResponse) => void` | No | -- | Called after a successful charge. |
| `onError` | `(error: Error) => void` | No | -- | Called when the charge fails. |
| `disabled` | `boolean` | No | `false` | Disables the button. |
| `className` | `string` | No | `''` | Additional CSS classes. |
| `children` | `ReactNode` | No | `t('payNow')` | Button label. Defaults to translated "Pay Now". |

While loading, the button text switches to the translated "Processing..." label and the button is disabled.

---

### `<PaymentStatus>`

Displays a color-coded payment status badge.

```tsx
<PaymentStatus status="SUCCESS" />
<PaymentStatus status="REFUNDING" className="my-class" />
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `status` | `PaymentStatus` | Yes | The current payment status enum value. |
| `className` | `string` | No | Additional CSS classes. |

#### Status Colors

| Status | Color |
|--------|-------|
| `SUCCESS` | Green |
| `FAIL` | Red |
| `TIMEOUT` | Gray |
| `PENDING` | Yellow |
| `ACCEPTED` | Blue |
| `REFUNDING` | Orange |
| `REFUND_SUCCESS` | Emerald |
| `REFUND_FAILED` | Red |

---

### `<TestModeBadge>`

Displays a yellow "Test Mode" badge when running in the SANDBOX environment. Renders nothing in PRODUCTION.

```tsx
<TestModeBadge />
<TestModeBadge className="absolute top-2 right-2" />
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `className` | `string` | No | Additional CSS classes. |

---

### `<ErrorDisplay>`

Renders an error message with a dismiss button. Maps error names to localized messages automatically.

```tsx
<ErrorDisplay error={error} onDismiss={reset} />
```

#### Error Name Mapping

| `error.name` | Translation Key |
|---------------|----------------|
| `NetworkError` | `errorNetwork` |
| `TimeoutError` | `errorTimeout` |
| `EnvironmentError` | `errorAuth` |
| `ValidationError` | `errorValidation` |
| (anything else) | `errorGeneric` |

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `error` | `Error \| null` | Yes | The error to display. Renders nothing when `null`. |
| `onDismiss` | `() => void` | No | Called when the dismiss button is clicked. When provided, a dismiss button is rendered. |
| `className` | `string` | No | Additional CSS classes. |

---

### `<RefundButton>`

A refund button with a built-in confirmation step.

```tsx
<RefundButton
  refundParams={{
    merchOrderId: 'order-123',
    refundRequestNo: 'refund-456',
    refundAmount: '100',
    refundReason: 'Customer request',
  }}
  onSuccess={() => console.log('Refunded')}
  onError={(err) => console.error(err)}
/>
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `refundParams` | `{ merchOrderId: string; refundRequestNo: string; refundAmount: string; refundReason?: string }` | Yes | Refund parameters. |
| `onSuccess` | `() => void` | No | Called after a successful refund. |
| `onError` | `(error: Error) => void` | No | Called when the refund fails. |
| `disabled` | `boolean` | No | Disables the button. |
| `className` | `string` | No | Additional CSS classes. |
| `children` | `ReactNode` | No | Button label. Defaults to translated "Refund". |

The component renders a confirmation prompt before executing the refund. The user must confirm the action.

---

### `<RetryButton>`

A button that retries a failed payment with exponential backoff. Displays a live countdown between attempts.

```tsx
<RetryButton
  params={{ amount: '100', title: 'My Product' }}
  retryConfig={{ maxAttempts: 5, baseDelayMs: 2000 }}
  onSuccess={(res) => console.log('Paid!', res)}
  onError={(err) => console.error(err)}
>
  Try Again
</RetryButton>
```

#### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `params` | `CreateOrderParams` | Yes | Payment parameters. |
| `retryConfig` | `{ maxAttempts?: number; baseDelayMs?: number; maxDelayMs?: number }` | No | Retry configuration. Defaults to 3 attempts, 1s base, 30s max delay. |
| `onSuccess` | `(response: CreateOrderResponse) => void` | No | Called after a successful charge. |
| `onError` | `(error: Error) => void` | No | Called when all retry attempts are exhausted. |
| `className` | `string` | No | Additional CSS classes. |
| `children` | `ReactNode` | No | Button label. Defaults to translated "Retry". |

During retries, the button is replaced by a countdown display showing seconds remaining and a cancel link.

## Internationalization

All user-facing strings are translated via `i18next` under the `telebirr` namespace. Built-in languages:

| Code | Language |
|------|----------|
| `en` | English (default) |
| `am` | Amharic |
| `om` | Oromo |
| `ti` | Tigrinya |
| `ar` | Arabic |

### Custom Translations

Override or extend any locale by passing a `translations` map to the provider:

```tsx
<TelebirrProvider
  config={config}
  translations={{
    en: { payNow: 'Complete Payment' },
    fr: { payNow: 'Payer', processing: 'Traitement...' },
  }}
>
  {children}
</TelebirrProvider>
```

Custom translations are merged on top of the built-in strings for each locale. Adding a locale that does not exist in the built-in set (e.g. `fr`) will create it entirely from your custom strings.

### Standalone i18n Instance

If you need to initialize translations outside of the provider (e.g. for SSR or testing), use the `createTelebirrI18n` factory:

```tsx
import { createTelebirrI18n } from '@telebirr-sdk/react-elements';

const i18n = createTelebirrI18n({
  en: { payNow: 'Pay' },
});

// Use the returned i18next instance directly
i18n.t('payNow'); // "Pay"
```

A pre-built singleton is also exported as `telebirrI18n`:

```tsx
import { telebirrI18n } from '@telebirr-sdk/react-elements';

telebirrI18n.t('processing'); // "Processing..."
```

### Translation Keys

| Key | English Value |
|-----|---------------|
| `payNow` | Pay Now |
| `processing` | Processing... |
| `testMode` | Test Mode |
| `statusSuccess` | Success |
| `statusFail` | Failed |
| `statusTimeout` | Timed Out |
| `statusPending` | Pending |
| `statusAccepted` | Accepted |
| `statusRefunding` | Refunding |
| `statusRefundSuccess` | Refund Success |
| `statusRefundFailed` | Refund Failed |
| `refund` | Refund |
| `refundConfirm` | Are you sure you want to refund this payment? |
| `refundProcessing` | Processing refund... |
| `refundSuccess` | Refund completed successfully |
| `refundFailed` | Refund failed |
| `retry` | Retry |
| `retryCountdown` | Retrying in {{seconds}}s... |
| `retryFailed` | All retry attempts failed |
| `errorGeneric` | An error occurred |
| `errorNetwork` | Network error. Please check your connection. |
| `errorTimeout` | Request timed out. Please try again. |
| `errorAuth` | Authentication failed. Please check your credentials. |
| `errorValidation` | Invalid payment parameters. |
| `errorDismiss` | Dismiss |
| `webhookVerificationFailed` | Webhook signature verification failed |

## Re-exports

Everything from `@telebirr-sdk/sdk-core` is re-exported, so you can import types and utilities directly:

```tsx
import {
  Telebirr,
  PaymentStatus,
  buildReceiveCode,
  type CreateOrderParams,
  type TelebirrConfig,
} from '@telebirr-sdk/react-elements';
```

## Testing

```bash
npm run build
npm test
npm run lint
```

The test suite uses Jest with `@testing-library/react` and `jest-environment-jsdom`. The `typecheck` script (`tsc --noEmit`) is run separately via `npm run lint`.

## Support

If you find this SDK useful, consider supporting the author via Telebirr:

**Telebirr:** [+251 96 563 1263](tel:+251965631263)

**Security issues:** Report privately to [asasahegn17@gmail.com](mailto:asasahegn17@gmail.com)

## License

MIT — Copyright (c) Asasahegn Alemayehu
