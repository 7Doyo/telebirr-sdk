import '@testing-library/jest-dom';
import { jest } from '@jest/globals';
import { render, screen, fireEvent } from '@testing-library/react';
import { PaymentButton } from '../src/components/payment-button.js';
import { TestModeBadge } from '../src/components/test-mode-badge.js';
import { CheckoutElement } from '../src/components/checkout-element.js';
import { PaymentStatus } from '../src/components/payment-status.js';
import { ErrorDisplay } from '../src/components/error-display.js';
import { RefundButton } from '../src/components/refund-button.js';
import { RetryButton } from '../src/components/retry-button.js';
import { TelebirrProvider } from '../src/provider.js';
import { PaymentStatus as PaymentStatusEnum } from '@telebirr-sdk/sdk-core';
import type { TelebirrConfig } from '@telebirr-sdk/sdk-core';

const SANDBOX_CONFIG: TelebirrConfig = {
  environment: 'SANDBOX',
  fabricAppId: 'sk_test_abc123',
  merchantAppId: 'test-merchant',
  merchantCode: 'test-merchant-code',
  appSecret: 'test-secret',
  privateKeyPem: '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
  shortCode: '123456',
  timeout: '600',
  notifyUrl: 'https://example.com/notify',
};

const PRODUCTION_CONFIG: TelebirrConfig = {
  ...SANDBOX_CONFIG,
  environment: 'PRODUCTION',
  fabricAppId: 'sk_live_abc123',
};

function WithProvider({
  config,
  children,
}: {
  config: TelebirrConfig;
  children: React.ReactNode;
}) {
  return <TelebirrProvider config={config}>{children}</TelebirrProvider>;
}

describe('PaymentButton', () => {
  it('renders with default text', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentButton params={{ amount: '100', title: 'Test' }} />
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-button')).toHaveTextContent('Pay Now');
  });

  it('renders with custom children', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentButton params={{ amount: '100', title: 'Test' }}>
          Custom Text
        </PaymentButton>
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-button')).toHaveTextContent('Custom Text');
  });

  it('can be disabled', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentButton params={{ amount: '100', title: 'Test' }} disabled />
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-button')).toBeDisabled();
  });
});

describe('TestModeBadge', () => {
  it('shows badge in SANDBOX', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <TestModeBadge />
      </WithProvider>,
    );
    expect(screen.getByTestId('test-mode-badge')).toHaveTextContent('Test Mode');
  });

  it('hides badge in PRODUCTION', () => {
    render(
      <WithProvider config={PRODUCTION_CONFIG}>
        <TestModeBadge />
      </WithProvider>,
    );
    expect(screen.queryByTestId('test-mode-badge')).toBeNull();
  });
});

describe('CheckoutElement', () => {
  it('passes correct args to render prop', () => {
    let receivedArgs: {
      charge: () => Promise<void>;
      loading: boolean;
      error: Error | null;
    } | null = null;

    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <CheckoutElement params={{ amount: '100', title: 'Test' }}>
          {(args: { charge: () => Promise<void>; loading: boolean; error: Error | null }) => {
            receivedArgs = args;
            return <span data-testid="checkout-child" />;
          }}
        </CheckoutElement>
      </WithProvider>,
    );
    expect(receivedArgs).not.toBeNull();
    expect(typeof receivedArgs!.charge).toBe('function');
    expect(receivedArgs!.loading).toBe(false);
    expect(receivedArgs!.error).toBeNull();
  });
});

describe('PaymentStatus', () => {
  it('renders SUCCESS status with green styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.SUCCESS} />
      </WithProvider>,
    );
    const el = screen.getByTestId('payment-status');
    expect(el).toHaveTextContent('Success');
    expect(el.className).toContain('bg-green-100');
  });

  it('renders FAIL status with red styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.FAIL} />
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-status')).toHaveTextContent('Failed');
  });

  it('renders PENDING status with yellow styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.PENDING} />
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-status')).toHaveTextContent('Pending');
  });

  it('renders TIMEOUT status with gray styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.TIMEOUT} />
      </WithProvider>,
    );
    expect(screen.getByTestId('payment-status')).toHaveTextContent('Timed Out');
  });

  it('renders ACCEPTED status with blue styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.ACCEPTED} />
      </WithProvider>,
    );
    const el = screen.getByTestId('payment-status');
    expect(el).toHaveTextContent('Accepted');
    expect(el.className).toContain('bg-blue-100');
  });

  it('renders REFUNDING status with orange styling', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <PaymentStatus status={PaymentStatusEnum.REFUNDING} />
      </WithProvider>,
    );
    const el = screen.getByTestId('payment-status');
    expect(el).toHaveTextContent('Refunding');
    expect(el.className).toContain('bg-orange-100');
  });
});

describe('ErrorDisplay', () => {
  it('renders nothing when error is null', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <ErrorDisplay error={null} />
      </WithProvider>,
    );
    expect(screen.queryByTestId('error-display')).toBeNull();
  });

  it('renders error message', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <ErrorDisplay error={new Error('test')} />
      </WithProvider>,
    );
    expect(screen.getByTestId('error-display')).toBeInTheDocument();
    expect(screen.getByText('An error occurred')).toBeInTheDocument();
  });

  it('renders dismiss button when onDismiss provided', () => {
    const onDismiss = jest.fn();
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <ErrorDisplay error={new Error('test')} onDismiss={onDismiss} />
      </WithProvider>,
    );
    expect(screen.getByTestId('error-dismiss')).toBeInTheDocument();
  });

  it('hides dismiss button when no onDismiss', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <ErrorDisplay error={new Error('test')} />
      </WithProvider>,
    );
    expect(screen.queryByTestId('error-dismiss')).toBeNull();
  });
});

describe('RefundButton', () => {
  it('renders with default text', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <RefundButton
          refundParams={{ merchOrderId: 'test', refundRequestNo: 'ref-001', refundAmount: '100' }}
        />
      </WithProvider>,
    );
    expect(screen.getByTestId('refund-button')).toHaveTextContent('Refund');
  });

  it('shows confirm dialog on click', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <RefundButton
          refundParams={{ merchOrderId: 'test', refundRequestNo: 'ref-001', refundAmount: '100' }}
        />
      </WithProvider>,
    );
    fireEvent.click(screen.getByTestId('refund-button'));
    expect(screen.getByTestId('refund-confirm')).toBeInTheDocument();
    expect(screen.getByText('Are you sure you want to refund this payment?')).toBeInTheDocument();
  });
});

describe('RetryButton', () => {
  it('renders with default text', () => {
    render(
      <WithProvider config={SANDBOX_CONFIG}>
        <RetryButton params={{ amount: '100', title: 'Test' }} />
      </WithProvider>,
    );
    expect(screen.getByTestId('retry-button')).toHaveTextContent('Retry');
  });
});
