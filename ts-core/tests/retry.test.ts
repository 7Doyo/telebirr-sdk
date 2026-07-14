import { withRetry } from '../src/retry.js';

describe('withRetry', () => {
  it('returns result on success', async () => {
    const result = await withRetry(async () => 'ok');
    expect(result).toBe('ok');
  });

  it('retries on retryable error', async () => {
    let attempts = 0;
    const result = await withRetry(
      async () => {
        attempts++;
        if (attempts < 3) throw { code: 'NETWORK_ERROR', message: 'fail' };
        return 'ok';
      },
      { maxAttempts: 3, baseDelayMs: 1 },
    );
    expect(result).toBe('ok');
    expect(attempts).toBe(3);
  });

  it('throws after max attempts', async () => {
    await expect(
      withRetry(
        async () => {
          throw { code: 'NETWORK_ERROR', message: 'fail' };
        },
        { maxAttempts: 2, baseDelayMs: 1 },
      ),
    ).rejects.toMatchObject({ code: 'NETWORK_ERROR' });
  });

  it('does not retry on non-retryable error', async () => {
    let attempts = 0;
    await expect(
      withRetry(
        async () => {
          attempts++;
          throw { code: 'VALIDATION_ERROR', message: 'fail' };
        },
        { maxAttempts: 3, baseDelayMs: 1 },
      ),
    ).rejects.toMatchObject({ code: 'VALIDATION_ERROR' });
    expect(attempts).toBe(1);
  });

  it('accepts custom retryOn function', async () => {
    let attempts = 0;
    const result = await withRetry(
      async () => {
        attempts++;
        if (attempts < 2) throw new Error('custom');
        return 'ok';
      },
      { maxAttempts: 3, baseDelayMs: 1, retryOn: () => true },
    );
    expect(result).toBe('ok');
    expect(attempts).toBe(2);
  });
});
