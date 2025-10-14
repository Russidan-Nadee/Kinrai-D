import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AddFavoriteDto } from './dto/add-favorite.dto';
import { RemoveFavoriteDto } from './dto/remove-favorite.dto';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async addFavorite(userId: string, addFavoriteDto: AddFavoriteDto) {
    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    const menu = await this.prisma.menu.findUnique({
      where: { id: addFavoriteDto.menu_id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    try {
      return await this.prisma.favoriteMenu.create({
        data: {
          user_profile_id: userId,
          menu_id: addFavoriteDto.menu_id,
        },
        include: {
          Menu: {
            include: {
              Subcategory: {
                include: {
                  Translations: true,
                  Category: {
                    include: {
                      Translations: true,
                      FoodType: {
                        include: {
                          Translations: true,
                        },
                      },
                    },
                  },
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
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('Menu already in favorites');
      }
      throw error;
    }
  }

  async removeFavorite(userId: string, removeFavoriteDto: RemoveFavoriteDto) {
    const favorite = await this.prisma.favoriteMenu.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: removeFavoriteDto.menu_id,
      },
    });

    if (!favorite) {
      throw new NotFoundException('Favorite not found');
    }

    return await this.prisma.favoriteMenu.delete({
      where: { id: favorite.id },
    });
  }

  async getUserFavorites(userId: string, language = 'en') {
    return await this.prisma.favoriteMenu.findMany({
      where: { user_profile_id: userId },
      include: {
        Menu: {
          include: {
            Subcategory: {
              include: {
                Translations: {
                  where: { language },
                },
                Category: {
                  include: {
                    Translations: {
                      where: { language },
                    },
                    FoodType: {
                      include: {
                        Translations: {
                          where: { language },
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

  async checkIsFavorite(userId: string, menuId: number): Promise<boolean> {
    const favorite = await this.prisma.favoriteMenu.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: menuId,
      },
    });

    return !!favorite;
  }

  async getFavoritesByMealTime(
    userId: string,
    mealTime: string,
    language = 'en',
  ) {
    return await this.prisma.favoriteMenu.findMany({
      where: {
        user_profile_id: userId,
        Menu: {
          meal_time: mealTime.toUpperCase() as any,
        },
      },
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
}
