import i18next from 'i18next';
import en from './locales/en.json';
import am from './locales/am.json';
import om from './locales/om.json';
import ti from './locales/ti.json';
import ar from './locales/ar.json';

/**
 * A flat record of translation key-value pairs for the `telebirr` namespace.
 *
 * Each key corresponds to a UI string used by components like `PaymentButton`,
 * `PaymentStatus`, `ErrorDisplay`, etc.
 */
export type TelebirrTranslations = Record<string, string>;

const NAMESPACE = 'telebirr';

/**
 * Creates and initializes a standalone i18next instance pre-loaded with
 * built-in Telebirr translations (English, Amharic, Oromo, Tigrinya, Arabic).
 *
 * Custom translations are merged on top of the built-in strings, and any
 * locale not in the built-in set is added as-is.
 *
 * @param customTranslations - Optional map of locale codes to custom key-value pairs.
 * @returns A configured i18next instance with the `telebirr` namespace.
 *
 * @example
 * ```ts
 * const i18n = createTelebirrI18n({
 *   fr: { payNow: 'Payer maintenant', processing: 'Traitement…' },
 * });
 * ```
 */
export function createTelebirrI18n(
  customTranslations?: Record<string, TelebirrTranslations>,
) {
  const resources: Record<string, { telebirr: Record<string, string> }> = {};

  const builtIn: Record<string, Record<string, string>> = {
    en,
    am,
    om,
    ti,
    ar,
  };

  for (const [lang, defaultStrings] of Object.entries(builtIn)) {
    resources[lang] = {
      [NAMESPACE]: {
        ...defaultStrings,
        ...customTranslations?.[lang],
      },
    };
  }

  if (customTranslations) {
    for (const [lang, customStrings] of Object.entries(customTranslations)) {
      if (!resources[lang]) {
        resources[lang] = { [NAMESPACE]: customStrings };
      }
    }
  }

  const instance = i18next.createInstance();
  instance.init({
    lng: 'en',
    fallbackLng: 'en',
    ns: [NAMESPACE],
    defaultNS: NAMESPACE,
    resources,
    interpolation: { escapeValue: false },
  });

  return instance;
}

/**
 * Pre-created singleton i18next instance with built-in Telebirr translations.
 */
export const telebirrI18n = createTelebirrI18n();
