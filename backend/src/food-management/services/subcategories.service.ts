import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateSubcategoryDto } from '../dto/create-subcategory.dto';
import { UpdateSubcategoryDto } from '../dto/update-subcategory.dto';

@Injectable()
export class SubcategoriesService {
  constructor(private prisma: PrismaService) {}

  async create(createSubcategoryDto: CreateSubcategoryDto) {
    try {
      // ตรวจสอบว่า category มีอยู่จริง
      const category = await this.prisma.category.findUnique({
        where: { id: createSubcategoryDto.category_id },
      });

      if (!category) {
        throw new NotFoundException(
          `Category with ID ${createSubcategoryDto.category_id} not found`,
        );
      }

      const subcategory = await this.prisma.subcategory.create({
        data: {
          key: createSubcategoryDto.key,
          category_id: createSubcategoryDto.category_id,
          Translations: {
            create: createSubcategoryDto.translations,
          },
        },
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
      });
      return subcategory;
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('Subcategory key already exists');
      }
      throw error;
    }
  }

  async findAll(language: string = 'th') {
    return this.prisma.subcategory.findMany({
      where: {
        is_active: true,
      },
      include: {
        Translations: {
          where: {
            language: language,
          },
        },
        Category: {
          include: {
            Translations: {
              where: {
                language: language,
              },
            },
            FoodType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: {
        created_at: 'desc',
      },
    });
  }

  async findOne(id: number, language: string = 'th') {
    const subcategory = await this.prisma.subcategory.findUnique({
      where: { id },
      include: {
        Translations: {
          where: {
            language: language,
          },
        },
        Category: {
          include: {
            Translations: {
              where: {
                language: language,
              },
            },
            FoodType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
        },
        Menus: {
          where: {
            is_active: true,
          },
          include: {
            Subcategory: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
            ProteinType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
          orderBy: {
            id: 'asc',
          },
        },
      },
    });

    if (!subcategory) {
      throw new NotFoundException(`Subcategory with ID ${id} not found`);
    }

    return subcategory;
  }

  async update(id: number, updateSubcategoryDto: UpdateSubcategoryDto) {
    try {
      // อัพเดทข้อมูลหลัก
      const updateData: any = {};
      if (updateSubcategoryDto.key) {
        updateData.key = updateSubcategoryDto.key;
      }
      if (updateSubcategoryDto.category_id) {
        // ตรวจสอบว่า category มีอยู่จริง
        const category = await this.prisma.category.findUnique({
          where: { id: updateSubcategoryDto.category_id },
        });
        if (!category) {
          throw new NotFoundException(
            `Category with ID ${updateSubcategoryDto.category_id} not found`,
          );
        }
        updateData.category_id = updateSubcategoryDto.category_id;
      }
      if (updateSubcategoryDto.is_active !== undefined) {
        updateData.is_active = updateSubcategoryDto.is_active;
      }

      const subcategory = await this.prisma.subcategory.update({
        where: { id },
        data: updateData,
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
      });

      // อัพเดท translations หากมี
      if (updateSubcategoryDto.translations) {
        // ลบ translations เก่า
        await this.prisma.subcategoryTranslation.deleteMany({
          where: { subcategory_id: id },
        });

        // สร้าง translations ใหม่
        await this.prisma.subcategoryTranslation.createMany({
          data: updateSubcategoryDto.translations.map((translation) => ({
            subcategory_id: id,
            language: translation.language,
            name: translation.name,
            description: translation.description,
          })),
        });

        // ดึงข้อมูลที่อัพเดทแล้วพร้อม translations
        return this.prisma.subcategory.findUnique({
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
          },
        });
      }

      return subcategory;
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2025') {
        throw new NotFoundException(`Subcategory with ID ${id} not found`);
      }
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException('Subcategory key already exists');
      }
      throw error;
    }
  }

  async remove(id: number) {
    try {
      // Soft delete - ตั้ง is_active เป็น false
      const subcategory = await this.prisma.subcategory.update({
        where: { id },
        data: {
          is_active: false,
        },
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
      });
      return subcategory;
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2025') {
        throw new NotFoundException(`Subcategory with ID ${id} not found`);
      }
      throw error;
    }
  }

  async findByCategory(categoryId: number, language: string = 'th') {
    return this.prisma.subcategory.findMany({
      where: {
        category_id: categoryId,
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
        key: 'asc',
      },
    });
  }

  async findByKey(key: string, language: string = 'th') {
    const subcategory = await this.prisma.subcategory.findUnique({
      where: { key },
      include: {
        Translations: {
          where: {
            language: language,
          },
        },
        Category: {
          include: {
            Translations: {
              where: {
                language: language,
              },
            },
            FoodType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!subcategory) {
      throw new NotFoundException(`Subcategory with key '${key}' not found`);
    }

    return subcategory;
  }

  async findAllWithMenus(language: string = 'th') {
    return this.prisma.subcategory.findMany({
      where: {
        is_active: true,
      },
      include: {
        Translations: {
          where: {
            language: language,
          },
        },
        Category: {
          include: {
            Translations: {
              where: {
                language: language,
              },
            },
            FoodType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
        },
        Menus: {
          where: {
            is_active: true,
          },
          include: {
            Subcategory: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
            ProteinType: {
              include: {
                Translations: {
                  where: {
                    language: language,
                  },
                },
              },
            },
          },
          orderBy: {
            id: 'asc',
          },
        },
      },
      orderBy: {
        created_at: 'desc',
      },
    });
  }
}
