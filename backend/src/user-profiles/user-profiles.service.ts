import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserProfileDto } from './dto/create-user-profile.dto';
import { UpdateUserProfileDto } from './dto/update-user-profile.dto';
import { CreateDislikeDto } from './dto/create-dislike.dto';
import { RemoveDislikeDto } from './dto/remove-dislike.dto';

@Injectable()
export class UserProfilesService {
  constructor(private prisma: PrismaService) {}

  async create(createUserProfileDto: CreateUserProfileDto) {
    try {
      return await this.prisma.userProfile.create({
        data: createUserProfileDto,
      });
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('User profile already exists');
      }
      throw error;
    }
  }

  async findOne(id: string) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { id },
      include: {
        UserDislikes: {
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
        },
        UserProteinPreferences: {
          include: {
            ProteinType: {
              include: {
                Translations: true,
              },
            },
          },
        },
        Favorites: {
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
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('User profile not found');
    }

    return profile;
  }

  async update(id: string, updateUserProfileDto: UpdateUserProfileDto) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { id },
    });

    if (!profile) {
      throw new NotFoundException('User profile not found');
    }

    return await this.prisma.userProfile.update({
      where: { id },
      data: updateUserProfileDto,
    });
  }

  async remove(id: string) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { id },
    });

    if (!profile) {
      throw new NotFoundException('User profile not found');
    }

    return await this.prisma.userProfile.update({
      where: { id },
      data: { is_active: false },
    });
  }

  async addDislike(
    userId: string,
    createDislikeDto: CreateDislikeDto,
    userEmail: string,
  ) {
    // Auto-create profile if it doesn't exist
    let profile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!profile) {
      profile = await this.prisma.userProfile.create({
        data: {
          id: userId,
          email: userEmail,
          is_active: true,
        },
      });
    }

    const menu = await this.prisma.menu.findUnique({
      where: { id: createDislikeDto.menu_id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    try {
      return await this.prisma.userDislike.create({
        data: {
          user_profile_id: userId,
          ...createDislikeDto,
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
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('Menu already in dislikes');
      }
      throw error;
    }
  }

  async removeDislike(userId: string, removeDislikeDto: RemoveDislikeDto) {
    const dislike = await this.prisma.userDislike.findFirst({
      where: {
        user_profile_id: userId,
        menu_id: removeDislikeDto.menu_id,
      },
    });

    if (!dislike) {
      throw new NotFoundException('Dislike not found');
    }

    return await this.prisma.userDislike.delete({
      where: { id: dislike.id },
    });
  }

  async getUserDislikes(userId: string, language = 'en') {
    return await this.prisma.userDislike.findMany({
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
    });
  }

  async getUserStats(userId: string) {
    const [
      totalDislikes,
      totalFavorites,
      totalRatings,
      averageRating,
      dietaryRestrictions,
    ] = await Promise.all([
      this.prisma.userDislike.count({
        where: { user_profile_id: userId },
      }),
      this.prisma.favoriteMenu.count({
        where: { user_profile_id: userId },
      }),
      this.prisma.menuRating.count({
        where: { user_profile_id: userId },
      }),
      this.prisma.menuRating.aggregate({
        where: { user_profile_id: userId },
        _avg: { rating: true },
      }),
      this.prisma.userProteinPreference.count({
        where: { user_profile_id: userId },
      }),
    ]);

    return {
      totalDislikes,
      totalFavorites,
      totalRatings,
      averageRating: averageRating._avg.rating || 0,
      dietaryRestrictions,
    };
  }

  async removeBulkDislikes(userId: string, menuIds: number[]) {
    if (!menuIds || menuIds.length === 0) {
      throw new Error('No menu IDs provided');
    }

    const result = await this.prisma.userDislike.deleteMany({
      where: {
        user_profile_id: userId,
        menu_id: {
          in: menuIds,
        },
      },
    });

    return {
      message: `Successfully removed ${result.count} dislikes`,
      removedCount: result.count,
    };
  }
}
