import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@Injectable()
export class CategoriesService {
   constructor(private prisma: PrismaService) { }

   async create(createCategoryDto: CreateCategoryDto) {
      try {
         // Check if food_type exists
         const foodType = await this.prisma.foodType.findUnique({
            where: { id: createCategoryDto.food_type_id }
         });

         if (!foodType) {
            throw new NotFoundException(`Food type with ID ${createCategoryDto.food_type_id} not found`);
         }

         const category = await this.prisma.category.create({
            data: {
               key: createCategoryDto.key,
               food_type_id: createCategoryDto.food_type_id,
               Translations: {
                  create: createCategoryDto.translations
               }
            },
            include: {
               Translations: true,
               FoodType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });
         return category;
      } catch (error) {
         if (error.code === 'P2002') {
            throw new ConflictException('Category key already exists');
         }
         throw error;
      }
   }

   async findAll(language: string = 'en') {
      return this.prisma.category.findMany({
         where: {
            is_active: true,
         },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            FoodType: {
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               }
            }
         },
         orderBy: {
            created_at: 'desc',
         },
      });
   }

   async findOne(id: number, language: string = 'en') {
      const category = await this.prisma.category.findUnique({
         where: { id },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            FoodType: {
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               }
            },
            Subcategories: {
               where: {
                  is_active: true,
               },
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               },
               orderBy: {
                  key: 'asc',
               },
            },
         },
      });

      if (!category) {
         throw new NotFoundException(`Category with ID ${id} not found`);
      }

      return category;
   }

   async update(id: number, updateCategoryDto: UpdateCategoryDto) {
      try {
         // Update main record
         const updateData: any = {};
         if (updateCategoryDto.key) {
            updateData.key = updateCategoryDto.key;
         }
         if (updateCategoryDto.food_type_id) {
            // Check if food_type exists
            const foodType = await this.prisma.foodType.findUnique({
               where: { id: updateCategoryDto.food_type_id }
            });
            if (!foodType) {
               throw new NotFoundException(`Food type with ID ${updateCategoryDto.food_type_id} not found`);
            }
            updateData.food_type_id = updateCategoryDto.food_type_id;
         }
         if (updateCategoryDto.is_active !== undefined) {
            updateData.is_active = updateCategoryDto.is_active;
         }

         const category = await this.prisma.category.update({
            where: { id },
            data: updateData,
            include: {
               Translations: true,
               FoodType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });

         // Update translations if provided
         if (updateCategoryDto.translations) {
            // Delete existing translations
            await this.prisma.categoryTranslation.deleteMany({
               where: { category_id: id }
            });

            // Create new translations
            await this.prisma.categoryTranslation.createMany({
               data: updateCategoryDto.translations.map(translation => ({
                  category_id: id,
                  language: translation.language,
                  name: translation.name,
                  description: translation.description
               }))
            });

            // Fetch updated record with translations
            return this.prisma.category.findUnique({
               where: { id },
               include: {
                  Translations: true,
                  FoodType: {
                     include: {
                        Translations: true
                     }
                  }
               }
            });
         }

         return category;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Category with ID ${id} not found`);
         }
         if (error.code === 'P2002') {
            throw new ConflictException('Category key already exists');
         }
         throw error;
      }
   }

   async remove(id: number) {
      try {
         // Soft delete - set is_active to false
         const category = await this.prisma.category.update({
            where: { id },
            data: {
               is_active: false,
            },
            include: {
               Translations: true,
               FoodType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });
         return category;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Category with ID ${id} not found`);
         }
         throw error;
      }
   }

   async findByFoodType(foodTypeId: number, language: string = 'en') {
      return this.prisma.category.findMany({
         where: {
            food_type_id: foodTypeId,
            is_active: true,
         },
         include: {
            Translations: {
               where: {
                  language: language
               }
            }
         },
         orderBy: {
            key: 'asc',
         },
      });
   }

   async findByKey(key: string, language: string = 'en') {
      const category = await this.prisma.category.findUnique({
         where: { key },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            FoodType: {
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               }
            }
         }
      });

      if (!category) {
         throw new NotFoundException(`Category with key '${key}' not found`);
      }

      return category;
   }

   async findAllWithSubcategories(language: string = 'en') {
      return this.prisma.category.findMany({
         where: {
            is_active: true,
         },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            FoodType: {
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               }
            },
            Subcategories: {
               where: {
                  is_active: true,
               },
               include: {
                  Translations: {
                     where: {
                        language: language
                     }
                  }
               },
               orderBy: {
                  key: 'asc',
               },
            },
         },
         orderBy: {
            created_at: 'desc',
         },
      });
   }
}