import { generateIdempotencyKey } from '../src/idempotency.js';

describe('generateIdempotencyKey', () => {
  it('returns a 32-char hex string', () => {
    const key = generateIdempotencyKey('order-123');
    expect(key).toHaveLength(64);
    expect(key).toMatch(/^[0-9A-F]+$/);
  });

  it('returns same key for same orderId', () => {
    const key1 = generateIdempotencyKey('order-123');
    const key2 = generateIdempotencyKey('order-123');
    expect(key1).toBe(key2);
  });

  it('returns different keys for different orderIds', () => {
    const key1 = generateIdempotencyKey('order-123');
    const key2 = generateIdempotencyKey('order-456');
    expect(key1).not.toBe(key2);
  });
});
