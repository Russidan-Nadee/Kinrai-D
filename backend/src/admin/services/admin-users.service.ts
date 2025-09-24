import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateUserDto,
  UpdateUserDto,
  UserQueryDto,
} from '../dto/user-management.dto';

@Injectable()
export class AdminUsersService {
  constructor(private prisma: PrismaService) {}

  async getUsers(query: UserQueryDto) {
    const { page = 1, limit = 10, search, role, is_active } = query;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (search) {
      where.OR = [
        { email: { contains: search, mode: 'insensitive' } },
        { name: { contains: search, mode: 'insensitive' } },
      ];
    }

    if (role) {
      where.role = role;
    }

    if (is_active !== undefined) {
      where.is_active = is_active;
    }

    const [users, total] = await Promise.all([
      this.prisma.userProfile.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          _count: {
            select: {
              Favorites: true,
              Ratings: true,
              UserDislikes: true,
            },
          },
        },
      }),
      this.prisma.userProfile.count({ where }),
    ]);

    return {
      users,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getUserById(id: string) {
    const user = await this.prisma.userProfile.findUnique({
      where: { id },
      include: {
        UserDietaryRestrictions: {
          include: {
            DietaryRestriction: {
              include: {
                Translations: {
                  where: { language: 'en' },
                },
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
                    Translations: {
                      where: { language: 'en' },
                    },
                  },
                },
                ProteinType: {
                  include: {
                    Translations: {
                      where: { language: 'en' },
                    },
                  },
                },
              },
            },
          },
        },
        Ratings: {
          include: {
            Menu: {
              include: {
                Subcategory: {
                  include: {
                    Translations: {
                      where: { language: 'en' },
                    },
                  },
                },
                ProteinType: {
                  include: {
                    Translations: {
                      where: { language: 'en' },
                    },
                  },
                },
              },
            },
          },
        },
        _count: {
          select: {
            Favorites: true,
            Ratings: true,
            UserDislikes: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async createUser(createUserDto: CreateUserDto) {
    return this.prisma.userProfile.create({
      data: createUserDto,
    });
  }

  async updateUser(id: string, updateUserDto: UpdateUserDto) {
    const user = await this.prisma.userProfile.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.userProfile.update({
      where: { id },
      data: updateUserDto,
    });
  }

  async deleteUser(id: string) {
    const user = await this.prisma.userProfile.findUnique({
      where: { id },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.userProfile.delete({
      where: { id },
    });
  }

  async activateUser(id: string) {
    return this.prisma.userProfile.update({
      where: { id },
      data: { is_active: true },
    });
  }

  async deactivateUser(id: string) {
    return this.prisma.userProfile.update({
      where: { id },
      data: { is_active: false },
    });
  }
}
