import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateFoodTypeDto } from '../dto/create-food-type.dto';
import { UpdateFoodTypeDto } from '../dto/update-food-type.dto';

@Injectable()
export class FoodTypesService {
   constructor(private prisma: PrismaService) { }

   async create(createFoodTypeDto: CreateFoodTypeDto) {
      try {
         const foodType = await this.prisma.foodType.create({
            data: {
               key: createFoodTypeDto.key,
               Translations: {
                  create: createFoodTypeDto.translations
               }
            },
            include: {
               Translations: true
            }
         });
         return foodType;
      } catch (error) {
         if (error.code === 'P2002') {
            throw new ConflictException('Food type key already exists');
         }
         throw error;
      }
   }

   async findAll(language: string = 'th') {
      return this.prisma.foodType.findMany({
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
            created_at: 'desc',
         },
      });
   }

   async findOne(id: number, language: string = 'th') {
      const foodType = await this.prisma.foodType.findUnique({
         where: { id },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            Categories: {
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

      if (!foodType) {
         throw new NotFoundException(`Food type with ID ${id} not found`);
      }

      return foodType;
   }

   async update(id: number, updateFoodTypeDto: UpdateFoodTypeDto) {
      try {
         // Update main record
         const updateData: any = {};
         if (updateFoodTypeDto.key) {
            updateData.key = updateFoodTypeDto.key;
         }
         if (updateFoodTypeDto.is_active !== undefined) {
            updateData.is_active = updateFoodTypeDto.is_active;
         }

         const foodType = await this.prisma.foodType.update({
            where: { id },
            data: updateData,
            include: {
               Translations: true
            }
         });

         // Update translations if provided
         if (updateFoodTypeDto.translations) {
            // Delete existing translations
            await this.prisma.foodTypeTranslation.deleteMany({
               where: { food_type_id: id }
            });

            // Create new translations
            await this.prisma.foodTypeTranslation.createMany({
               data: updateFoodTypeDto.translations.map(translation => ({
                  food_type_id: id,
                  language: translation.language,
                  name: translation.name,
                  description: translation.description
               }))
            });

            // Fetch updated record with translations
            return this.prisma.foodType.findUnique({
               where: { id },
               include: {
                  Translations: true
               }
            });
         }

         return foodType;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Food type with ID ${id} not found`);
         }
         if (error.code === 'P2002') {
            throw new ConflictException('Food type key already exists');
         }
         throw error;
      }
   }

   async remove(id: number) {
      try {
         // Soft delete - set is_active to false
         const foodType = await this.prisma.foodType.update({
            where: { id },
            data: {
               is_active: false,
            },
            include: {
               Translations: true
            }
         });
         return foodType;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Food type with ID ${id} not found`);
         }
         throw error;
      }
   }

   async findAllWithCategories(language: string = 'th') {
      return this.prisma.foodType.findMany({
         where: {
            is_active: true,
         },
         include: {
            Translations: {
               where: {
                  language: language
               }
            },
            Categories: {
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

   async findAllLanguages() {
      const languages = await this.prisma.foodTypeTranslation.findMany({
         select: {
            language: true
         },
         distinct: ['language']
      });

      return languages.map(l => l.language);
   }

   async findByKey(key: string, language: string = 'th') {
      const foodType = await this.prisma.foodType.findUnique({
         where: { key },
         include: {
            Translations: {
               where: {
                  language: language
               }
            }
         }
      });

      if (!foodType) {
         throw new NotFoundException(`Food type with key '${key}' not found`);
      }

      return foodType;
   }
}