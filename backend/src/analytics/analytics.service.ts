import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AnalyticsReportDto } from './dto/analytics-report.dto';
import { UserStatsDto } from './dto/user-stats.dto';
import { MenuStatsDto } from './dto/menu-stats.dto';

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getUserAnalytics(
    userId: string,
    language = 'en',
  ): Promise<AnalyticsReportDto> {
    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    // Get basic user stats
    const [
      favoritesCount,
      dislikesCount,
      ratingsCount,
      avgRating,
      dietaryRestrictionsCount,
    ] = await Promise.all([
      this.prisma.favoriteMenu.count({ where: { user_profile_id: userId } }),
      this.prisma.userDislike.count({ where: { user_profile_id: userId } }),
      this.prisma.menuRating.count({ where: { user_profile_id: userId } }),
      this.prisma.menuRating.aggregate({
        where: { user_profile_id: userId },
        _avg: { rating: true },
      }),
      this.prisma.userProteinPreference.count({
        where: { user_profile_id: userId },
      }),
    ]);

    // Get activity timeline (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [favoritesTimeline, ratingsTimeline, dislikesTimeline] =
      await Promise.all([
        this.prisma.favoriteMenu.findMany({
          where: {
            user_profile_id: userId,
            created_at: { gte: thirtyDaysAgo },
          },
          select: { created_at: true },
        }),
        this.prisma.menuRating.findMany({
          where: {
            user_profile_id: userId,
            created_at: { gte: thirtyDaysAgo },
          },
          select: { created_at: true },
        }),
        this.prisma.userDislike.findMany({
          where: {
            user_profile_id: userId,
            created_at: { gte: thirtyDaysAgo },
          },
          select: { created_at: true },
        }),
      ]);

    // Process timeline data
    const activityTimeline = this.processActivityTimeline(
      favoritesTimeline,
      ratingsTimeline,
      dislikesTimeline,
    );

    // Get preferences insights
    const [topCategories, mealTimeStats, proteinPreferences] =
      await Promise.all([
        this.getTopCategories(userId, language),
        this.getMealTimeDistribution(userId),
        this.getProteinPreferences(userId, language),
      ]);

    // Get most liked category and meal time
    const mostLikedCategory = topCategories[0]?.category || null;
    const mealTimeEntries = Object.entries(mealTimeStats);
    const mostLikedMealTime =
      mealTimeEntries.length > 0
        ? mealTimeEntries.reduce((a, b) => (a[1] > b[1] ? a : b))[0]
        : 'breakfast';

    return {
      user_stats: {
        total_favorites: favoritesCount,
        total_dislikes: dislikesCount,
        total_ratings: ratingsCount,
        average_rating_given:
          Math.round((avgRating._avg.rating || 0) * 100) / 100,
        dietary_restrictions_count: dietaryRestrictionsCount,
        most_liked_category: mostLikedCategory ?? undefined,
        most_liked_meal_time: mostLikedMealTime,
      },
      activity_timeline: activityTimeline,
      preferences_insight: {
        top_categories: topCategories,
        meal_time_distribution: {
          breakfast: mealTimeStats.breakfast ?? 0,
          lunch: mealTimeStats.lunch ?? 0,
          dinner: mealTimeStats.dinner ?? 0,
          snack: mealTimeStats.snack ?? 0,
        },
        protein_preferences: proteinPreferences,
      },
    };
  }

  async getUserStats(userId: string): Promise<UserStatsDto> {
    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
      include: {
        Favorites: { take: 1, orderBy: { created_at: 'desc' } },
        Ratings: { take: 1, orderBy: { created_at: 'desc' } },
        UserDislikes: { take: 1, orderBy: { created_at: 'desc' } },
        UserProteinPreferences: true,
      },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    const [favoritesCount, dislikesCount, ratingsCount, avgRating] =
      await Promise.all([
        this.prisma.favoriteMenu.count({ where: { user_profile_id: userId } }),
        this.prisma.userDislike.count({ where: { user_profile_id: userId } }),
        this.prisma.menuRating.count({ where: { user_profile_id: userId } }),
        this.prisma.menuRating.aggregate({
          where: { user_profile_id: userId },
          _avg: { rating: true },
        }),
      ]);

    // Calculate profile completion percentage
    let completion = 0;
    if (userProfile.name) completion += 25;
    if (userProfile.phone) completion += 25;
    if (userProfile.UserProteinPreferences.length > 0) completion += 25;
    if (favoritesCount > 0) completion += 25;

    // Get last activity
    const lastActivities = [
      ...userProfile.Favorites.map((f) => f.created_at),
      ...userProfile.Ratings.map((r) => r.created_at),
      ...userProfile.UserDislikes.map((d) => d.created_at),
    ];
    const lastActivity =
      lastActivities.length > 0
        ? new Date(Math.max(...lastActivities.map((d) => d.getTime())))
        : userProfile.created_at;

    return {
      total_favorites: favoritesCount,
      total_dislikes: dislikesCount,
      total_ratings: ratingsCount,
      average_rating_given:
        Math.round((avgRating._avg.rating || 0) * 100) / 100,
      protein_preferences_count: userProfile.UserProteinPreferences.length,
      profile_completion_percentage: completion,
      join_date: userProfile.created_at,
      last_activity: lastActivity,
    };
  }

  async getMenuStats(menuId: number, language = 'en'): Promise<MenuStatsDto> {
    const menu = await this.prisma.menu.findUnique({
      where: { id: menuId },
      include: {
        Subcategory: {
          include: {
            Translations: { where: { language } },
          },
        },
        ProteinType: {
          include: {
            Translations: { where: { language } },
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    const [favoritesCount, dislikesCount, ratingsCount, avgRating] =
      await Promise.all([
        this.prisma.favoriteMenu.count({ where: { menu_id: menuId } }),
        this.prisma.userDislike.count({ where: { menu_id: menuId } }),
        this.prisma.menuRating.count({ where: { menu_id: menuId } }),
        this.prisma.menuRating.aggregate({
          where: { menu_id: menuId },
          _avg: { rating: true },
        }),
      ]);

    // Calculate popularity score (favorites * 3 + ratings * 2 - dislikes)
    const popularityScore =
      favoritesCount * 3 + ratingsCount * 2 - dislikesCount;

    // Generate dynamic menu name
    const subcategoryName =
      menu.Subcategory?.Translations[0]?.name ||
      menu.Subcategory?.key ||
      'Unknown';
    const proteinName = menu.ProteinType?.Translations[0]?.name;
    const menuName = proteinName
      ? `${subcategoryName}${proteinName}`
      : subcategoryName;

    return {
      menu_id: menuId,
      menu_name: menuName,
      total_favorites: favoritesCount,
      total_dislikes: dislikesCount,
      total_ratings: ratingsCount,
      average_rating: Math.round((avgRating._avg.rating || 0) * 100) / 100,
      popularity_score: Math.max(0, popularityScore),
      category: menu.Subcategory.Translations[0]?.name || menu.Subcategory.key,
      meal_time: menu.meal_time,
    };
  }

  async getPersonalizedInsights(userId: string) {
    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    // Get insights based on user behavior
    const [favoritePatterns, ratingPatterns, similarUsers, recommendations] = [
      this.getFavoritePatterns(),
      this.getRatingPatterns(),
      this.findSimilarUsers(),
      this.getPersonalizedRecommendations(),
    ];

    return {
      favorite_patterns: favoritePatterns,
      rating_patterns: ratingPatterns,
      similar_users_count: similarUsers.length,
      recommendations: recommendations.slice(0, 5), // Top 5 recommendations
    };
  }

  private processActivityTimeline(
    favorites: Array<{ created_at: Date }>,
    ratings: Array<{ created_at: Date }>,
    dislikes: Array<{ created_at: Date }>,
  ): Array<{
    date: string;
    favorites_added: number;
    ratings_given: number;
    dislikes_added: number;
  }> {
    const timeline = new Map<
      string,
      {
        date: string;
        favorites_added: number;
        ratings_given: number;
        dislikes_added: number;
      }
    >();

    // Process each activity type
    [...favorites, ...ratings, ...dislikes].forEach((activity) => {
      const date = activity.created_at.toISOString().split('T')[0];
      if (date && !timeline.has(date)) {
        timeline.set(date, {
          date,
          favorites_added: 0,
          ratings_given: 0,
          dislikes_added: 0,
        });
      }
    });

    favorites.forEach((fav) => {
      const date = fav.created_at.toISOString().split('T')[0];
      const entry = timeline.get(date);
      if (date && entry) {
        entry.favorites_added++;
      }
    });

    ratings.forEach((rating) => {
      const date = rating.created_at.toISOString().split('T')[0];
      const entry = timeline.get(date);
      if (date && entry) {
        entry.ratings_given++;
      }
    });

    dislikes.forEach((dislike) => {
      const date = dislike.created_at.toISOString().split('T')[0];
      const entry = timeline.get(date);
      if (date && entry) {
        entry.dislikes_added++;
      }
    });

    return Array.from(timeline.values()).sort((a, b) =>
      a.date.localeCompare(b.date),
    );
  }

  private async getTopCategories(userId: string, language: string) {
    const favorites = await this.prisma.favoriteMenu.findMany({
      where: { user_profile_id: userId },
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Category: {
                  include: {
                    Translations: { where: { language } },
                  },
                },
              },
            },
          },
        },
      },
    });

    const categoryCount = new Map<string, number>();
    favorites.forEach((fav) => {
      const categoryName =
        fav.Menu.Subcategory.Category.Translations[0]?.name ||
        fav.Menu.Subcategory.Category.key;
      categoryCount.set(
        categoryName,
        (categoryCount.get(categoryName) || 0) + 1,
      );
    });

    return Array.from(categoryCount.entries())
      .map(([category, count]) => ({
        category,
        interaction_count: count,
      }))
      .sort((a, b) => b.interaction_count - a.interaction_count)
      .slice(0, 5);
  }

  private async getMealTimeDistribution(
    userId: string,
  ): Promise<Record<string, number>> {
    const favorites = await this.prisma.favoriteMenu.findMany({
      where: { user_profile_id: userId },
      include: { Menu: { select: { meal_time: true } } },
    });

    const distribution: Record<string, number> = {
      breakfast: 0,
      lunch: 0,
      dinner: 0,
      snack: 0,
    };
    favorites.forEach((fav) => {
      const mealTime = fav.Menu.meal_time.toLowerCase();
      if (Object.prototype.hasOwnProperty.call(distribution, mealTime)) {
        distribution[mealTime]++;
      }
    });

    return distribution;
  }

  private async getProteinPreferences(userId: string, language: string) {
    const favorites = await this.prisma.favoriteMenu.findMany({
      where: { user_profile_id: userId },
      include: {
        Menu: {
          include: {
            ProteinType: {
              include: {
                Translations: { where: { language } },
              },
            },
          },
        },
      },
    });

    const proteinCount = new Map<string, number>();
    favorites.forEach((fav) => {
      if (fav.Menu.ProteinType) {
        const proteinName =
          fav.Menu.ProteinType.Translations[0]?.name ||
          fav.Menu.ProteinType.key;
        proteinCount.set(proteinName, (proteinCount.get(proteinName) || 0) + 1);
      }
    });

    return Array.from(proteinCount.entries())
      .map(([protein_type, count]) => ({
        protein_type,
        preference_score: Math.round((count / favorites.length) * 100),
      }))
      .sort((a, b) => b.preference_score - a.preference_score)
      .slice(0, 3);
  }

  private getFavoritePatterns(): { message: string } {
    // Implementation for analyzing favorite patterns
    return { message: 'Favorite patterns analysis' };
  }

  private getRatingPatterns(): { message: string } {
    // Implementation for analyzing rating patterns
    return { message: 'Rating patterns analysis' };
  }

  private findSimilarUsers(): unknown[] {
    // Implementation for finding similar users
    return [];
  }

  private getPersonalizedRecommendations(): unknown[] {
    // Implementation for personalized recommendations
    return [];
  }
}
