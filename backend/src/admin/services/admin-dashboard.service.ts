import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminDashboardService {
  constructor(private prisma: PrismaService) {}

  async getSystemStats() {
    const [
      totalUsers,
      activeUsers,
      totalMenus,
      activeMenus,
      totalRatings,
      totalFavorites,
    ] = await Promise.all([
      this.prisma.userProfile.count(),
      this.prisma.userProfile.count({ where: { is_active: true } }),
      this.prisma.menu.count(),
      this.prisma.menu.count({ where: { is_active: true } }),
      this.prisma.menuRating.count(),
      this.prisma.favoriteMenu.count(),
    ]);

    return {
      users: {
        total: totalUsers,
        active: activeUsers,
        inactive: totalUsers - activeUsers,
      },
      menus: {
        total: totalMenus,
        active: activeMenus,
        inactive: totalMenus - activeMenus,
      },
      engagement: {
        ratings: totalRatings,
        favorites: totalFavorites,
      },
    };
  }

  async getRecentActivity() {
    const [recentUsers, recentRatings, recentFavorites] = await Promise.all([
      this.prisma.userProfile.findMany({
        take: 5,
        orderBy: { created_at: 'desc' },
        select: {
          id: true,
          email: true,
          name: true,
          created_at: true,
        },
      }),
      this.prisma.menuRating.findMany({
        take: 5,
        orderBy: { created_at: 'desc' },
        include: {
          UserProfile: {
            select: { email: true, name: true },
          },
          Menu: {
            include: {
              Translations: {
                where: { language: 'en' },
                select: { name: true },
              },
            },
          },
        },
      }),
      this.prisma.favoriteMenu.findMany({
        take: 5,
        orderBy: { created_at: 'desc' },
        include: {
          UserProfile: {
            select: { email: true, name: true },
          },
          Menu: {
            include: {
              Translations: {
                where: { language: 'en' },
                select: { name: true },
              },
            },
          },
        },
      }),
    ]);

    return {
      recentUsers,
      recentRatings,
      recentFavorites,
    };
  }
}