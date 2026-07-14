import { verifyNotification, NotificationTradeStatus } from '../src/webhook.js';
import { generateKeyPairSync, createSign } from 'node:crypto';

let privateKey = '';
let publicKey = '';

beforeAll(() => {
  const { privateKey: priv, publicKey: pub } = generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
  privateKey = priv;
  publicKey = pub;
});

describe('NotificationTradeStatus', () => {
  it('has correct values', () => {
    expect(NotificationTradeStatus.PAYING).toBe('Paying');
    expect(NotificationTradeStatus.EXPIRED).toBe('Expired');
    expect(NotificationTradeStatus.PENDING).toBe('Pending');
    expect(NotificationTradeStatus.COMPLETED).toBe('Completed');
    expect(NotificationTradeStatus.FAILURE).toBe('Failure');
  });
});

describe('verifyNotification', () => {
  it('returns true for valid signature', () => {
    const payload = {
      merch_order_id: 'order-123',
      payment_order_id: 'pay-456',
      trade_status: NotificationTradeStatus.COMPLETED,
      trans_end_time: '20240101120000',
      sign: '',
      sign_type: 'SHA256WithRSA',
    };

    const signString = Object.keys(payload)
      .filter((k) => k !== 'sign' && k !== 'sign_type')
      .sort()
      .map((k) => `${k}=${payload[k as keyof typeof payload]}`)
      .join('&');

    const sign = createSign('SHA256');
    sign.update(signString);
    sign.end();
    const signature = sign.sign(privateKey, 'base64');

    const signedPayload = { ...payload, sign: signature };
    expect(verifyNotification(signedPayload, publicKey)).toBe(true);
  });

  it('returns false for invalid signature', () => {
    const payload = {
      merch_order_id: 'order-123',
      payment_order_id: 'pay-456',
      trade_status: NotificationTradeStatus.COMPLETED,
      trans_end_time: '20240101120000',
      sign: 'invalid-signature',
      sign_type: 'SHA256WithRSA',
    };

    expect(verifyNotification(payload, publicKey)).toBe(false);
  });

  it('returns false when sign is missing', () => {
    const payload = {
      merch_order_id: 'order-123',
      payment_order_id: 'pay-456',
      trade_status: NotificationTradeStatus.COMPLETED,
      trans_end_time: '20240101120000',
      sign_type: 'SHA256WithRSA',
    };

    expect(verifyNotification(payload, publicKey)).toBe(false);
  });
});
