import { Telebirr } from '../src/client.js';
import { EnvironmentError, ValidationError } from '../src/exceptions.js';
import { PaymentStatus, mapTelebirrStatus } from '../src/models/query-order.js';
import { generateKeyPairSync } from 'node:crypto';

let privateKey = '';

beforeAll(() => {
  const { privateKey: priv } = generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
  privateKey = priv;
});

const baseConfig = () => ({
  fabricAppId: 'sk_test_12345678-1234-1234-1234-123456789012',
  merchantAppId: '100001',
  merchantCode: 'MC001',
  appSecret: 'secret',
  privateKeyPem: privateKey,
  shortCode: '220311',
  timeout: '120m',
  notifyUrl: 'https://example.com/webhook',
});

describe('Telebirr constructor', () => {
  it('creates instance with valid sandbox config', () => {
    const client = new Telebirr({
      ...baseConfig(),
      environment: 'SANDBOX',
    });
    expect(client.payments).toBeDefined();
  });

  it('throws EnvironmentError for test key in production', () => {
    expect(
      () =>
        new Telebirr({
          ...baseConfig(),
          environment: 'PRODUCTION',
        }),
    ).toThrow(EnvironmentError);
  });

  it('throws EnvironmentError for live key in sandbox', () => {
    expect(
      () =>
        new Telebirr({
          ...baseConfig(),
          fabricAppId: 'sk_live_12345678-1234-1234-1234-123456789012',
          environment: 'SANDBOX',
        }),
    ).toThrow(EnvironmentError);
  });

  it('allows live key in production', () => {
    const client = new Telebirr({
      ...baseConfig(),
      fabricAppId: 'sk_live_12345678-1234-1234-1234-123456789012',
      environment: 'PRODUCTION',
    });
    expect(client.payments).toBeDefined();
  });
});

describe('PaymentStatus', () => {
  it('has correct enum values', () => {
    expect(PaymentStatus.SUCCESS).toBe('SUCCESS');
    expect(PaymentStatus.FAIL).toBe('FAIL');
    expect(PaymentStatus.TIMEOUT).toBe('TIMEOUT');
    expect(PaymentStatus.PENDING).toBe('PENDING');
    expect(PaymentStatus.ACCEPTED).toBe('ACCEPTED');
    expect(PaymentStatus.REFUNDING).toBe('REFUNDING');
    expect(PaymentStatus.REFUND_SUCCESS).toBe('REFUND_SUCCESS');
    expect(PaymentStatus.REFUND_FAILED).toBe('REFUND_FAILED');
  });
});

describe('mapTelebirrStatus', () => {
  it('maps PAY_SUCCESS to SUCCESS', () => {
    expect(mapTelebirrStatus('PAY_SUCCESS')).toBe(PaymentStatus.SUCCESS);
  });

  it('maps PAY_FAILED to FAIL', () => {
    expect(mapTelebirrStatus('PAY_FAILED')).toBe(PaymentStatus.FAIL);
  });

  it('maps ORDER_CLOSED to TIMEOUT', () => {
    expect(mapTelebirrStatus('ORDER_CLOSED')).toBe(PaymentStatus.TIMEOUT);
  });

  it('maps WAIT_PAY to PENDING', () => {
    expect(mapTelebirrStatus('WAIT_PAY')).toBe(PaymentStatus.PENDING);
  });

  it('maps PAYING to PENDING', () => {
    expect(mapTelebirrStatus('PAYING')).toBe(PaymentStatus.PENDING);
  });

  it('maps ACCEPTED to ACCEPTED', () => {
    expect(mapTelebirrStatus('ACCEPTED')).toBe(PaymentStatus.ACCEPTED);
  });

  it('maps REFUNDING to REFUNDING', () => {
    expect(mapTelebirrStatus('REFUNDING')).toBe(PaymentStatus.REFUNDING);
  });

  it('maps REFUND_SUCCESS to REFUND_SUCCESS', () => {
    expect(mapTelebirrStatus('REFUND_SUCCESS')).toBe(PaymentStatus.REFUND_SUCCESS);
  });

  it('maps REFUND_FAILED to REFUND_FAILED', () => {
    expect(mapTelebirrStatus('REFUND_FAILED')).toBe(PaymentStatus.REFUND_FAILED);
  });

  it('returns PENDING for unknown status', () => {
    expect(mapTelebirrStatus('UNKNOWN')).toBe(PaymentStatus.PENDING);
  });
});
