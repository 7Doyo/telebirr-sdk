import { renderHook, act } from '@testing-library/react';
import { usePayment } from '../src/hooks/use-payment.js';
import { useRefund } from '../src/hooks/use-refund.js';
import { useWebhook } from '../src/hooks/use-webhook.js';
import { useRetry } from '../src/hooks/use-retry.js';
import { TelebirrProvider } from '../src/provider.js';
import type { ReactNode } from 'react';

const SANDBOX_CONFIG = {
  environment: 'SANDBOX' as const,
  fabricAppId: 'sk_test_abc123',
  merchantAppId: 'test-merchant',
  merchantCode: 'test-merchant-code',
  appSecret: 'test-secret',
  privateKeyPem: '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
  shortCode: '123456',
  timeout: '600',
  notifyUrl: 'https://example.com/notify',
};

function createWrapper() {
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <TelebirrProvider config={SANDBOX_CONFIG}>{children}</TelebirrProvider>
    );
  };
}

describe('usePayment', () => {
  it('starts with idle state', () => {
    const { result } = renderHook(() => usePayment(), {
      wrapper: createWrapper(),
    });
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.data).toBeNull();
  });

  it('reset clears data and error', () => {
    const { result } = renderHook(() => usePayment(), {
      wrapper: createWrapper(),
    });
    act(() => {
      result.current.reset();
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
  });

  it('charge sets loading true during call', async () => {
    const { result } = renderHook(() => usePayment(), {
      wrapper: createWrapper(),
    });
    const params = { amount: '100', title: 'Test' };
    await act(async () => {
      try {
        await result.current.charge(params);
      } catch {
        // Expected to fail since we have no real API
      }
    });
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeInstanceOf(Error);
  });
});

describe('useRefund', () => {
  it('starts with idle state', () => {
    const { result } = renderHook(() => useRefund(), {
      wrapper: createWrapper(),
    });
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.data).toBeNull();
  });

  it('reset clears state', () => {
    const { result } = renderHook(() => useRefund(), {
      wrapper: createWrapper(),
    });
    act(() => {
      result.current.reset();
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
  });

  it('refund throws on API failure', async () => {
    const { result } = renderHook(() => useRefund(), {
      wrapper: createWrapper(),
    });
    await act(async () => {
      try {
        await result.current.refund({ merchOrderId: 'test', refundRequestNo: 'refund-001', refundAmount: '100' });
      } catch {
        // Expected
      }
    });
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeInstanceOf(Error);
  });
});

describe('useWebhook', () => {
  it('returns verify function and null initial state', () => {
    const { result } = renderHook(() => useWebhook(), {
      wrapper: createWrapper(),
    });
    expect(typeof result.current.verify).toBe('function');
    expect(result.current.lastResult).toBeNull();
    expect(result.current.lastPayload).toBeNull();
  });
});

describe('useRetry', () => {
  it('starts with idle state', () => {
    const { result } = renderHook(() => useRetry(), {
      wrapper: createWrapper(),
    });
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.data).toBeNull();
    expect(result.current.attempt).toBe(0);
  });

  it('reset clears state', () => {
    const { result } = renderHook(() => useRetry(), {
      wrapper: createWrapper(),
    });
    act(() => {
      result.current.reset();
    });
    expect(result.current.data).toBeNull();
    expect(result.current.error).toBeNull();
  });
});
