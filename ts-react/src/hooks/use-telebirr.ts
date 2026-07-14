'use client';
import { useContext } from 'react';
import { TelebirrContext } from '../provider.js';

/**
 * Retrieves the Telebirr SDK client and configuration from context.
 *
 * Must be called from a component rendered inside a `<TelebirrProvider>`.
 * Throws a descriptive error if no provider is found.
 *
 * @returns The {@link TelebirrContextValue} containing the `client` and `config`.
 *
 * @example
 * ```tsx
 * const { client, config } = useTelebirr();
 * ```
 */
export function useTelebirr() {
  const ctx = useContext(TelebirrContext);
  if (!ctx) throw new Error('useTelebirr must be used within TelebirrProvider');
  return ctx;
}
