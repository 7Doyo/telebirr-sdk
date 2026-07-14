import { NetworkError } from './exceptions.js';

/**
 * Sends a JSON POST request using the native `fetch` API.
 *
 * @typeParam T - Expected response body type.
 * @param url - Full URL to send the request to.
 * @param body - Request body object (serialised to JSON).
 * @param headers - Additional HTTP headers (merged with `Content-Type: application/json`).
 * @returns Parsed JSON response body.
 * @throws {NetworkError} On network errors or non-2xx HTTP responses.
 *
 * @example
 * ```ts
 * const data = await postJson<{ token: string }>(
 *   'https://api.example.com/token',
 *   { appSecret: 'secret' },
 *   { 'X-APP-Key': 'my-app-id' },
 * );
 * ```
 */
export async function postJson<T>(
  url: string,
  body: Record<string, unknown>,
  headers: Record<string, string>,
): Promise<T> {
  let response: Response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...headers },
      body: JSON.stringify(body),
    });
  } catch (err) {
    throw new NetworkError(
      `Request failed: ${err instanceof Error ? err.message : String(err)}`,
    );
  }

  if (!response.ok) {
    const text = await response.text().catch(() => '');
    throw new NetworkError(
      `HTTP ${response.status}: ${text || response.statusText}`,
    );
  }

  return (await response.json()) as T;
}
