import { buildSignString, sha256PssSign, signRequest } from '../src/signing.js';
import { generateKeyPairSync } from 'node:crypto';

let privateKey: string;
let publicKey: string;

beforeAll(() => {
  const { privateKey: priv, publicKey: pub } = generateKeyPairSync('rsa', {
    modulusLength: 2048,
    publicKeyEncoding: { type: 'spki', format: 'pem' },
    privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
  });
  privateKey = priv;
  publicKey = pub;
});

describe('buildSignString', () => {
  it('excludes sign, sign_type, and biz_content keys', () => {
    const request: Record<string, unknown> = {
      method: 'payment.preorder',
      version: '1.0',
      sign_type: 'SHA256WithRSA',
      sign: 'abc',
      nonce_str: 'ABC123',
      timestamp: '1234567890',
      biz_content: {
        appid: '123',
        merch_code: 'MC001',
        total_amount: '100',
      },
    };

    const result = buildSignString(request);
    expect(result).not.toContain('sign=');
    expect(result).not.toContain('sign_type=');
    expect(result).not.toContain('biz_content=');

    expect(result).toContain('appid=123');
    expect(result).toContain('merch_code=MC001');
    expect(result).toContain('method=payment.preorder');
    expect(result).toContain('nonce_str=ABC123');
    expect(result).toContain('timestamp=1234567890');
    expect(result).toContain('total_amount=100');
    expect(result).toContain('version=1.0');
  });

  it('sorts fields ASCII lexicographically', () => {
    const request: Record<string, unknown> = {
      version: '1.0',
      method: 'payment.preorder',
      nonce_str: 'XYZ',
      biz_content: {
        total_amount: '500',
        appid: '999',
      },
    };

    const result = buildSignString(request);
    const keys = result.split('&').map((pair) => pair.split('=')[0]);
    const sorted = [...keys].sort();
    expect(keys).toEqual(sorted);
  });
});

describe('sha256PssSign', () => {
  it('returns a base64 string', () => {
    const signature = sha256PssSign('hello world', privateKey);
    expect(typeof signature).toBe('string');
    expect(() => Buffer.from(signature, 'base64')).not.toThrow();
  });

  it('produces different signatures for different inputs', () => {
    const sig1 = sha256PssSign('data1', privateKey);
    const sig2 = sha256PssSign('data2', privateKey);
    expect(sig1).not.toBe(sig2);
  });
});

describe('signRequest', () => {
  it('returns a base64 signature', () => {
    const request: Record<string, unknown> = {
      method: 'payment.preorder',
      version: '1.0',
      nonce_str: 'TEST',
      timestamp: '1000',
      biz_content: { appid: '123' },
    };

    const sig = signRequest(request, privateKey);
    expect(typeof sig).toBe('string');
    expect(() => Buffer.from(sig, 'base64')).not.toThrow();
  });
});
