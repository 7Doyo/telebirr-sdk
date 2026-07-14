'use client';
import { createContext, useContext, useMemo } from 'react';
import type { ReactNode } from 'react';
import { I18nextProvider } from 'react-i18next';
import { Telebirr } from '@telebirr/sdk-core';
import type { TelebirrConfig } from '@telebirr/sdk-core';
import { createTelebirrI18n } from './i18n/index.js';
import type { TelebirrTranslations } from './i18n/index.js';

/** Value exposed by the Telebirr context to descendant components. */
export interface TelebirrContextValue {
  /** Configured Telebirr SDK client instance. */
  client: Telebirr;
  /** The configuration object passed to the provider. */
  config: TelebirrConfig;
}

const TelebirrContext = createContext<TelebirrContextValue | null>(null);

/** Props accepted by the {@link TelebirrProvider} component. */
interface TelebirrProviderProps {
  /** Telebirr SDK configuration (appId, environment, keys, etc.). */
  config: TelebirrConfig;
  /** React children rendered inside the provider tree. */
  children: ReactNode;
  /** Optional overrides for built-in i18n translations keyed by locale code. */
  translations?: Record<string, TelebirrTranslations>;
}

/**
 * Root provider component for the Telebirr React SDK.
 *
 * Creates a `Telebirr` client instance and an i18n instance, then makes them
 * available to all descendants via React context. Must be rendered once at the
 * top of the component tree that uses Telebirr hooks or components.
 *
 * @example
 * ```tsx
 * <TelebirrProvider config={config}>
 *   <App />
 * </TelebirrProvider>
 * ```
 */
export function TelebirrProvider({
  config,
  children,
  translations,
}: TelebirrProviderProps) {
  const i18n = useMemo(
    () => createTelebirrI18n(translations),
    [translations],
  );

  const value = useMemo(
    () => ({
      client: new Telebirr(config),
      config,
    }),
    [config],
  );

  return (
    <I18nextProvider i18n={i18n}>
      <TelebirrContext.Provider value={value}>
        {children}
      </TelebirrContext.Provider>
    </I18nextProvider>
  );
}

export { TelebirrContext };
