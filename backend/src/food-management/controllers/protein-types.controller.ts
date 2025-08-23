import {
  Controller,
  Get,
  Query,
  HttpStatus,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Controller('protein-types')
export class ProteinTypesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async findAll(@Query('lang') language: string = 'en') {
    const proteinTypes = await this.prisma.proteinType.findMany({
      where: {
        is_active: true,
      },
      include: {
        Translations: {
          where: {
            language: language,
          },
        },
      },
      orderBy: {
        id: 'asc',
      },
    });

    const data = proteinTypes.map(proteinType => ({
      id: proteinType.id,
      key: proteinType.key,
      name: proteinType.Translations[0]?.name || proteinType.key,
      is_active: proteinType.is_active,
      created_at: proteinType.created_at,
      updated_at: proteinType.updated_at,
    }));

    return {
      statusCode: HttpStatus.OK,
      message: 'Protein types retrieved successfully',
      data,
      meta: {
        language: language,
        total: data.length,
      }
    };
  }
}