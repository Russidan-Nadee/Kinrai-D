import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SetProteinPreferenceDto } from './dto/set-protein-preference.dto';
import { RemoveProteinPreferenceDto } from './dto/remove-protein-preference.dto';

@Injectable()
export class ProteinPreferencesService {
  constructor(private prisma: PrismaService) {}

  async getAvailableProteinTypes(language = 'en') {
    return await this.prisma.proteinType.findMany({
      where: { is_active: true },
      include: {
        Translations: {
          where: { language },
        },
      },
      orderBy: { id: 'asc' },
    });
  }

  async getUserProteinPreferences(userId: string, language = 'en') {
    return await this.prisma.userProteinPreference.findMany({
      where: { user_profile_id: userId },
      include: {
        ProteinType: {
          include: {
            Translations: {
              where: { language },
            },
          },
        },
      },
    });
  }

  async setProteinPreference(
    userId: string,
    setProteinPreferenceDto: SetProteinPreferenceDto,
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

    const proteinType = await this.prisma.proteinType.findUnique({
      where: { id: setProteinPreferenceDto.protein_type_id },
    });

    if (!proteinType) {
      throw new NotFoundException('Protein type not found');
    }

    try {
      return await this.prisma.userProteinPreference.upsert({
        where: {
          user_profile_id_protein_type_id: {
            user_profile_id: userId,
            protein_type_id: setProteinPreferenceDto.protein_type_id,
          },
        },
        update: {
          exclude: setProteinPreferenceDto.exclude ?? true,
        },
        create: {
          user_profile_id: userId,
          protein_type_id: setProteinPreferenceDto.protein_type_id,
          exclude: setProteinPreferenceDto.exclude ?? true,
        },
        include: {
          ProteinType: {
            include: {
              Translations: true,
            },
          },
        },
      });
    } catch (error) {
      throw error;
    }
  }

  async removeProteinPreference(
    userId: string,
    removeProteinPreferenceDto: RemoveProteinPreferenceDto,
  ) {
    const preference = await this.prisma.userProteinPreference.findFirst({
      where: {
        user_profile_id: userId,
        protein_type_id: removeProteinPreferenceDto.protein_type_id,
      },
    });

    if (!preference) {
      throw new NotFoundException('Protein preference not found');
    }

    return await this.prisma.userProteinPreference.delete({
      where: { id: preference.id },
    });
  }
}
