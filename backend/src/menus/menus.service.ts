import { Injectable, NotFoundException, ConflictException, UseInterceptors } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LanguageService } from '../common/services/language.service';
import { CacheService } from '../common/services/cache.service';
import { LoggingService } from '../common/services/logging.service';
import { DEFAULT_LANGUAGE } from '../common/constants/languages';
import { Cacheable, CacheEvict, CacheEvictByTags } from '../common/decorators/cache.decorator';
import { CacheInterceptor } from '../common/interceptors/cache.interceptor';
import { LoggingInterceptor } from '../common/interceptors/logging.interceptor';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { FilterMenuDto } from './dto/filter-menu.dto';
import { SearchMenuDto, SearchMenuResultDto } from './dto/search-menu.dto';
import { MenuRecommendationQueryDto, MenuRecommendationResultDto, MenuRecommendationDto } from './dto/menu-recommendation.dto';
import { MenuWithTranslations } from './entities/menu.entity';
import { RecommendationService } from './services/recommendation.service';
import { MealTime } from './dto/create-menu.dto';

@Injectable()
@UseInterceptors(CacheInterceptor, LoggingInterceptor)
export class MenusService {
   constructor(
      private prisma: PrismaService,
      private languageService: LanguageService,
      private cacheService: CacheService,
      private loggingService: LoggingService,
      private recommendationService: RecommendationService
   ) { }

   @CacheEvictByTags(['menus', 'menu_list'])
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

   @Cacheable({ 
      key: 'menus:findAll', 
      ttl: 900, // 15 minutes
      tags: ['menus', 'menu_list']
   })
   async findAll(filterDto: FilterMenuDto) {
      const {
         subcategory_id,
         category_id,
         food_type_id,
         protein_type_id,
         meal_time,
         language = DEFAULT_LANGUAGE,
         search,
         dietary_restrictions,
         page = 1,
         limit = 10,
         sort_by = 'created_at',
         sort_order = 'desc'
      } = filterDto;

      // Validate and get language preferences
      const preferredLanguage = this.languageService.validateLanguage(language);

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
               ...this.languageService.createTranslationWhereClause(preferredLanguage)
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
                  where: this.languageService.createTranslationWhereClause(preferredLanguage)
               },
               Subcategory: {
                  include: {
                     Translations: {
                        where: this.languageService.createTranslationWhereClause(preferredLanguage)
                     },
                     Category: {
                        include: {
                           Translations: {
                              where: this.languageService.createTranslationWhereClause(preferredLanguage)
                           },
                           FoodType: {
                              include: {
                                 Translations: {
                                    where: this.languageService.createTranslationWhereClause(preferredLanguage)
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

   @Cacheable({ 
      key: 'menus:findOne', 
      ttl: 1800, // 30 minutes
      tags: ['menus', 'menu_detail']
   })
   async findOne(id: number, language: string = DEFAULT_LANGUAGE) {
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

   @Cacheable({ 
      key: 'menus:popular', 
      ttl: 1800, // 30 minutes
      tags: ['menus', 'popular_menus']
   })
   async getPopularMenus(language: string = DEFAULT_LANGUAGE, limit: number = 10) {
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

   @Cacheable({ 
      key: 'menus:recommendations', 
      ttl: 600, // 10 minutes - shorter cache for personalized recommendations
      tags: ['recommendations']
   })
   async getRecommendations(queryDto: MenuRecommendationQueryDto): Promise<MenuRecommendationResultDto> {
      const tracker = this.loggingService.createPerformanceTracker('menu_recommendations');
      
      try {
         // Use the enhanced recommendation service for better results
         const result = await this.recommendationService.getAdvancedRecommendations(queryDto);
         
         // Log recommendation operation
         this.loggingService.logRecommendationOperation(
            queryDto.recommendation_type || 'personalized',
            queryDto.user_id?.toString(),
            result.recommendations.length,
            0,
            {
               filters: {
                  meal_time: queryDto.meal_time,
                  preferred_food_types: queryDto.preferred_food_types,
                  preferred_protein_types: queryDto.preferred_protein_types,
                  dietary_restrictions: queryDto.dietary_restrictions
               }
            }
         );
         
         tracker.finish(true, { results: result.recommendations.length });
         return result;
      } catch (error) {
         tracker.finish(false, { error: error.message });
         throw error;
      }
   }

   async searchMenus(searchDto: SearchMenuDto): Promise<SearchMenuResultDto> {
      const startTime = Date.now();
      const tracker = this.loggingService.createPerformanceTracker('menu_search');
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

      // Log search operation
      if (search) {
         this.loggingService.logSearchOperation(search, totalCount, searchTimeMs);
      }

      const result = {
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

      tracker.finish(true, { 
         results: totalCount, 
         search_term: search,
         filters: filtersApplied.length 
      });

      return result;
   }

   @Cacheable({
      key: 'menus:random',
      ttl: 300, // 5 minutes - shorter cache for random content
      tags: ['menus', 'random_menu']
   })
   async getRandomMenu(language: string = DEFAULT_LANGUAGE): Promise<MenuWithTranslations> {
      try {
         // ดึงข้อมูลเมนูทั้งหมดที่ active พร้อม keys ที่สำคัญ
         const activeMenus = await this.prisma.menu.findMany({
            where: { is_active: true },
            select: {
               id: true,
               key: true,
               subcategory_id: true,
               protein_type_id: true,
               meal_time: true
            }
         });

         if (activeMenus.length === 0) {
            throw new NotFoundException('No active menus found');
         }

         // สุ่มเลือก 1 เมนูจาก list
         const randomIndex = Math.floor(Math.random() * activeMenus.length);
         const selectedMenuBasic = activeMenus[randomIndex];

         // ใช้ key (unique) เพื่อให้แน่ใจว่าได้เมนูเดียวเท่านั้น
         // พร้อม validate ด้วย combination ของ keys อื่นเพื่อความแน่ใจ
         const menu = await this.prisma.menu.findFirst({
            where: {
               key: selectedMenuBasic.key, // unique key
               subcategory_id: selectedMenuBasic.subcategory_id,
               protein_type_id: selectedMenuBasic.protein_type_id,
               meal_time: selectedMenuBasic.meal_time,
               is_active: true
            },
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
            throw new NotFoundException('No menu found');
         }

         // คำนวณ average rating
         const ratings = await this.prisma.menuRating.aggregate({
            where: { menu_id: menu.id },
            _avg: { rating: true },
            _count: { rating: true }
         });

         // Map translations to correct format
         const translations = (menu.Translations || []).map(t => ({
            id: t.id,
            menu_id: t.menu_id,
            language: t.language,
            name: t.name,
            description: t.description || undefined
         }));

         // Map subcategory if exists
         const subcategory = menu.Subcategory ? {
            id: menu.Subcategory.id,
            name: menu.Subcategory.Translations?.[0]?.name || menu.Subcategory.key,
            category: menu.Subcategory.Category ? {
               id: menu.Subcategory.Category.id,
               name: menu.Subcategory.Category.Translations?.[0]?.name || menu.Subcategory.Category.key,
               food_type: menu.Subcategory.Category.FoodType ? {
                  id: menu.Subcategory.Category.FoodType.id,
                  name: menu.Subcategory.Category.FoodType.Translations?.[0]?.name || menu.Subcategory.Category.FoodType.key
               } : undefined
            } : undefined
         } : undefined;

         // Map protein type if exists
         const protein_type = menu.ProteinType ? {
            id: menu.ProteinType.id,
            name: menu.ProteinType.Translations?.[0]?.name || menu.ProteinType.key
         } : undefined;

         const menuWithRating: MenuWithTranslations = {
            ...menu,
            protein_type_id: menu.protein_type_id || undefined,
            image_url: menu.image_url || undefined,
            meal_time: menu.meal_time as MealTime,
            translations,
            subcategory,
            protein_type,
            average_rating: ratings._avg.rating ? Number(ratings._avg.rating.toFixed(1)) : undefined,
            total_ratings: ratings._count.rating
         };

         return menuWithRating;

      } catch (error) {
         throw error;
      }
   }

   async getPersonalizedRandomMenu(language: string = DEFAULT_LANGUAGE, userId: string): Promise<MenuWithTranslations> {
      try {
         // Get user's disliked menu IDs
         const userDislikes = await this.prisma.userDislike.findMany({
            where: { user_profile_id: userId },
            select: { menu_id: true }
         });

         const dislikedMenuIds = userDislikes.map(dislike => dislike.menu_id);

         // Get active menus excluding user dislikes
         const activeMenus = await this.prisma.menu.findMany({
            where: {
               is_active: true,
               ...(dislikedMenuIds.length > 0 && {
                  id: {
                     notIn: dislikedMenuIds
                  }
               })
            },
            select: {
               id: true,
               key: true,
               subcategory_id: true,
               protein_type_id: true,
               meal_time: true
            }
         });

         if (activeMenus.length === 0) {
            throw new NotFoundException('No active menus found that match your preferences');
         }

         // Randomly select one menu from the filtered list
         const randomIndex = Math.floor(Math.random() * activeMenus.length);
         const selectedMenuBasic = activeMenus[randomIndex];

         // Get full menu details with translations
         const menu = await this.prisma.menu.findFirst({
            where: {
               key: selectedMenuBasic.key,
               subcategory_id: selectedMenuBasic.subcategory_id,
               protein_type_id: selectedMenuBasic.protein_type_id,
               meal_time: selectedMenuBasic.meal_time,
               is_active: true
            },
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
            throw new NotFoundException('No menu found');
         }

         // Calculate average rating
         const ratings = await this.prisma.menuRating.aggregate({
            where: { menu_id: menu.id },
            _avg: { rating: true },
            _count: { rating: true }
         });

         // Map translations to correct format
         const translations = (menu.Translations || []).map(t => ({
            id: t.id,
            menu_id: t.menu_id,
            language: t.language,
            name: t.name,
            description: t.description || undefined
         }));

         // Map subcategory if exists
         const subcategory = menu.Subcategory ? {
            id: menu.Subcategory.id,
            name: menu.Subcategory.Translations?.[0]?.name || menu.Subcategory.key,
            category: menu.Subcategory.Category ? {
               id: menu.Subcategory.Category.id,
               name: menu.Subcategory.Category.Translations?.[0]?.name || menu.Subcategory.Category.key,
               food_type: menu.Subcategory.Category.FoodType ? {
                  id: menu.Subcategory.Category.FoodType.id,
                  name: menu.Subcategory.Category.FoodType.Translations?.[0]?.name || menu.Subcategory.Category.FoodType.key
               } : undefined
            } : undefined
         } : undefined;

         // Map protein type if exists
         const protein_type = menu.ProteinType ? {
            id: menu.ProteinType.id,
            name: menu.ProteinType.Translations?.[0]?.name || menu.ProteinType.key
         } : undefined;

         const menuWithRating: MenuWithTranslations = {
            ...menu,
            protein_type_id: menu.protein_type_id || undefined,
            image_url: menu.image_url || undefined,
            meal_time: menu.meal_time as MealTime,
            translations,
            subcategory,
            protein_type,
            average_rating: ratings._avg.rating ? Number(ratings._avg.rating.toFixed(1)) : undefined,
            total_ratings: ratings._count.rating
         };

         return menuWithRating;

      } catch (error) {
         throw error;
      }
   }
}