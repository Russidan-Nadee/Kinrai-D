import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import {
  CreateFoodTypeDto,
  UpdateFoodTypeDto,
  CreateCategoryDto,
  UpdateCategoryDto,
  CreateSubcategoryDto,
  UpdateSubcategoryDto,
  CreateProteinTypeDto,
  UpdateProteinTypeDto,
} from '../dto/bulk-upload.dto';

@Injectable()
export class AdminFoodManagementService {
  constructor(private prisma: PrismaService) {}

  async getFoodTypes(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const [foodTypes, total] = await Promise.all([
      this.prisma.foodType.findMany({
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          Translations: true,
          _count: {
            select: {
              Categories: true,
            },
          },
        },
      }),
      this.prisma.foodType.count(),
    ]);

    return {
      foodTypes,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getFoodTypeById(id: number) {
    const foodType = await this.prisma.foodType.findUnique({
      where: { id },
      include: {
        Translations: true,
        Categories: {
          include: {
            Translations: true,
          },
        },
      },
    });

    if (!foodType) {
      throw new NotFoundException('Food type not found');
    }

    return foodType;
  }

  async createFoodType(createFoodTypeDto: CreateFoodTypeDto) {
    const { translations, ...foodTypeData } = createFoodTypeDto;

    return this.prisma.foodType.create({
      data: {
        ...foodTypeData,
        Translations: {
          create: translations,
        },
      },
      include: {
        Translations: true,
      },
    });
  }

  async updateFoodType(id: number, updateFoodTypeDto: UpdateFoodTypeDto) {
    const { translations, ...foodTypeData } = updateFoodTypeDto;

    const foodType = await this.prisma.foodType.findUnique({
      where: { id },
    });

    if (!foodType) {
      throw new NotFoundException('Food type not found');
    }

    if (translations) {
      await this.prisma.foodTypeTranslation.deleteMany({
        where: { food_type_id: id },
      });
    }

    return this.prisma.foodType.update({
      where: { id },
      data: {
        ...foodTypeData,
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

  async deleteFoodType(id: number) {
    const foodType = await this.prisma.foodType.findUnique({
      where: { id },
    });

    if (!foodType) {
      throw new NotFoundException('Food type not found');
    }

    return this.prisma.foodType.delete({
      where: { id },
    });
  }

  async getCategories(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const [categories, total] = await Promise.all([
      this.prisma.category.findMany({
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          Translations: true,
          FoodType: {
            include: {
              Translations: {
                where: { language: 'en' },
              },
            },
          },
          _count: {
            select: {
              Subcategories: true,
            },
          },
        },
      }),
      this.prisma.category.count(),
    ]);

    return {
      categories,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getCategoryById(id: number) {
    const category = await this.prisma.category.findUnique({
      where: { id },
      include: {
        Translations: true,
        FoodType: {
          include: {
            Translations: true,
          },
        },
        Subcategories: {
          include: {
            Translations: true,
          },
        },
      },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return category;
  }

  async createCategory(createCategoryDto: CreateCategoryDto) {
    const { translations, ...categoryData } = createCategoryDto;

    return this.prisma.category.create({
      data: {
        ...categoryData,
        Translations: {
          create: translations,
        },
      },
      include: {
        Translations: true,
      },
    });
  }

  async updateCategory(id: number, updateCategoryDto: UpdateCategoryDto) {
    const { translations, ...categoryData } = updateCategoryDto;

    const category = await this.prisma.category.findUnique({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    if (translations) {
      await this.prisma.categoryTranslation.deleteMany({
        where: { category_id: id },
      });
    }

    return this.prisma.category.update({
      where: { id },
      data: {
        ...categoryData,
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

  async deleteCategory(id: number) {
    const category = await this.prisma.category.findUnique({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return this.prisma.category.delete({
      where: { id },
    });
  }

  async getSubcategories(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const [subcategories, total] = await Promise.all([
      this.prisma.subcategory.findMany({
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          Translations: true,
          Category: {
            include: {
              Translations: {
                where: { language: 'en' },
              },
              FoodType: {
                include: {
                  Translations: {
                    where: { language: 'en' },
                  },
                },
              },
            },
          },
          _count: {
            select: {
              Menus: true,
            },
          },
        },
      }),
      this.prisma.subcategory.count(),
    ]);

    return {
      subcategories,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getSubcategoryById(id: number) {
    const subcategory = await this.prisma.subcategory.findUnique({
      where: { id },
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
        Menus: {
          include: {
            Translations: {
              where: { language: 'en' },
            },
          },
        },
      },
    });

    if (!subcategory) {
      throw new NotFoundException('Subcategory not found');
    }

    return subcategory;
  }

  async createSubcategory(createSubcategoryDto: CreateSubcategoryDto) {
    const { translations, ...subcategoryData } = createSubcategoryDto;

    return this.prisma.subcategory.create({
      data: {
        ...subcategoryData,
        Translations: {
          create: translations,
        },
      },
      include: {
        Translations: true,
      },
    });
  }

  async updateSubcategory(id: number, updateSubcategoryDto: UpdateSubcategoryDto) {
    const { translations, ...subcategoryData } = updateSubcategoryDto;

    const subcategory = await this.prisma.subcategory.findUnique({
      where: { id },
    });

    if (!subcategory) {
      throw new NotFoundException('Subcategory not found');
    }

    if (translations) {
      await this.prisma.subcategoryTranslation.deleteMany({
        where: { subcategory_id: id },
      });
    }

    return this.prisma.subcategory.update({
      where: { id },
      data: {
        ...subcategoryData,
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

  async deleteSubcategory(id: number) {
    const subcategory = await this.prisma.subcategory.findUnique({
      where: { id },
    });

    if (!subcategory) {
      throw new NotFoundException('Subcategory not found');
    }

    return this.prisma.subcategory.delete({
      where: { id },
    });
  }

  async getProteinTypes(page: number = 1, limit: number = 10) {
    const skip = (page - 1) * limit;

    const [proteinTypes, total] = await Promise.all([
      this.prisma.proteinType.findMany({
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          Translations: true,
          _count: {
            select: {
              Menus: true,
            },
          },
        },
      }),
      this.prisma.proteinType.count(),
    ]);

    return {
      proteinTypes,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getProteinTypeById(id: number) {
    const proteinType = await this.prisma.proteinType.findUnique({
      where: { id },
      include: {
        Translations: true,
        Menus: {
          include: {
            Translations: {
              where: { language: 'en' },
            },
          },
        },
      },
    });

    if (!proteinType) {
      throw new NotFoundException('Protein type not found');
    }

    return proteinType;
  }

  async createProteinType(createProteinTypeDto: CreateProteinTypeDto) {
    const { translations, ...proteinTypeData } = createProteinTypeDto;

    return this.prisma.proteinType.create({
      data: {
        ...proteinTypeData,
        Translations: {
          create: translations,
        },
      },
      include: {
        Translations: true,
      },
    });
  }

  async updateProteinType(id: number, updateProteinTypeDto: UpdateProteinTypeDto) {
    const { translations, ...proteinTypeData } = updateProteinTypeDto;

    const proteinType = await this.prisma.proteinType.findUnique({
      where: { id },
    });

    if (!proteinType) {
      throw new NotFoundException('Protein type not found');
    }

    if (translations) {
      await this.prisma.proteinTypeTranslation.deleteMany({
        where: { protein_type_id: id },
      });
    }

    return this.prisma.proteinType.update({
      where: { id },
      data: {
        ...proteinTypeData,
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

  async deleteProteinType(id: number) {
    const proteinType = await this.prisma.proteinType.findUnique({
      where: { id },
    });

    if (!proteinType) {
      throw new NotFoundException('Protein type not found');
    }

    return this.prisma.proteinType.delete({
      where: { id },
    });
  }
}