import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateMenuDto,
  UpdateMenuDto,
  MenuQueryDto,
  BulkMenuDto,
} from '../dto/menu-batch.dto';

@Injectable()
export class AdminMenusService {
  constructor(private prisma: PrismaService) {}

  async getMenus(query: MenuQueryDto) {
    const { page = 1, limit = 10, search, subcategory_id, meal_time, is_active } = query;
    const skip = (page - 1) * limit;

    const where: any = {};
    
    if (search) {
      where.OR = [
        { key: { contains: search, mode: 'insensitive' } },
        {
          Translations: {
            some: {
              name: { contains: search, mode: 'insensitive' },
            },
          },
        },
      ];
    }

    if (subcategory_id) {
      where.subcategory_id = subcategory_id;
    }

    if (meal_time) {
      where.meal_time = meal_time;
    }

    if (is_active !== undefined) {
      where.is_active = is_active;
    }

    const [menus, total] = await Promise.all([
      this.prisma.menu.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          Translations: true,
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
          _count: {
            select: {
              Favorites: true,
              Ratings: true,
            },
          },
        },
      }),
      this.prisma.menu.count({ where }),
    ]);

    return {
      menus,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getMenuById(id: number) {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
      include: {
        Translations: true,
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
        Ratings: {
          include: {
            UserProfile: {
              select: { email: true, name: true },
            },
          },
        },
        _count: {
          select: {
            Favorites: true,
            Ratings: true,
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    return menu;
  }

  async createMenu(createMenuDto: CreateMenuDto) {
    const { translations, ...menuData } = createMenuDto;

    return this.prisma.menu.create({
      data: {
        ...menuData,
        Translations: {
          create: translations,
        },
      },
      include: {
        Translations: true,
      },
    });
  }

  async updateMenu(id: number, updateMenuDto: UpdateMenuDto) {
    const { translations, ...menuData } = updateMenuDto;

    const menu = await this.prisma.menu.findUnique({
      where: { id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    if (translations) {
      await this.prisma.menuTranslation.deleteMany({
        where: { menu_id: id },
      });
    }

    return this.prisma.menu.update({
      where: { id },
      data: {
        ...menuData,
        ...(translations && {
          Translations: {
            create: translations,
          },
        }),
      },
      include: {
        Translations: true,
      },
    });
  }

  async deleteMenu(id: number) {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    return this.prisma.menu.delete({
      where: { id },
    });
  }

  async bulkCreateMenus(bulkMenuDto: BulkMenuDto) {
    const { menus } = bulkMenuDto;
    const results = [];

    for (const menuData of menus) {
      const { translations, ...menu } = menuData;
      
      const createdMenu = await this.prisma.menu.create({
        data: {
          ...menu,
          Translations: {
            create: translations,
          },
        },
        include: {
          Translations: true,
        },
      });

      results.push(createdMenu);
    }

    return {
      created: results.length,
      menus: results,
    };
  }

  async activateMenu(id: number) {
    return this.prisma.menu.update({
      where: { id },
      data: { is_active: true },
    });
  }

  async deactivateMenu(id: number) {
    return this.prisma.menu.update({
      where: { id },
      data: { is_active: false },
    });
  }
}