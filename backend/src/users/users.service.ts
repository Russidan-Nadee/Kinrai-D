import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';

export interface CreateUserDto {
  id: string;
  email: string;
  name?: string;
  phone?: string;
}

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(private prisma: PrismaService) {}

  async createOrUpdateUser(userData: CreateUserDto) {
    this.logger.log(`Creating/updating user: ${userData.email}`);

    try {
      const user = await this.prisma.userProfile.upsert({
        where: {
          id: userData.id,
        },
        update: {
          email: userData.email,
          name: userData.name,
          phone: userData.phone,
          updated_at: new Date(),
        },
        create: {
          id: userData.id,
          email: userData.email,
          name: userData.name,
          phone: userData.phone,
          role: UserRole.USER,
          is_active: true,
        },
      });

      this.logger.log(`User ${user.email} synced successfully`);
      return user;
    } catch (error) {
      this.logger.error(`Failed to sync user ${userData.email}:`, error);
      throw error;
    }
  }

  async getUserById(id: string) {
    return this.prisma.userProfile.findUnique({
      where: { id },
      include: {
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
        Ratings: {
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
      },
    });
  }

  async getUserByEmail(email: string) {
    return this.prisma.userProfile.findUnique({
      where: { email },
    });
  }

  async updateUserProfile(id: string, updateData: Partial<CreateUserDto>) {
    return this.prisma.userProfile.update({
      where: { id },
      data: {
        ...updateData,
        updated_at: new Date(),
      },
    });
  }
}
