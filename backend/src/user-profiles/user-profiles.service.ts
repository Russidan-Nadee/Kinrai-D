import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
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
      if (error.code === 'P2002') {
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
                Translations: true,
              },
            },
          },
        },
        UserDietaryRestrictions: {
          include: {
            DietaryRestriction: {
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
                Translations: true,
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

  async addDislike(userId: string, createDislikeDto: CreateDislikeDto) {
    const profile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!profile) {
      throw new NotFoundException('User profile not found');
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
              Translations: true,
            },
          },
        },
      });
    } catch (error) {
      if (error.code === 'P2002') {
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
            Translations: {
              where: { language },
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
      this.prisma.userDietaryRestriction.count({
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
}