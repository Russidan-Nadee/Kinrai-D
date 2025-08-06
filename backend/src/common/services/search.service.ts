import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { LanguageService } from './language.service';

export interface FullTextSearchOptions {
  query: string;
  language?: string;
  fuzzySearch?: boolean;
  minRelevance?: number;
  limit?: number;
  offset?: number;
}

export interface SearchResult<T> {
  data: T[];
  total: number;
  relevanceScores?: number[];
  searchTime: number;
}

@Injectable()
export class SearchService {
  constructor(
    private prisma: PrismaService,
    private languageService: LanguageService
  ) {}

  /**
   * Perform full-text search on menu translations
   */
  async searchMenus(options: FullTextSearchOptions): Promise<SearchResult<any>> {
    const startTime = Date.now();
    const {
      query,
      language = 'th',
      fuzzySearch = true,
      minRelevance = 0.1,
      limit = 20,
      offset = 0
    } = options;

    const preferredLanguage = this.languageService.validateLanguage(language);
    const searchQuery = this.sanitizeSearchQuery(query);

    // Build search queries
    const baseQuery = `
      SELECT DISTINCT
        m.*,
        mt.name,
        mt.description,
        ts_rank(
          to_tsvector('english', COALESCE(mt.name, '') || ' ' || COALESCE(mt.description, '')),
          plainto_tsquery('english', $1)
        ) as relevance_score
      FROM menus m
      INNER JOIN menu_translations mt ON m.id = mt.menu_id
      WHERE m.is_active = true
        AND mt.language = $2
        AND (
          to_tsvector('english', COALESCE(mt.name, '') || ' ' || COALESCE(mt.description, ''))
          @@ plainto_tsquery('english', $1)
          ${fuzzySearch ? 'OR similarity(mt.name, $1) > 0.3 OR similarity(mt.description, $1) > 0.2' : ''}
        )
        AND ts_rank(
          to_tsvector('english', COALESCE(mt.name, '') || ' ' || COALESCE(mt.description, '')),
          plainto_tsquery('english', $1)
        ) >= $3
      ORDER BY relevance_score DESC, m.created_at DESC
      LIMIT $4 OFFSET $5
    `;

    const countQuery = `
      SELECT COUNT(DISTINCT m.id) as total
      FROM menus m
      INNER JOIN menu_translations mt ON m.id = mt.menu_id
      WHERE m.is_active = true
        AND mt.language = $2
        AND (
          to_tsvector('english', COALESCE(mt.name, '') || ' ' || COALESCE(mt.description, ''))
          @@ plainto_tsquery('english', $1)
          ${fuzzySearch ? 'OR similarity(mt.name, $1) > 0.3 OR similarity(mt.description, $1) > 0.2' : ''}
        )
        AND ts_rank(
          to_tsvector('english', COALESCE(mt.name, '') || ' ' || COALESCE(mt.description, '')),
          plainto_tsquery('english', $1)
        ) >= $3
    `;

    try {
      const [results, countResult] = await Promise.all([
        this.prisma.$queryRawUnsafe(baseQuery, searchQuery, preferredLanguage, minRelevance, limit, offset),
        this.prisma.$queryRawUnsafe(countQuery, searchQuery, preferredLanguage, minRelevance)
      ]);

      const endTime = Date.now();
      const searchTime = endTime - startTime;

      return {
        data: results as any[],
        total: (countResult as any[])[0]?.total || 0,
        relevanceScores: (results as any[]).map((r: any) => r.relevance_score),
        searchTime
      };
    } catch (error) {
      // Fallback to basic LIKE search if full-text search fails
      console.warn('Full-text search failed, falling back to LIKE search:', error.message);
      return this.fallbackSearch(options);
    }
  }

  /**
   * Fallback search using basic LIKE operations
   */
  private async fallbackSearch(options: FullTextSearchOptions): Promise<SearchResult<any>> {
    const startTime = Date.now();
    const {
      query,
      language = 'th',
      limit = 20,
      offset = 0
    } = options;

    const preferredLanguage = this.languageService.validateLanguage(language);
    const searchTerm = `%${query}%`;

    const [menus, total] = await Promise.all([
      this.prisma.menu.findMany({
        where: {
          is_active: true,
          Translations: {
            some: {
              language: preferredLanguage,
              OR: [
                { name: { contains: query, mode: 'insensitive' } },
                { description: { contains: query, mode: 'insensitive' } }
              ]
            }
          }
        },
        include: {
          Translations: {
            where: { language: preferredLanguage }
          }
        },
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: offset
      }),
      this.prisma.menu.count({
        where: {
          is_active: true,
          Translations: {
            some: {
              language: preferredLanguage,
              OR: [
                { name: { contains: query, mode: 'insensitive' } },
                { description: { contains: query, mode: 'insensitive' } }
              ]
            }
          }
        }
      })
    ]);

    const endTime = Date.now();
    
    return {
      data: menus,
      total,
      searchTime: endTime - startTime
    };
  }

  /**
   * Get search suggestions based on partial input
   */
  async getSearchSuggestions(partialQuery: string, language = 'th', limit = 5): Promise<string[]> {
    const preferredLanguage = this.languageService.validateLanguage(language);
    
    const suggestions = await this.prisma.$queryRawUnsafe(`
      SELECT DISTINCT mt.name
      FROM menu_translations mt
      INNER JOIN menus m ON mt.menu_id = m.id
      WHERE m.is_active = true
        AND mt.language = $1
        AND mt.name ILIKE $2
      ORDER BY similarity(mt.name, $3) DESC, LENGTH(mt.name)
      LIMIT $4
    `, preferredLanguage, `${partialQuery}%`, partialQuery, limit);

    return (suggestions as any[]).map(s => s.name);
  }

  /**
   * Get popular search terms
   */
  async getPopularSearchTerms(language = 'th', limit = 10): Promise<string[]> {
    // This would typically come from search logs
    // For now, return common food terms
    return [
      'ข้าว', 'ผัด', 'แกง', 'ส้ม', 'ย่าง',
      'rice', 'curry', 'soup', 'spicy', 'sweet'
    ].slice(0, limit);
  }

  /**
   * Sanitize search query to prevent injection
   */
  private sanitizeSearchQuery(query: string): string {
    return query
      .trim()
      .replace(/[^\w\s\u0E00-\u0E7F]/g, '') // Keep only word characters and Thai characters
      .replace(/\s+/g, ' ')
      .substring(0, 100); // Limit length
  }

  /**
   * Build search filters for complex queries
   */
  buildSearchFilters(searchDto: any) {
    const filters: any = {
      is_active: true
    };

    if (searchDto.meal_time) {
      filters.meal_time = searchDto.meal_time;
    }

    if (searchDto.subcategory_ids?.length) {
      filters.subcategory_id = { in: searchDto.subcategory_ids };
    }

    if (searchDto.protein_type_ids?.length) {
      filters.protein_type_id = { in: searchDto.protein_type_ids };
    }

    if (searchDto.category_ids?.length) {
      filters.Subcategory = {
        category_id: { in: searchDto.category_ids }
      };
    }

    if (searchDto.food_type_ids?.length) {
      filters.Subcategory = {
        ...filters.Subcategory,
        Category: {
          food_type_id: { in: searchDto.food_type_ids }
        }
      };
    }

    return filters;
  }
}