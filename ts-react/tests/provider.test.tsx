import '@testing-library/jest-dom';
import { jest } from '@jest/globals';
import { render, screen } from '@testing-library/react';
import { TelebirrProvider } from '../src/provider.js';
import { useTelebirr } from '../src/hooks/use-telebirr.js';

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

function TestChild() {
  const ctx = useTelebirr();
  return <span data-testid="context-child">{ctx.config.environment}</span>;
}

describe('TelebirrProvider', () => {
  it('provides context to children', () => {
    render(
      <TelebirrProvider config={SANDBOX_CONFIG}>
        <TestChild />
      </TelebirrProvider>,
    );
    expect(screen.getByTestId('context-child')).toHaveTextContent('SANDBOX');
  });

  it('useTelebirr works inside provider', () => {
    function Inner() {
      const { client } = useTelebirr();
      return <span data-testid="has-client">{typeof client.payments.charge}</span>;
    }
    render(
      <TelebirrProvider config={SANDBOX_CONFIG}>
        <Inner />
      </TelebirrProvider>,
    );
    expect(screen.getByTestId('has-client')).toHaveTextContent('function');
  });

  it('useTelebirr throws outside provider', () => {
    const spy = jest.spyOn(console, 'error').mockImplementation(() => {});
    function Outer() {
      useTelebirr();
      return null;
    }
    expect(() => render(<Outer />)).toThrow(
      'useTelebirr must be used within TelebirrProvider',
    );
    spy.mockRestore();
  });
});
