export const SUPPORTED_LANGUAGES = ['th', 'en', 'jp', 'zh'] as const;
export const DEFAULT_LANGUAGE = 'th' as const;
export const FALLBACK_LANGUAGE = 'en' as const;

export type SupportedLanguage = (typeof SUPPORTED_LANGUAGES)[number];

export const LANGUAGE_CONFIG = {
  DEFAULT: DEFAULT_LANGUAGE,
  FALLBACK: FALLBACK_LANGUAGE,
  SUPPORTED: SUPPORTED_LANGUAGES,

  // Language priority for fallback
  FALLBACK_PRIORITY: {
    th: ['th', 'en', 'jp', 'zh'],
    en: ['en', 'th', 'jp', 'zh'],
    jp: ['jp', 'en', 'th', 'zh'],
    zh: ['zh', 'en', 'th', 'jp'],
  } as Record<SupportedLanguage, SupportedLanguage[]>,
};

export const LANGUAGE_NAMES = {
  th: 'ไทย',
  en: 'English',
  jp: '日本語',
  zh: '中文',
} as Record<SupportedLanguage, string>;
