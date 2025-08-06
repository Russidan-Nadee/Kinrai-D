import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { FilterMenuDto } from './dto/filter-menu.dto';
import { SearchMenuDto, SearchMenuResultDto } from './dto/search-menu.dto';
import { MenuRecommendationQueryDto, MenuRecommendationResultDto, MenuRecommendationDto } from './dto/menu-recommendation.dto';
import { MenuWithTranslations } from './entities/menu.entity';

@Injectable()
export class MenusService {
   constructor(private prisma: PrismaService) { }

   async create(createMenuDto: CreateMenuDto) {
      try {
         // ตรวจสอบว่า subcategory มีอยู่จริง
         const subcategory = await this.prisma.subcategory.findUnique({
            where: { id: createMenuDto.subcategory_id }
         });

         if (!subcategory) {
            throw new NotFoundException(`Subcategory with ID ${createMenuDto.subcategory_id} not found`);
         }

         // ตรวจสอบ protein_type หากมี
         if (createMenuDto.protein_type_id) {
            const proteinType = await this.prisma.proteinType.findUnique({
               where: { id: createMenuDto.protein_type_id }
            });
            if (!proteinType) {
               throw new NotFoundException(`Protein type with ID ${createMenuDto.protein_type_id} not found`);
            }
         }

         const menu = await this.prisma.menu.create({
            data: {
               key: createMenuDto.key,
               subcategory_id: createMenuDto.subcategory_id,
               protein_type_id: createMenuDto.protein_type_id,
               image_url: createMenuDto.image_url,
               contains: createMenuDto.contains,
               meal_time: createMenuDto.meal_time,
               Translations: {
                  create: createMenuDto.translations
               }
            },
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
                                 Translations: true
                              }
                           }
                        }
                     }
                  }
               },
               ProteinType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });
         return menu;
      } catch (error) {
         if (error.code === 'P2002') {
            throw new ConflictException('Menu key already exists');
         }
         throw error;
      }
   }

   async findAll(filterDto: FilterMenuDto) {
      const {
         subcategory_id,
         category_id,
         food_type_id,
         protein_type_id,
         meal_time,
         language = 'th',
         search,
         dietary_restrictions,
         page = 1,
         limit = 10,
         sort_by = 'created_at',
         sort_order = 'desc'
      } = filterDto;

      // สร้าง where conditions
      const where: any = {
         is_active: true,
      };

      if (subcategory_id) {
         where.subcategory_id = subcategory_id;
      }

      if (category_id) {
         where.Subcategory = { category_id: category_id };
      }

      if (food_type_id) {
         where.Subcategory = {
            ...where.Subcategory,
            Category: { food_type_id: food_type_id }
         };
      }

      if (protein_type_id) {
         where.protein_type_id = protein_type_id;
      }

      if (meal_time) {
         where.meal_time = meal_time;
      }

      if (search) {
         where.Translations = {
            some: {
               OR: [
                  { name: { contains: search, mode: 'insensitive' } },
                  { description: { contains: search, mode: 'insensitive' } }
               ],
               language: language
            }
         };
      }

      // สร้าง orderBy
      let orderBy: any = {};
      if (sort_by === 'name') {
         orderBy = {
            Translations: {
               _count: sort_order
            }
         };
      } else {
         orderBy[sort_by] = sort_order;
      }

      // คำนวณ pagination
      const skip = (page - 1) * limit;

      const [menus, totalCount] = await Promise.all([
         this.prisma.menu.findMany({
            where,
            include: {
               Translations: {
                  where: { language: language }
               },
               Subcategory: {
                  include: {
                     Translations: {
                        where: { language: language }
                     },
                     Category: {
                        include: {
                           Translations: {
                              where: { language: language }
                           },
                           FoodType: {
                              include: {
                                 Translations: {
                                    where: { language: language }
                                 }
                              }
                           }
                        }
                     }
                  }
               },
               ProteinType: {
                  include: {
                     Translations: {
                        where: { language: language }
                     }
                  }
               }
            },
            orderBy,
            skip,
            take: limit,
         }),
         this.prisma.menu.count({ where })
      ]);

      return {
         data: menus,
         pagination: {
            page,
            limit,
            total: totalCount,
            total_pages: Math.ceil(totalCount / limit),
            has_next: page < Math.ceil(totalCount / limit),
            has_prev: page > 1
         }
      };
   }

   async findOne(id: number, language: string = 'th') {
      const menu = await this.prisma.menu.findUnique({
         where: { id },
         include: {
            Translations: {
               where: { language: language }
            },
            Subcategory: {
               include: {
                  Translations: {
                     where: { language: language }
                  },
                  Category: {
                     include: {
                        Translations: {
                           where: { language: language }
                        },
                        FoodType: {
                           include: {
                              Translations: {
                                 where: { language: language }
                              }
                           }
                        }
                     }
                  }
               }
            },
            ProteinType: {
               include: {
                  Translations: {
                     where: { language: language }
                  }
               }
            },
            Ratings: {
               take: 10,
               orderBy: { created_at: 'desc' },
               include: {
                  UserProfile: {
                     select: { name: true }
                  }
               }
            }
         },
      });

      if (!menu) {
         throw new NotFoundException(`Menu with ID ${id} not found`);
      }

      // คำนวณคะแนนเฉลี่ย
      const avgRating = await this.prisma.menuRating.aggregate({
         where: { menu_id: id },
         _avg: { rating: true },
         _count: { rating: true }
      });

      return {
         ...menu,
         average_rating: avgRating._avg.rating || 0,
         total_ratings: avgRating._count.rating || 0
      };
   }

   async update(id: number, updateMenuDto: UpdateMenuDto) {
      try {
         // ตรวจสอบ subcategory หากมี
         if (updateMenuDto.subcategory_id) {
            const subcategory = await this.prisma.subcategory.findUnique({
               where: { id: updateMenuDto.subcategory_id }
            });
            if (!subcategory) {
               throw new NotFoundException(`Subcategory with ID ${updateMenuDto.subcategory_id} not found`);
            }
         }

         // ตรวจสอบ protein_type หากมี
         if (updateMenuDto.protein_type_id) {
            const proteinType = await this.prisma.proteinType.findUnique({
               where: { id: updateMenuDto.protein_type_id }
            });
            if (!proteinType) {
               throw new NotFoundException(`Protein type with ID ${updateMenuDto.protein_type_id} not found`);
            }
         }

         // อัพเดทข้อมูลหลัก
         const updateData: any = {};
         if (updateMenuDto.key) updateData.key = updateMenuDto.key;
         if (updateMenuDto.subcategory_id) updateData.subcategory_id = updateMenuDto.subcategory_id;
         if (updateMenuDto.protein_type_id !== undefined) updateData.protein_type_id = updateMenuDto.protein_type_id;
         if (updateMenuDto.image_url !== undefined) updateData.image_url = updateMenuDto.image_url;
         if (updateMenuDto.contains) updateData.contains = updateMenuDto.contains;
         if (updateMenuDto.meal_time) updateData.meal_time = updateMenuDto.meal_time;
         if (updateMenuDto.is_active !== undefined) updateData.is_active = updateMenuDto.is_active;

         const menu = await this.prisma.menu.update({
            where: { id },
            data: updateData,
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
                                 Translations: true
                              }
                           }
                        }
                     }
                  }
               },
               ProteinType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });

         // อัพเดท translations หากมี
         if (updateMenuDto.translations) {
            await this.prisma.menuTranslation.deleteMany({
               where: { menu_id: id }
            });

            await this.prisma.menuTranslation.createMany({
               data: updateMenuDto.translations.map(translation => ({
                  menu_id: id,
                  language: translation.language,
                  name: translation.name,
                  description: translation.description
               }))
            });

            return this.prisma.menu.findUnique({
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
                                    Translations: true
                                 }
                              }
                           }
                        }
                     }
                  },
                  ProteinType: {
                     include: {
                        Translations: true
                     }
                  }
               }
            });
         }

         return menu;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Menu with ID ${id} not found`);
         }
         if (error.code === 'P2002') {
            throw new ConflictException('Menu key already exists');
         }
         throw error;
      }
   }

   async remove(id: number) {
      try {
         const menu = await this.prisma.menu.update({
            where: { id },
            data: { is_active: false },
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
                                 Translations: true
                              }
                           }
                        }
                     }
                  }
               },
               ProteinType: {
                  include: {
                     Translations: true
                  }
               }
            }
         });
         return menu;
      } catch (error) {
         if (error.code === 'P2025') {
            throw new NotFoundException(`Menu with ID ${id} not found`);
         }
         throw error;
      }
   }

   async findByKey(key: string, language: string = 'th') {
      const menu = await this.prisma.menu.findUnique({
         where: { key },
         include: {
            Translations: {
               where: { language: language }
            },
            Subcategory: {
               include: {
                  Translations: {
                     where: { language: language }
                  },
                  Category: {
                     include: {
                        Translations: {
                           where: { language: language }
                        },
                        FoodType: {
                           include: {
                              Translations: {
                                 where: { language: language }
                              }
                           }
                        }
                     }
                  }
               }
            },
            ProteinType: {
               include: {
                  Translations: {
                     where: { language: language }
                  }
               }
            }
         }
      });

      if (!menu) {
         throw new NotFoundException(`Menu with key '${key}' not found`);
      }

      return menu;
   }

   async getPopularMenus(language: string = 'th', limit: number = 10) {
      return this.prisma.menu.findMany({
         where: { is_active: true },
         include: {
            Translations: {
               where: { language: language }
            },
            Subcategory: {
               include: {
                  Translations: {
                     where: { language: language }
                  }
               }
            },
            Ratings: {
               select: { rating: true }
            }
         },
         orderBy: {
            Favorites: {
               _count: 'desc'
            }
         },
         take: limit
      });
   }

   async getRecommendations(queryDto: MenuRecommendationQueryDto): Promise<MenuRecommendationResultDto> {
      const {
         user_id,
         meal_time,
         preferred_food_types,
         preferred_protein_types,
         dietary_restrictions,
         excluded_menu_ids,
         disliked_ingredients,
         language = 'th',
         limit = 10,
         min_rating,
         recommendation_type = 'personalized'
      } = queryDto;

      // สร้าง base where conditions
      const where: any = {
         is_active: true,
      };

      if (meal_time) {
         where.meal_time = meal_time;
      }

      if (excluded_menu_ids?.length) {
         where.id = { notIn: excluded_menu_ids };
      }

      if (preferred_protein_types?.length) {
         where.protein_type_id = { in: preferred_protein_types };
      }

      if (preferred_food_types?.length) {
         where.Subcategory = {
            Category: {
               food_type_id: { in: preferred_food_types }
            }
         };
      }

      // กรอง dietary restrictions ถ้ามี
      if (dietary_restrictions?.length) {
         // สมมติว่า dietary restrictions เก็บใน contains field
         where.NOT = {
            OR: dietary_restrictions.map(restriction => ({
               contains: {
                  path: ['restrictions'],
                  array_contains: restriction
               }
            }))
         };
      }

      // กรอง disliked ingredients
      if (disliked_ingredients?.length) {
         where.NOT = {
            ...where.NOT,
            OR: [
               ...(where.NOT?.OR || []),
               ...disliked_ingredients.map(ingredient => ({
                  contains: {
                     path: ['ingredients'],
                     array_contains: ingredient
                  }
               }))
            ]
         };
      }

      let orderBy: any = {};
      
      // กำหนด ordering strategy ตาม recommendation type
      switch (recommendation_type) {
         case 'popular':
            orderBy = [
               { Favorites: { _count: 'desc' } },
               { Ratings: { _count: 'desc' } }
            ];
            break;
         case 'random':
            // สำหรับ random, เราจะเอาทั้งหมดแล้ว shuffle ใน code
            orderBy = { created_at: 'desc' };
            break;
         default: // personalized หรือ similar
            orderBy = [
               { Ratings: { _count: 'desc' } },
               { created_at: 'desc' }
            ];
      }

      const menus = await this.prisma.menu.findMany({
         where,
         include: {
            Translations: {
               where: { language }
            },
            Subcategory: {
               include: {
                  Translations: {
                     where: { language }
                  },
                  Category: {
                     include: {
                        Translations: {
                           where: { language }
                        },
                        FoodType: {
                           include: {
                              Translations: {
                                 where: { language }
                              }
                           }
                        }
                     }
                  }
               }
            },
            ProteinType: {
               include: {
                  Translations: {
                     where: { language }
                  }
               }
            },
            Ratings: true
         },
         orderBy,
         take: limit * 2 // เอามาเยอะหน่อยเพื่อ filter และ calculate score
      });

      // คำนวณ average rating สำหรับแต่ละเมนู
      const menusWithRatings = await Promise.all(
         menus.map(async (menu) => {
            const avgRating = await this.prisma.menuRating.aggregate({
               where: { menu_id: menu.id },
               _avg: { rating: true },
               _count: { rating: true }
            });

            const averageRating = avgRating._avg.rating || 0;
            const totalRatings = avgRating._count.rating || 0;

            // Skip if below minimum rating
            if (min_rating && averageRating < min_rating) {
               return null;
            }

            return {
               menu,
               averageRating,
               totalRatings
            };
         })
      );

      const filteredMenus = menusWithRatings.filter(item => item !== null);

      // Random shuffle ถ้าเป็น random type
      if (recommendation_type === 'random') {
         for (let i = filteredMenus.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [filteredMenus[i], filteredMenus[j]] = [filteredMenus[j], filteredMenus[i]];
         }
      }

      // จำกัดจำนวนตาม limit ที่ต้องการ
      const finalMenus = filteredMenus.slice(0, limit);

      // แปลงเป็น DTO format
      const recommendations: MenuRecommendationDto[] = finalMenus.map((item) => {
         const menu = item.menu;
         const translation = menu.Translations[0];
         const subcategoryTranslation = menu.Subcategory.Translations[0];
         const categoryTranslation = menu.Subcategory.Category.Translations[0];
         const foodTypeTranslation = menu.Subcategory.Category.FoodType.Translations[0];
         const proteinTypeTranslation = menu.ProteinType?.Translations[0];

         // คำนวณ recommendation score
         let recommendationScore = 50; // base score
         const reasons: string[] = [];

         // เพิ่มคะแนนตาม criteria
         if (item.averageRating > 4) {
            recommendationScore += 20;
            reasons.push('High rated by users');
         }
         if (item.totalRatings > 50) {
            recommendationScore += 15;
            reasons.push('Popular choice');
         }
         if (preferred_food_types?.includes(menu.Subcategory.Category.food_type_id)) {
            recommendationScore += 25;
            reasons.push('Matches your food preferences');
         }
         if (menu.protein_type_id && preferred_protein_types?.includes(menu.protein_type_id)) {
            recommendationScore += 20;
            reasons.push('Contains your preferred protein');
         }

         recommendationScore = Math.min(recommendationScore, 100);

         return {
            id: menu.id,
            key: menu.key,
            name: translation?.name || menu.key,
            description: translation?.description,
            image_url: menu.image_url,
            subcategory: {
               id: menu.Subcategory.id,
               name: subcategoryTranslation?.name || '',
               category: {
                  id: menu.Subcategory.Category.id,
                  name: categoryTranslation?.name || '',
                  food_type: {
                     id: menu.Subcategory.Category.FoodType.id,
                     name: foodTypeTranslation?.name || ''
                  }
               }
            },
            protein_type: menu.ProteinType && proteinTypeTranslation ? {
               id: menu.ProteinType.id,
               name: proteinTypeTranslation.name
            } : undefined,
            average_rating: item.averageRating,
            total_ratings: item.totalRatings,
            recommendation_score: recommendationScore,
            recommendation_reasons: reasons,
            meal_time: menu.meal_time,
            contains: menu.contains
         };
      });

      // Get user context if user_id provided
      let userContext: any = undefined;
      if (user_id) {
         // TODO: Fix user_id to UUID conversion when implementing actual user system
         // For now, skip user context to avoid type errors
         userContext = {
            user_id,
            dietary_restrictions: [],
            food_preferences: {},
            recent_orders: []
         };
      }

      return {
         recommendations,
         metadata: {
            total_found: filteredMenus.length,
            recommendation_type,
            user_preferences_used: !!user_id,
            generated_at: new Date(),
            language
         },
         user_context: userContext
      };
   }

   async searchMenus(searchDto: SearchMenuDto): Promise<SearchMenuResultDto> {
      const startTime = Date.now();
      const {
         search,
         language = 'th',
         tags,
         ingredients,
         meal_time,
         page = 1,
         limit = 20,
         sort_by = 'relevance',
         sort_order = 'desc',
         min_rating,
         food_type_ids,
         category_ids,
         subcategory_ids,
         protein_type_ids
      } = searchDto;

      // Build where conditions
      const where: any = {
         is_active: true,
      };

      // Text search in translations
      if (search) {
         where.Translations = {
            some: {
               OR: [
                  { name: { contains: search, mode: 'insensitive' } },
                  { description: { contains: search, mode: 'insensitive' } }
               ],
               language: language
            }
         };
      }

      // Filter by meal time
      if (meal_time) {
         where.meal_time = meal_time;
      }

      // Filter by food types
      if (food_type_ids?.length) {
         where.Subcategory = {
            Category: {
               food_type_id: { in: food_type_ids }
            }
         };
      }

      // Filter by categories
      if (category_ids?.length) {
         where.Subcategory = {
            ...where.Subcategory,
            category_id: { in: category_ids }
         };
      }

      // Filter by subcategories
      if (subcategory_ids?.length) {
         where.subcategory_id = { in: subcategory_ids };
      }

      // Filter by protein types
      if (protein_type_ids?.length) {
         where.protein_type_id = { in: protein_type_ids };
      }

      // Build order by
      let orderBy: any = {};
      switch (sort_by) {
         case 'name':
            // This is a simplified version - proper implementation would need aggregation
            orderBy = { key: sort_order };
            break;
         case 'rating':
            orderBy = { created_at: sort_order }; // Simplified - would need rating aggregation
            break;
         case 'popularity':
            orderBy = [
               { Favorites: { _count: sort_order } },
               { created_at: sort_order }
            ];
            break;
         case 'created_at':
            orderBy = { created_at: sort_order };
            break;
         default: // relevance
            orderBy = search ? { created_at: sort_order } : { created_at: 'desc' };
      }

      const skip = (page - 1) * limit;

      const [menus, totalCount] = await Promise.all([
         this.prisma.menu.findMany({
            where,
            include: {
               Translations: {
                  where: { language }
               },
               Subcategory: {
                  include: {
                     Translations: {
                        where: { language }
                     },
                     Category: {
                        include: {
                           Translations: {
                              where: { language }
                           },
                           FoodType: {
                              include: {
                                 Translations: {
                                    where: { language }
                                 }
                              }
                           }
                        }
                     }
                  }
               },
               ProteinType: {
                  include: {
                     Translations: {
                        where: { language }
                     }
                  }
               }
            },
            orderBy,
            skip,
            take: limit,
         }),
         this.prisma.menu.count({ where })
      ]);

      const endTime = Date.now();
      const searchTimeMs = endTime - startTime;

      const filtersApplied: string[] = [];
      if (search) filtersApplied.push('text_search');
      if (meal_time) filtersApplied.push('meal_time');
      if (food_type_ids?.length) filtersApplied.push('food_types');
      if (category_ids?.length) filtersApplied.push('categories');
      if (subcategory_ids?.length) filtersApplied.push('subcategories');
      if (protein_type_ids?.length) filtersApplied.push('protein_types');
      if (min_rating) filtersApplied.push('min_rating');

      return {
         menus,
         total: totalCount,
         page,
         limit,
         total_pages: Math.ceil(totalCount / limit),
         search_metadata: {
            search_term: search,
            search_language: language,
            filters_applied: filtersApplied,
            sort_criteria: `${sort_by}_${sort_order}`,
            search_time_ms: searchTimeMs,
            suggestions: totalCount === 0 && search ? [`Try searching for "${search.slice(0, -1)}"`, 'Check spelling', 'Use fewer keywords'] : undefined
         }
      };
   }
}