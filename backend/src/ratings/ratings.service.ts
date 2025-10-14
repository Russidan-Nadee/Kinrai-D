import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { UpdateRatingDto } from './dto/update-rating.dto';
import { RatingSummaryDto } from './dto/rating-summary.dto';

@Injectable()
export class RatingsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, createRatingDto: CreateRatingDto) {
    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    const menu = await this.prisma.menu.findUnique({
      where: { id: createRatingDto.menu_id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    try {
      return await this.prisma.menuRating.create({
        data: {
          user_profile_id: userId,
          ...createRatingDto,
        },
        include: {
          Menu: {
            include: {
              Subcategory: {
                include: {
                  Translations: true,
                },
              },
              ProteinType: {
                include: {
                  Translations: true,
                },
              },
            },
          },
          UserProfile: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('Rating for this menu already exists');
      }
      throw error;
    }
  }

  async findAll(menuId?: number, userId?: string, language = 'en') {
    const where: any = {};
    if (menuId) where.menu_id = menuId;
    if (userId) where.user_profile_id = userId;

    return await this.prisma.menuRating.findMany({
      where,
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: {
                  where: { language },
                },
              },
            },
            ProteinType: {
              include: {
                Translations: {
                  where: { language },
                },
              },
            },
          },
        },
        UserProfile: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async findOne(id: number) {
    const rating = await this.prisma.menuRating.findUnique({
      where: { id },
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: true,
              },
            },
            ProteinType: {
              include: {
                Translations: true,
              },
            },
          },
        },
        UserProfile: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });

    if (!rating) {
      throw new NotFoundException('Rating not found');
    }

    return rating;
  }

  async findUserRating(userId: string, menuId: number) {
    const rating = await this.prisma.menuRating.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: menuId,
      },
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: true,
              },
            },
            ProteinType: {
              include: {
                Translations: true,
              },
            },
          },
        },
      },
    });

    if (!rating) {
      throw new NotFoundException('Rating not found');
    }

    return rating;
  }

  async update(
    userId: string,
    menuId: number,
    updateRatingDto: UpdateRatingDto,
  ) {
    const rating = await this.prisma.menuRating.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: menuId,
      },
    });

    if (!rating) {
      throw new NotFoundException('Rating not found');
    }

    return await this.prisma.menuRating.update({
      where: { id: rating.id },
      data: updateRatingDto,
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: true,
              },
            },
            ProteinType: {
              include: {
                Translations: true,
              },
            },
          },
        },
      },
    });
  }

  async remove(userId: string, menuId: number) {
    const rating = await this.prisma.menuRating.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: menuId,
      },
    });

    if (!rating) {
      throw new NotFoundException('Rating not found');
    }

    return await this.prisma.menuRating.delete({
      where: { id: rating.id },
    });
  }

  async getMenuRatingSummary(menuId: number): Promise<RatingSummaryDto> {
    const menu = await this.prisma.menu.findUnique({
      where: { id: menuId },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    const ratings = await this.prisma.menuRating.findMany({
      where: { menu_id: menuId },
      select: { rating: true },
    });

    const totalRatings = ratings.length;
    const averageRating =
      totalRatings > 0
        ? ratings.reduce((sum, r) => sum + r.rating, 0) / totalRatings
        : 0;

    const ratingDistribution = {
      1: ratings.filter((r) => r.rating === 1).length,
      2: ratings.filter((r) => r.rating === 2).length,
      3: ratings.filter((r) => r.rating === 3).length,
      4: ratings.filter((r) => r.rating === 4).length,
      5: ratings.filter((r) => r.rating === 5).length,
    };

    return {
      menu_id: menuId,
      total_ratings: totalRatings,
      average_rating: Math.round(averageRating * 100) / 100,
      rating_distribution: ratingDistribution,
    };
  }

  async getUserRatings(userId: string, language = 'en') {
    return await this.prisma.menuRating.findMany({
      where: { user_profile_id: userId },
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: {
                  where: { language },
                },
              },
            },
            ProteinType: {
              include: {
                Translations: {
                  where: { language },
                },
              },
            },
          },
        },
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async getTopRatedMenus(limit = 10, language = 'en') {
    const topRated = await this.prisma.menuRating.groupBy({
      by: ['menu_id'],
      _avg: {
        rating: true,
      },
      _count: {
        rating: true,
      },
      having: {
        rating: {
          _count: {
            gte: 3, // At least 3 ratings
          },
        },
      },
      orderBy: {
        _avg: {
          rating: 'desc',
        },
      },
      take: limit,
    });

    const menuIds = topRated.map((item) => item.menu_id);

    const menus = await this.prisma.menu.findMany({
      where: {
        id: { in: menuIds },
        is_active: true,
      },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language },
            },
          },
        },
      },
    });

    return menus
      .map((menu) => {
        const ratingData = topRated.find((item) => item.menu_id === menu.id);
        return {
          ...menu,
          average_rating: ratingData?._avg.rating || 0,
          total_ratings: ratingData?._count.rating || 0,
        };
      })
      .sort((a, b) => b.average_rating - a.average_rating);
  }
}
