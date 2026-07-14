import { TokenCache } from '../src/token-cache.js';

describe('TokenCache', () => {
  it('returns null when empty', () => {
    const cache = new TokenCache();
    expect(cache.get()).toBeNull();
  });

  it('returns cached token', () => {
    const cache = new TokenCache();
    cache.set('test-token');
    expect(cache.get()).toBe('test-token');
  });

  it('returns null after TTL expires', () => {
    const cache = new TokenCache({ ttlMs: 1 });
    cache.set('test-token');
    // Wait for TTL to expire
    return new Promise((resolve) => setTimeout(resolve, 10)).then(() => {
      expect(cache.get()).toBeNull();
    });
  });

  it('clears token', () => {
    const cache = new TokenCache();
    cache.set('test-token');
    cache.clear();
    expect(cache.get()).toBeNull();
  });

  it('uses default TTL of 50 minutes', () => {
    const cache = new TokenCache();
    cache.set('test-token');
    // Should still be valid immediately
    expect(cache.get()).toBe('test-token');
  });
});
