import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { LANGUAGE_CONFIG, SupportedLanguage } from '../constants/languages';

@Injectable()
export class LanguageService {
  constructor(private prisma: PrismaService) {}

  /**
   * Get the best available translation from a list of translations
   * Falls back to other languages if requested language is not available
   */
  getBestTranslation<T extends { language: string }>(
    translations: T[],
    requestedLanguage: string = LANGUAGE_CONFIG.DEFAULT
  ): T | null {
    if (!translations || translations.length === 0) {
      return null;
    }

    // Validate requested language
    const lang = this.validateLanguage(requestedLanguage);
    
    // Get fallback priority for the requested language
    const fallbackPriority = LANGUAGE_CONFIG.FALLBACK_PRIORITY[lang] || 
                            LANGUAGE_CONFIG.FALLBACK_PRIORITY[LANGUAGE_CONFIG.DEFAULT];

    // Try to find translation in priority order
    for (const priorityLang of fallbackPriority) {
      const translation = translations.find(t => t.language === priorityLang);
      if (translation) {
        return translation;
      }
    }

    // If no translation found in priority languages, return the first available
    return translations[0] || null;
  }

  /**
   * Get all available translations with fallback for missing languages
   */
  async getTranslationsWithFallback<T extends { language: string }>(
    translations: T[],
    requestedLanguages: string[] = [LANGUAGE_CONFIG.DEFAULT]
  ): Promise<T[]> {
    const results: T[] = [];

    for (const lang of requestedLanguages) {
      const validLang = this.validateLanguage(lang);
      const translation = this.getBestTranslation(translations, validLang);
      
      if (translation && !results.find(r => r.language === translation.language)) {
        results.push(translation);
      }
    }

    return results;
  }

  /**
   * Validate and normalize language code
   */
  validateLanguage(language: string): SupportedLanguage {
    const normalizedLang = language.toLowerCase().slice(0, 2);
    
    if (LANGUAGE_CONFIG.SUPPORTED.includes(normalizedLang as SupportedLanguage)) {
      return normalizedLang as SupportedLanguage;
    }
    
    return LANGUAGE_CONFIG.DEFAULT;
  }

  /**
   * Get language preferences based on user context or headers
   */
  getLanguagePreferences(
    userPreference?: string,
    acceptLanguage?: string
  ): SupportedLanguage[] {
    const preferences: string[] = [];
    
    // Add user preference first
    if (userPreference) {
      preferences.push(userPreference);
    }
    
    // Parse Accept-Language header
    if (acceptLanguage) {
      const headerLangs = this.parseAcceptLanguage(acceptLanguage);
      preferences.push(...headerLangs);
    }
    
    // Add default and fallback
    preferences.push(LANGUAGE_CONFIG.DEFAULT, LANGUAGE_CONFIG.FALLBACK);
    
    // Remove duplicates and validate
    const uniquePrefs = [...new Set(preferences)];
    return uniquePrefs.map(lang => this.validateLanguage(lang));
  }

  /**
   * Parse Accept-Language header
   */
  private parseAcceptLanguage(acceptLanguage: string): string[] {
    return acceptLanguage
      .split(',')
      .map(lang => lang.split(';')[0].trim().slice(0, 2))
      .filter(lang => lang.length === 2);
  }

  /**
   * Create Prisma where clause for translations with fallback
   */
  createTranslationWhereClause(
    requestedLanguage: string = LANGUAGE_CONFIG.DEFAULT,
    enableFallback: boolean = true
  ) {
    const lang = this.validateLanguage(requestedLanguage);
    
    if (!enableFallback) {
      return { language: lang };
    }

    const fallbackPriority = LANGUAGE_CONFIG.FALLBACK_PRIORITY[lang];
    
    return {
      language: {
        in: fallbackPriority
      }
    };
  }

  /**
   * Get language statistics for analytics
   */
  async getLanguageStats() {
    const stats = await Promise.all([
      this.prisma.menuTranslation.groupBy({
        by: ['language'],
        _count: { id: true }
      }),
      this.prisma.categoryTranslation.groupBy({
        by: ['language'],
        _count: { id: true }
      }),
      this.prisma.foodTypeTranslation.groupBy({
        by: ['language'],
        _count: { id: true }
      })
    ]);

    return {
      menu_translations: stats[0],
      category_translations: stats[1],
      food_type_translations: stats[2],
      total_supported_languages: LANGUAGE_CONFIG.SUPPORTED.length,
      default_language: LANGUAGE_CONFIG.DEFAULT
    };
  }
}