import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { AnalyticsQueryDto } from '../dto/analytics-query.dto';

@Injectable()
export class AdminAnalyticsService {
  constructor(private prisma: PrismaService) {}

  async getUserAnalytics(query: AnalyticsQueryDto) {
    const { startDate, endDate } = query;

    const dateFilter = {
      ...(startDate && { gte: new Date(startDate) }),
      ...(endDate && { lte: new Date(endDate) }),
    };

    const [
      userRegistrations,
      usersByRole,
      activeUsers,
    ] = await Promise.all([
      this.prisma.userProfile.groupBy({
        by: ['created_at'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
        orderBy: { created_at: 'asc' },
      }),
      this.prisma.userProfile.groupBy({
        by: ['role'],
        _count: { id: true },
      }),
      this.prisma.userProfile.count({
        where: {
          is_active: true,
          created_at: dateFilter,
        },
      }),
    ]);

    return {
      registrations: userRegistrations,
      usersByRole,
      activeUsers,
    };
  }

  async getMenuAnalytics(query: AnalyticsQueryDto) {
    const { startDate, endDate } = query;

    const dateFilter = {
      ...(startDate && { gte: new Date(startDate) }),
      ...(endDate && { lte: new Date(endDate) }),
    };

    const [
      menusByCategory,
      menusByMealTime,
      activeMenus,
      totalMenus,
    ] = await Promise.all([
      this.prisma.menu.groupBy({
        by: ['subcategory_id'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
      }),
      this.prisma.menu.groupBy({
        by: ['meal_time'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
      }),
      this.prisma.menu.count({
        where: {
          is_active: true,
          created_at: dateFilter,
        },
      }),
      this.prisma.menu.count({
        where: {
          created_at: dateFilter,
        },
      }),
    ]);

    return {
      menusByCategory,
      menusByMealTime,
      activeMenus,
      totalMenus,
    };
  }

  async getRatingAnalytics(query: AnalyticsQueryDto) {
    const { startDate, endDate } = query;

    const dateFilter = {
      ...(startDate && { gte: new Date(startDate) }),
      ...(endDate && { lte: new Date(endDate) }),
    };

    const [
      avgRating,
      ratingDistribution,
      totalRatings,
      topRatedMenus,
    ] = await Promise.all([
      this.prisma.menuRating.aggregate({
        _avg: { rating: true },
        where: {
          created_at: dateFilter,
        },
      }),
      this.prisma.menuRating.groupBy({
        by: ['rating'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
        orderBy: { rating: 'asc' },
      }),
      this.prisma.menuRating.count({
        where: {
          created_at: dateFilter,
        },
      }),
      this.prisma.menu.findMany({
        take: 10,
        include: {
          Translations: {
            where: { language: 'en' },
          },
          Ratings: {
            where: {
              created_at: dateFilter,
            },
          },
        },
      }),
    ]);

    const processedTopRated = topRatedMenus
      .map(menu => ({
        ...menu,
        avgRating: menu.Ratings.length > 0 
          ? menu.Ratings.reduce((sum, r) => sum + r.rating, 0) / menu.Ratings.length 
          : 0,
        totalRatings: menu.Ratings.length,
      }))
      .filter(menu => menu.totalRatings > 0)
      .sort((a, b) => b.avgRating - a.avgRating)
      .slice(0, 10);

    return {
      averageRating: avgRating._avg.rating || 0,
      ratingDistribution,
      totalRatings,
      topRatedMenus: processedTopRated,
    };
  }

  async getPopularItems(query: AnalyticsQueryDto) {
    const { startDate, endDate, limit = 10 } = query;

    const dateFilter = {
      ...(startDate && { gte: new Date(startDate) }),
      ...(endDate && { lte: new Date(endDate) }),
    };

    const [
      mostFavorited,
      mostRated,
    ] = await Promise.all([
      this.prisma.menu.findMany({
        take: limit,
        include: {
          Translations: {
            where: { language: 'en' },
          },
          Favorites: {
            where: {
              created_at: dateFilter,
            },
          },
          _count: {
            select: {
              Favorites: {
                where: {
                  created_at: dateFilter,
                },
              },
            },
          },
        },
        orderBy: {
          Favorites: {
            _count: 'desc',
          },
        },
      }),
      this.prisma.menu.findMany({
        take: limit,
        include: {
          Translations: {
            where: { language: 'en' },
          },
          Ratings: {
            where: {
              created_at: dateFilter,
            },
          },
          _count: {
            select: {
              Ratings: {
                where: {
                  created_at: dateFilter,
                },
              },
            },
          },
        },
        orderBy: {
          Ratings: {
            _count: 'desc',
          },
        },
      }),
    ]);

    return {
      mostFavorited,
      mostRated,
    };
  }

  async getTrends(query: AnalyticsQueryDto) {
    const { startDate, endDate } = query;

    const dateFilter = {
      ...(startDate && { gte: new Date(startDate) }),
      ...(endDate && { lte: new Date(endDate) }),
    };

    const [
      dailyFavorites,
      dailyRatings,
      dailyRegistrations,
    ] = await Promise.all([
      this.prisma.favoriteMenu.groupBy({
        by: ['created_at'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
        orderBy: { created_at: 'asc' },
      }),
      this.prisma.menuRating.groupBy({
        by: ['created_at'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
        orderBy: { created_at: 'asc' },
      }),
      this.prisma.userProfile.groupBy({
        by: ['created_at'],
        _count: { id: true },
        where: {
          created_at: dateFilter,
        },
        orderBy: { created_at: 'asc' },
      }),
    ]);

    return {
      dailyFavorites,
      dailyRatings,
      dailyRegistrations,
    };
  }
}