import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CacheService } from '../../common/services/cache.service';
import { LanguageService } from '../../common/services/language.service';
import {
  MenuRecommendationQueryDto,
  MenuRecommendationResultDto,
  MenuRecommendationDto,
} from '../dto/menu-recommendation.dto';
import { DEFAULT_LANGUAGE } from '../../common/constants/languages';

export interface UserBehaviorData {
  userId: string;
  recentOrders: number[];
  favoriteMenus: number[];
  ratings: { menuId: number; rating: number; timestamp: Date }[];
  searchHistory: string[];
  viewHistory: number[];
  timePreferences: { [key: string]: number }; // hour -> frequency
  categoryPreferences: { [key: number]: number }; // categoryId -> score
}

export interface RecommendationStrategy {
  name: string;
  weight: number;
  calculateScore(
    menu: any,
    userData?: UserBehaviorData,
    context?: any,
  ): Promise<number>;
}

@Injectable()
export class RecommendationService {
  private readonly logger = new Logger(RecommendationService.name);
  private strategies: Map<string, RecommendationStrategy> = new Map();

  constructor(
    private prisma: PrismaService,
    private cacheService: CacheService,
    private languageService: LanguageService,
  ) {
    this.initializeStrategies();
  }

  private initializeStrategies() {
    // Register different recommendation strategies
    this.strategies.set('popularity', {
      name: 'Popularity Based',
      weight: 0.2,
      calculateScore: this.calculatePopularityScore.bind(this),
    });

    this.strategies.set('rating', {
      name: 'Rating Based',
      weight: 0.25,
      calculateScore: this.calculateRatingScore.bind(this),
    });

    this.strategies.set('collaborative', {
      name: 'Collaborative Filtering',
      weight: 0.3,
      calculateScore: this.calculateCollaborativeScore.bind(this),
    });

    this.strategies.set('content', {
      name: 'Content Based',
      weight: 0.15,
      calculateScore: this.calculateContentScore.bind(this),
    });

    this.strategies.set('temporal', {
      name: 'Time-based',
      weight: 0.1,
      calculateScore: this.calculateTemporalScore.bind(this),
    });
  }

  async getAdvancedRecommendations(
    queryDto: MenuRecommendationQueryDto,
  ): Promise<MenuRecommendationResultDto> {
    const startTime = Date.now();

    try {
      // Handle random subcategory + protein selection
      if (queryDto.recommendation_type === 'random') {
        return await this.getRandomSubcategoryProteinRecommendations(queryDto);
      }

      // Get user behavior data if user_id provided
      const userData = queryDto.user_id
        ? await this.getUserBehaviorData(queryDto.user_id)
        : null;

      // Get candidate menus
      const candidates = await this.getCandidateMenus(queryDto);

      // Calculate scores using multiple strategies
      const scoredMenus = await this.calculateAdvancedScores(
        candidates,
        userData || undefined,
        queryDto,
      );

      // Apply business rules and filters
      const filteredMenus = this.applyBusinessRules(scoredMenus, queryDto);

      // Sort and limit results
      const finalRecommendations = filteredMenus
        .sort((a, b) => b.recommendation_score - a.recommendation_score)
        .slice(0, queryDto.limit || 10);

      const endTime = Date.now();
      this.logger.log(
        `Generated ${finalRecommendations.length} recommendations in ${endTime - startTime}ms`,
      );

      return {
        recommendations: finalRecommendations,
        metadata: {
          total_found: candidates.length,
          recommendation_type: queryDto.recommendation_type || 'advanced',
          user_preferences_used: !!userData,
          generated_at: new Date(),
          language: queryDto.language || DEFAULT_LANGUAGE,
        },
        user_context: userData
          ? {
              user_id: queryDto.user_id,
              dietary_restrictions: [], // TODO: implement
              food_preferences: userData.categoryPreferences,
              recent_orders: userData.recentOrders.slice(0, 5),
            }
          : undefined,
      };
    } catch (error) {
      this.logger.error('Error generating advanced recommendations:', error);
      throw error;
    }
  }

  async getRandomSubcategoryProteinRecommendations(
    queryDto: MenuRecommendationQueryDto,
  ): Promise<MenuRecommendationResultDto> {
    const startTime = Date.now();

    try {
      const results: MenuRecommendationDto[] = [];
      const limit = queryDto.limit || 10;

      // Step 1: Get all active menu IDs
      const whereClause: any = { is_active: true };
      if (queryDto.meal_time) {
        whereClause.meal_time = queryDto.meal_time;
      }

      const menuIds = await this.prisma.menu.findMany({
        where: whereClause,
        select: { id: true },
      });

      if (menuIds.length === 0) {
        return {
          recommendations: [],
          metadata: {
            total_found: 0,
            recommendation_type: 'random',
            user_preferences_used: false,
            generated_at: new Date(),
            language: queryDto.language || DEFAULT_LANGUAGE,
          },
        };
      }

      // Step 2: Randomly select menu IDs
      const selectedIds = new Set<number>();
      for (let i = 0; i < limit && selectedIds.size < menuIds.length; i++) {
        let randomId;
        do {
          randomId = menuIds[Math.floor(Math.random() * menuIds.length)].id;
        } while (
          selectedIds.has(randomId) &&
          selectedIds.size < menuIds.length
        );
        selectedIds.add(randomId);
      }

      // Step 3: Get full menu data for selected IDs
      const selectedMenus = await this.prisma.menu.findMany({
        where: {
          id: { in: Array.from(selectedIds) },
        },
        include: {
          Subcategory: {
            include: {
              Translations: {
                where: this.languageService.createTranslationWhereClause(
                  queryDto.language,
                ),
              },
              Category: {
                include: {
                  Translations: {
                    where: this.languageService.createTranslationWhereClause(
                      queryDto.language,
                    ),
                  },
                  FoodType: {
                    include: {
                      Translations: {
                        where:
                          this.languageService.createTranslationWhereClause(
                            queryDto.language,
                          ),
                      },
                    },
                  },
                },
              },
            },
          },
          ProteinType: {
            include: {
              Translations: {
                where: this.languageService.createTranslationWhereClause(
                  queryDto.language,
                ),
              },
            },
          },
          Ratings: true,
          Favorites: true,
        },
      });

      // Step 4: Convert to recommendation format
      for (const menu of selectedMenus) {
        const subcategoryTranslation = menu.Subcategory?.Translations[0];

        // Generate dynamic menu name
        const subcategoryName =
          menu.Subcategory?.Translations[0]?.name ||
          menu.Subcategory?.key ||
          `subcategory_${menu.Subcategory?.id}`;
        const proteinName = menu.ProteinType?.Translations[0]?.name;
        const menuName = proteinName
          ? `${subcategoryName}${proteinName}`
          : subcategoryName;

        results.push({
          id: menu.id,
          name: menuName,
          description: undefined,
          image_url: menu.image_url,
          subcategory: {
            id: menu.Subcategory.id,
            name: subcategoryTranslation?.name || '',
            category: {
              id: menu.Subcategory.Category.id,
              name: menu.Subcategory.Category.Translations[0]?.name || '',
              food_type: {
                id: menu.Subcategory.Category.FoodType.id,
                name:
                  menu.Subcategory.Category.FoodType.Translations[0]?.name ||
                  '',
              },
            },
          },
          protein_type: menu.ProteinType
            ? {
                id: menu.ProteinType.id,
                name: menu.ProteinType.Translations[0]?.name || '',
              }
            : undefined,
          average_rating: this.calculateAverageRating(menu.Ratings),
          total_ratings: menu.Ratings.length,
          recommendation_score: 100,
          recommendation_reasons: ['Random selection'],
          meal_time: menu.meal_time,
          contains: menu.contains,
        });
      }

      const endTime = Date.now();
      this.logger.log(
        `Generated ${results.length} random menu recommendations in ${endTime - startTime}ms`,
      );

      return {
        recommendations: results,
        metadata: {
          total_found: results.length,
          recommendation_type: 'random',
          user_preferences_used: false,
          generated_at: new Date(),
          language: queryDto.language || DEFAULT_LANGUAGE,
        },
      };
    } catch (error) {
      this.logger.error('Error generating random menu recommendations:', error);
      throw error;
    }
  }

  private async getCandidateMenus(
    queryDto: MenuRecommendationQueryDto,
  ): Promise<any[]> {
    const cacheKey = `candidates:${JSON.stringify(queryDto)}`;

    return this.cacheService.getOrSet(
      cacheKey,
      async () => {
        const where: any = { is_active: true };

        // Apply basic filters
        if (queryDto.meal_time) where.meal_time = queryDto.meal_time;
        if (queryDto.excluded_menu_ids?.length)
          where.id = { notIn: queryDto.excluded_menu_ids };
        if (queryDto.preferred_protein_types?.length)
          where.protein_type_id = { in: queryDto.preferred_protein_types };

        const menus = await this.prisma.menu.findMany({
          where,
          include: {
            Subcategory: {
              include: {
                Translations: true,
                Category: {
                  include: {
                    Translations: true,
                    FoodType: { include: { Translations: true } },
                  },
                },
              },
            },
            ProteinType: { include: { Translations: true } },
            Ratings: true,
            Favorites: true,
          },
          take: (queryDto.limit || 10) * 3, // Get more candidates than needed
        });

        return menus;
      },
      { ttl: 300 },
    ); // 5 minutes cache
  }

  private async calculateAdvancedScores(
    candidates: any[],
    userData?: UserBehaviorData,
    context?: MenuRecommendationQueryDto,
  ): Promise<MenuRecommendationDto[]> {
    const scoredMenus: MenuRecommendationDto[] = [];

    for (const menu of candidates) {
      const scores: { [strategy: string]: number } = {};
      let totalScore = 0;
      const reasons: string[] = [];

      // Calculate score for each strategy
      for (const [strategyName, strategy] of this.strategies.entries()) {
        const strategyScore = await strategy.calculateScore(
          menu,
          userData,
          context,
        );
        scores[strategyName] = strategyScore;
        totalScore += strategyScore * strategy.weight;

        // Add reasons based on high strategy scores
        if (strategyScore > 0.7) {
          switch (strategyName) {
            case 'popularity':
              reasons.push('Popular among users');
              break;
            case 'rating':
              reasons.push('Highly rated');
              break;
            case 'collaborative':
              reasons.push('Users like you also enjoyed this');
              break;
            case 'content':
              reasons.push('Matches your preferences');
              break;
            case 'temporal':
              reasons.push('Perfect for this time');
              break;
          }
        }
      }

      // Build the recommendation DTO with dynamic naming
      const subcategoryTranslation = menu.Subcategory?.Translations[0];
      const subcategoryName =
        subcategoryTranslation?.name ||
        menu.Subcategory?.key ||
        `subcategory_${menu.Subcategory?.id}`;
      const proteinName = menu.ProteinType?.Translations[0]?.name;
      const menuName = proteinName
        ? `${subcategoryName}${proteinName}`
        : subcategoryName;

      scoredMenus.push({
        id: menu.id,
        name: menuName,
        description: undefined,
        image_url: menu.image_url,
        subcategory: {
          id: menu.Subcategory.id,
          name: subcategoryTranslation?.name || '',
          category: {
            id: menu.Subcategory.Category.id,
            name: menu.Subcategory.Category.Translations[0]?.name || '',
            food_type: {
              id: menu.Subcategory.Category.FoodType.id,
              name:
                menu.Subcategory.Category.FoodType.Translations[0]?.name || '',
            },
          },
        },
        protein_type: menu.ProteinType
          ? {
              id: menu.ProteinType.id,
              name: menu.ProteinType.Translations[0]?.name || '',
            }
          : undefined,
        average_rating: this.calculateAverageRating(menu.Ratings),
        total_ratings: menu.Ratings.length,
        recommendation_score: Math.min(totalScore * 100, 100),
        recommendation_reasons: reasons,
        meal_time: menu.meal_time,
        contains: menu.contains,
      });
    }

    return scoredMenus;
  }

  // Strategy implementations
  private async calculatePopularityScore(menu: any): Promise<number> {
    const favoriteCount = menu.Favorites?.length || 0;
    const viewCount = await this.getMenuViewCount(menu.id);
    const orderCount = await this.getMenuOrderCount(menu.id);

    const totalInteractions = favoriteCount * 3 + viewCount + orderCount * 5;

    // Normalize to 0-1 scale (assuming max interactions is 1000)
    return Math.min(totalInteractions / 1000, 1);
  }

  private async calculateRatingScore(menu: any): Promise<number> {
    const ratings = menu.Ratings || [];
    if (ratings.length === 0) return 0.5; // neutral for no ratings

    const avgRating = this.calculateAverageRating(ratings);
    const confidence = Math.min(ratings.length / 10, 1); // confidence based on rating count

    return (avgRating / 5) * confidence + (1 - confidence) * 0.5;
  }

  private async calculateCollaborativeScore(
    menu: any,
    userData?: UserBehaviorData,
  ): Promise<number> {
    if (!userData) return 0.5;

    // Find similar users based on common favorites and ratings
    const similarUsers = await this.findSimilarUsers(userData);

    if (similarUsers.length === 0) return 0.5;

    // Check how many similar users liked this menu
    let score = 0;
    for (const similarUser of similarUsers) {
      if (similarUser.favoriteMenuIds.includes(menu.id)) {
        score += similarUser.similarity * 0.8;
      }

      const rating = similarUser.ratings.find((r: any) => r.menuId === menu.id);
      if (rating && rating.rating >= 4) {
        score += similarUser.similarity * 0.6;
      }
    }

    return Math.min(score / similarUsers.length, 1);
  }

  private async calculateContentScore(
    menu: any,
    userData?: UserBehaviorData,
  ): Promise<number> {
    if (!userData) return 0.5;

    let score = 0;

    // Category preference
    const categoryId = menu.Subcategory.category_id;
    const categoryPreference = userData.categoryPreferences[categoryId] || 0;
    score += categoryPreference * 0.4;

    // Protein type preference
    if (menu.protein_type_id && userData.favoriteMenus.length > 0) {
      const proteinPreference = await this.calculateProteinPreference(
        userData,
        menu.protein_type_id,
      );
      score += proteinPreference * 0.3;
    }

    // Ingredient similarity
    const ingredientScore = await this.calculateIngredientSimilarity(
      userData,
      menu.contains,
    );
    score += ingredientScore * 0.3;

    return Math.min(score, 1);
  }

  private async calculateTemporalScore(
    menu: any,
    userData?: UserBehaviorData,
  ): Promise<number> {
    const now = new Date();
    const hour = now.getHours();

    // Meal time alignment
    let mealTimeScore = 0;
    switch (menu.meal_time) {
      case 'BREAKFAST':
        mealTimeScore = hour >= 6 && hour <= 10 ? 1 : 0.2;
        break;
      case 'LUNCH':
        mealTimeScore = hour >= 11 && hour <= 14 ? 1 : 0.3;
        break;
      case 'DINNER':
        mealTimeScore = hour >= 17 && hour <= 21 ? 1 : 0.4;
        break;
      case 'SNACK':
        mealTimeScore =
          (hour >= 15 && hour <= 16) || (hour >= 21 && hour <= 23) ? 1 : 0.6;
        break;
    }

    // User time preferences
    let userTimeScore = 0.5;
    if (userData?.timePreferences) {
      userTimeScore = userData.timePreferences[hour.toString()] || 0.5;
    }

    return (mealTimeScore + userTimeScore) / 2;
  }

  // Helper methods
  private async getUserBehaviorData(userId: number): Promise<UserBehaviorData> {
    const cacheKey = `user_behavior:${userId}`;

    return this.cacheService.getOrSet(
      cacheKey,
      async () => {
        // This would typically aggregate data from multiple sources
        // For now, return mock data structure
        return {
          userId: userId.toString(),
          recentOrders: [],
          favoriteMenus: [],
          ratings: [],
          searchHistory: [],
          viewHistory: [],
          timePreferences: {},
          categoryPreferences: {},
        };
      },
      { ttl: 1800 },
    ); // 30 minutes
  }

  private calculateAverageRating(ratings: any[]): number {
    if (!ratings || ratings.length === 0) return 0;
    const sum = ratings.reduce((acc, rating) => acc + rating.rating, 0);
    return sum / ratings.length;
  }

  private async getMenuViewCount(menuId: number): Promise<number> {
    // This would typically come from analytics data
    return Math.floor(Math.random() * 100);
  }

  private async getMenuOrderCount(menuId: number): Promise<number> {
    // This would typically come from order history
    return Math.floor(Math.random() * 50);
  }

  private async findSimilarUsers(userData: UserBehaviorData): Promise<any[]> {
    // This would implement collaborative filtering to find similar users
    return [];
  }

  private async calculateProteinPreference(
    userData: UserBehaviorData,
    proteinTypeId: number,
  ): Promise<number> {
    // Calculate user's preference for this protein type based on history
    return 0.5;
  }

  private async calculateIngredientSimilarity(
    userData: UserBehaviorData,
    contains: any,
  ): Promise<number> {
    // Calculate similarity based on ingredients in user's favorite dishes
    return 0.5;
  }

  private applyBusinessRules(
    menus: MenuRecommendationDto[],
    queryDto: MenuRecommendationQueryDto,
  ): MenuRecommendationDto[] {
    return menus.filter((menu) => {
      // Apply minimum rating filter
      if (queryDto.min_rating && menu.average_rating < queryDto.min_rating) {
        return false;
      }

      // Apply dietary restrictions
      if (queryDto.dietary_restrictions?.length) {
        // This would check menu ingredients against restrictions
        return true; // Simplified for now
      }

      return true;
    });
  }
}
