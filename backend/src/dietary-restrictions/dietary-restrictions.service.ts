import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDietaryRestrictionDto } from './dto/create-dietary-restriction.dto';
import { UpdateDietaryRestrictionDto } from './dto/update-dietary-restriction.dto';
import { AssignRestrictionDto } from './dto/assign-restriction.dto';
import { RemoveRestrictionDto } from './dto/remove-restriction.dto';

@Injectable()
export class DietaryRestrictionsService {
  constructor(private prisma: PrismaService) {}

  async create(createDietaryRestrictionDto: CreateDietaryRestrictionDto) {
    try {
      return await this.prisma.dietaryRestriction.create({
        data: createDietaryRestrictionDto,
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException('Dietary restriction key already exists');
      }
      throw error;
    }
  }

  async findAll(language = 'en') {
    return await this.prisma.dietaryRestriction.findMany({
      where: { is_active: true },
      include: {
        Translations: {
          where: { language },
        },
      },
      orderBy: { id: 'asc' },
    });
  }

  async findOne(id: number, language = 'en') {
    const restriction = await this.prisma.dietaryRestriction.findUnique({
      where: { id },
      include: {
        Translations: {
          where: { language },
        },
      },
    });

    if (!restriction) {
      throw new NotFoundException('Dietary restriction not found');
    }

    return restriction;
  }

  async update(
    id: number,
    updateDietaryRestrictionDto: UpdateDietaryRestrictionDto,
  ) {
    const restriction = await this.prisma.dietaryRestriction.findUnique({
      where: { id },
    });

    if (!restriction) {
      throw new NotFoundException('Dietary restriction not found');
    }

    return await this.prisma.dietaryRestriction.update({
      where: { id },
      data: updateDietaryRestrictionDto,
    });
  }

  async remove(id: number) {
    const restriction = await this.prisma.dietaryRestriction.findUnique({
      where: { id },
    });

    if (!restriction) {
      throw new NotFoundException('Dietary restriction not found');
    }

    return await this.prisma.dietaryRestriction.update({
      where: { id },
      data: { is_active: false },
    });
  }

  async assignToUser(
    userId: string,
    assignRestrictionDto: AssignRestrictionDto,
  ) {
    const restriction = await this.prisma.dietaryRestriction.findUnique({
      where: { id: assignRestrictionDto.dietary_restriction_id },
    });

    if (!restriction) {
      throw new NotFoundException('Dietary restriction not found');
    }

    const userProfile = await this.prisma.userProfile.findUnique({
      where: { id: userId },
    });

    if (!userProfile) {
      throw new NotFoundException('User profile not found');
    }

    try {
      return await this.prisma.userDietaryRestriction.create({
        data: {
          user_profile_id: userId,
          dietary_restriction_id: assignRestrictionDto.dietary_restriction_id,
        },
        include: {
          DietaryRestriction: {
            include: {
              Translations: true,
            },
          },
        },
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException(
          'Dietary restriction already assigned to user',
        );
      }
      throw error;
    }
  }

  async removeFromUser(
    userId: string,
    removeRestrictionDto: RemoveRestrictionDto,
  ) {
    const userRestriction = await this.prisma.userDietaryRestriction.findFirst({
      where: {
        user_profile_id: userId,
        dietary_restriction_id: removeRestrictionDto.dietary_restriction_id,
      },
    });

    if (!userRestriction) {
      throw new NotFoundException('User dietary restriction not found');
    }

    return await this.prisma.userDietaryRestriction.delete({
      where: { id: userRestriction.id },
    });
  }

  async getUserRestrictions(userId: string, language = 'en') {
    return await this.prisma.userDietaryRestriction.findMany({
      where: { user_profile_id: userId },
      include: {
        DietaryRestriction: {
          include: {
            Translations: {
              where: { language },
            },
          },
        },
      },
    });
  }
}
