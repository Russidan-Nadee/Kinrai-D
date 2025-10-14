import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export interface MenuCard {
  id: number;
  name: string;
  subcategory_name: string;
  protein_name: string | null;
  meal_time: string;
  is_active: boolean;
  favorites_count: number;
  ratings_count: number;
  image_url: string | null;
  created_at: Date;
  updated_at: Date;
}

@Injectable()
export class AdminMenusService {
  constructor(private prisma: PrismaService) {}

  async getMenuCards(): Promise<MenuCard[]> {
    const menus = await this.prisma.menu.findMany({
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: 'th' },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: 'th' },
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
      orderBy: { created_at: 'desc' },
    });

    return menus.map((menu) => {
      const subcategoryName =
        menu.Subcategory?.Translations[0]?.name ||
        menu.Subcategory?.key ||
        'Unknown';
      const proteinName = menu.ProteinType?.Translations[0]?.name;
      const displayName = proteinName
        ? `${subcategoryName}${proteinName}`
        : subcategoryName;

      return {
        id: menu.id,
        name: displayName,
        subcategory_name: subcategoryName,
        protein_name: proteinName || null,
        meal_time: menu.meal_time,
        is_active: menu.is_active,
        favorites_count: menu._count.Favorites,
        ratings_count: menu._count.Ratings,
        image_url: menu.image_url,
        created_at: menu.created_at,
        updated_at: menu.updated_at,
      };
    });
  }

  async getMenuCard(id: number): Promise<MenuCard> {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: 'th' },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: 'th' },
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

    const subcategoryName =
      menu.Subcategory?.Translations[0]?.name ||
      menu.Subcategory?.key ||
      'Unknown';
    const proteinName = menu.ProteinType?.Translations[0]?.name;
    const displayName = proteinName
      ? `${subcategoryName}${proteinName}`
      : subcategoryName;

    return {
      id: menu.id,
      name: displayName,
      subcategory_name: subcategoryName,
      protein_name: proteinName || null,
      meal_time: menu.meal_time,
      is_active: menu.is_active,
      favorites_count: menu._count.Favorites,
      ratings_count: menu._count.Ratings,
      image_url: menu.image_url,
      created_at: menu.created_at,
      updated_at: menu.updated_at,
    };
  }

  async toggleMenuStatus(id: number): Promise<MenuCard> {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    await this.prisma.menu.update({
      where: { id },
      data: { is_active: !menu.is_active },
    });

    return this.getMenuCard(id);
  }

  async deleteMenu(id: number): Promise<{ success: boolean }> {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
    });

    if (!menu) {
      throw new NotFoundException('Menu not found');
    }

    await this.prisma.menu.delete({
      where: { id },
    });

    return { success: true };
  }
}
