import {
  Injectable,
  NotFoundException,
  ConflictException,
  UseInterceptors,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LanguageService } from '../common/services/language.service';
import { CacheService } from '../common/services/cache.service';
import { LoggingService } from '../common/services/logging.service';
import { DEFAULT_LANGUAGE } from '../common/constants/languages';
import { CacheInterceptor } from '../common/interceptors/cache.interceptor';
import { LoggingInterceptor } from '../common/interceptors/logging.interceptor';
import {
  Cacheable,
  CacheEvictByTags,
} from '../common/decorators/cache.decorator';
import { CreateMenuDto, MealTime } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { FilterMenuDto } from './dto/filter-menu.dto';
import { SearchMenuDto, SearchMenuResultDto } from './dto/search-menu.dto';
import {
  MenuRecommendationQueryDto,
  MenuRecommendationResultDto,
} from './dto/menu-recommendation.dto';
import { MenuWithTranslations } from './entities/menu.entity';
import { RecommendationService } from './services/recommendation.service';

@Injectable()
@UseInterceptors(CacheInterceptor, LoggingInterceptor)
export class MenusService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly languageService: LanguageService,
    private readonly cacheService: CacheService,
    private readonly loggingService: LoggingService,
    private readonly recommendationService: RecommendationService,
  ) {}

  @CacheEvictByTags(['menus', 'menu_list'])
  async create(createMenuDto: CreateMenuDto) {
    try {
      // ตรวจสอบว่า subcategory มีอยู่จริง
      const subcategory = await this.prisma.subcategory.findUnique({
        where: { id: createMenuDto.subcategory_id },
      });

      if (!subcategory) {
        throw new NotFoundException(
          `Subcategory with ID ${createMenuDto.subcategory_id} not found`,
        );
      }

      // ตรวจสอบ protein_type หากมี
      if (createMenuDto.protein_type_id) {
        const proteinType = await this.prisma.proteinType.findUnique({
          where: { id: createMenuDto.protein_type_id },
        });
        if (!proteinType) {
          throw new NotFoundException(
            `Protein type with ID ${createMenuDto.protein_type_id} not found`,
          );
        }
      }

      // ตรวจสอบว่าเมนูนี้มีอยู่แล้วหรือไม่ (subcategory + protein_type)
      const existingMenu = await this.prisma.menu.findFirst({
        where: {
          subcategory_id: createMenuDto.subcategory_id,
          protein_type_id: createMenuDto.protein_type_id,
        },
      });

      if (existingMenu) {
        throw new ConflictException(
          'Menu with this subcategory and protein type combination already exists',
        );
      }

      const menu = await this.prisma.menu.create({
        data: {
          subcategory_id: createMenuDto.subcategory_id,
          protein_type_id: createMenuDto.protein_type_id,
          image_url: createMenuDto.image_url,
          contains: createMenuDto.contains,
          meal_time: createMenuDto.meal_time,
        },
        include: {
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
        },
      });
      return menu;
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2002') {
        throw new ConflictException(
          'Menu with this subcategory and protein type combination already exists',
        );
      }
      throw error;
    }
  }

  @Cacheable({
    key: 'menus:findAll',
    ttl: 900, // 15 minutes
    tags: ['menus', 'menu_list'],
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
      page = 1,
      limit = 10,
      sort_by = 'created_at',
      sort_order = 'desc',
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
        Category: { food_type_id: food_type_id },
      };
    }

    if (protein_type_id) {
      where.protein_type_id = protein_type_id;
    }

    if (meal_time) {
      where.meal_time = meal_time;
    }

    if (search) {
      where.OR = [
        {
          Subcategory: {
            Translations: {
              some: {
                name: { contains: search, mode: 'insensitive' },
                language: preferredLanguage,
              },
            },
          },
        },
        {
          ProteinType: {
            Translations: {
              some: {
                name: { contains: search, mode: 'insensitive' },
                language: preferredLanguage,
              },
            },
          },
        },
      ];
    }

    // สร้าง orderBy
    let orderBy: any = {};
    if (sort_by === 'name') {
      orderBy = {
        subcategory_id: sort_order,
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
          Subcategory: {
            include: {
              Translations: true, // Return all translations for client-side language switching
              Category: {
                include: {
                  Translations: true, // Return all translations
                  FoodType: {
                    include: {
                      Translations: true, // Return all translations
                    },
                  },
                },
              },
            },
          },
          ProteinType: {
            include: {
              Translations: true, // Return all translations for client-side language switching
            },
          },
        },
        orderBy,
        skip,
        take: limit,
      }),
      this.prisma.menu.count({ where }),
    ]);

    return {
      data: menus,
      pagination: {
        page,
        limit,
        total: totalCount,
        total_pages: Math.ceil(totalCount / limit),
        has_next: page < Math.ceil(totalCount / limit),
        has_prev: page > 1,
      },
    };
  }

  @Cacheable({
    key: 'menus:findOne',
    ttl: 1800, // 30 minutes
    tags: ['menus', 'menu_detail'],
  })
  async findOne(id: number, language: string = DEFAULT_LANGUAGE) {
    const menu = await this.prisma.menu.findUnique({
      where: { id },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: language },
            },
            Category: {
              include: {
                Translations: {
                  where: { language: language },
                },
                FoodType: {
                  include: {
                    Translations: {
                      where: { language: language },
                    },
                  },
                },
              },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: language },
            },
          },
        },
        Ratings: {
          take: 10,
          orderBy: { created_at: 'desc' },
          include: {
            UserProfile: {
              select: { name: true },
            },
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException(`Menu with ID ${id} not found`);
    }

    // คำนวณคะแนนเฉลี่ย
    const avgRating = await this.prisma.menuRating.aggregate({
      where: { menu_id: id },
      _avg: { rating: true },
      _count: { rating: true },
    });

    // สร้างชื่อเมนูจาก subcategory + protein
    const subcategoryName =
      menu.Subcategory.Translations[0]?.name || menu.Subcategory.key;
    const proteinName = menu.ProteinType?.Translations[0]?.name;
    const menuName = proteinName
      ? `${subcategoryName}${proteinName}`
      : subcategoryName;

    return {
      ...menu,
      name: menuName,
      subcategory: {
        id: menu.Subcategory.id,
        name: subcategoryName,
        category: {
          id: menu.Subcategory.Category.id,
          name:
            menu.Subcategory.Category.Translations[0]?.name ||
            menu.Subcategory.Category.key,
          food_type: {
            id: menu.Subcategory.Category.FoodType.id,
            name:
              menu.Subcategory.Category.FoodType.Translations[0]?.name ||
              menu.Subcategory.Category.FoodType.key,
          },
        },
      },
      protein_type: menu.ProteinType
        ? {
            id: menu.ProteinType.id,
            name: proteinName,
          }
        : undefined,
      average_rating: avgRating._avg.rating || 0,
      total_ratings: avgRating._count.rating || 0,
    };
  }

  async update(id: number, updateMenuDto: UpdateMenuDto) {
    try {
      await this.validateUpdateReferences(updateMenuDto);
      const updateData = this.buildUpdateData(updateMenuDto);
      const menu = await this.prisma.menu.update({
        where: { id },
        data: updateData,
        include: this.getMenuIncludeOptions(),
      });
      return menu;
    } catch (error) {
      this.handleUpdateError(error, id);
    }
  }

  private async validateUpdateReferences(
    updateMenuDto: UpdateMenuDto,
  ): Promise<void> {
    // Validate subcategory if provided
    if (updateMenuDto.subcategory_id) {
      const subcategory = await this.prisma.subcategory.findUnique({
        where: { id: updateMenuDto.subcategory_id },
      });
      if (!subcategory) {
        throw new NotFoundException(
          `Subcategory with ID ${updateMenuDto.subcategory_id} not found`,
        );
      }
    }

    // Validate protein type if provided
    if (updateMenuDto.protein_type_id) {
      const proteinType = await this.prisma.proteinType.findUnique({
        where: { id: updateMenuDto.protein_type_id },
      });
      if (!proteinType) {
        throw new NotFoundException(
          `Protein type with ID ${updateMenuDto.protein_type_id} not found`,
        );
      }
    }
  }

  private buildUpdateData(updateMenuDto: UpdateMenuDto): any {
    const updateData: any = {};
    if (updateMenuDto.subcategory_id)
      updateData.subcategory_id = updateMenuDto.subcategory_id;
    if (updateMenuDto.protein_type_id !== undefined)
      updateData.protein_type_id = updateMenuDto.protein_type_id;
    if (updateMenuDto.image_url !== undefined)
      updateData.image_url = updateMenuDto.image_url;
    if (updateMenuDto.contains) updateData.contains = updateMenuDto.contains;
    if (updateMenuDto.meal_time)
      updateData.meal_time = updateMenuDto.meal_time;
    if (updateMenuDto.is_active !== undefined)
      updateData.is_active = updateMenuDto.is_active;
    return updateData;
  }

  private getMenuIncludeOptions() {
    return {
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
    };
  }

  private handleUpdateError(error: any, id: number): never {
    if (error?.code === 'P2025') {
      throw new NotFoundException(`Menu with ID ${id} not found`);
    }
    if (error?.code === 'P2002') {
      throw new ConflictException('Menu key already exists');
    }
    throw error;
  }

  async remove(id: number) {
    try {
      const menu = await this.prisma.menu.update({
        where: { id },
        data: { is_active: false },
        include: {
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
        },
      });
      return menu;
    } catch (error) {
      if ((error as { code?: string })?.code === 'P2025') {
        throw new NotFoundException(`Menu with ID ${id} not found`);
      }
      throw error;
    }
  }

  async findBySubcategoryAndProtein(
    subcategoryId: number,
    proteinId: number,
    language: string = 'th',
  ) {
    const menu = await this.prisma.menu.findFirst({
      where: {
        subcategory_id: subcategoryId,
        protein_type_id: proteinId,
      },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: language },
            },
            Category: {
              include: {
                Translations: {
                  where: { language: language },
                },
                FoodType: {
                  include: {
                    Translations: {
                      where: { language: language },
                    },
                  },
                },
              },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: language },
            },
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException(
        `Menu with subcategory ID '${subcategoryId}' and protein ID '${proteinId}' not found`,
      );
    }

    return menu;
  }

  @Cacheable({
    key: 'menus:popular',
    ttl: 1800, // 30 minutes
    tags: ['menus', 'popular_menus'],
  })
  async getPopularMenus(
    language: string = DEFAULT_LANGUAGE,
    limit: number = 10,
  ) {
    return this.prisma.menu.findMany({
      where: { is_active: true },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: language },
            },
          },
        },
        Ratings: {
          select: { rating: true },
        },
      },
      orderBy: {
        Favorites: {
          _count: 'desc',
        },
      },
      take: limit,
    });
  }

  @Cacheable({
    key: 'menus:recommendations',
    ttl: 600, // 10 minutes - shorter cache for personalized recommendations
    tags: ['recommendations'],
  })
  async getRecommendations(
    queryDto: MenuRecommendationQueryDto,
  ): Promise<MenuRecommendationResultDto> {
    const tracker = this.loggingService.createPerformanceTracker(
      'menu_recommendations',
    );

    try {
      // Use the enhanced recommendation service for better results
      const result =
        await this.recommendationService.getAdvancedRecommendations(queryDto);

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
            dietary_restrictions: queryDto.dietary_restrictions,
          },
        },
      );

      tracker.finish(true, { results: result.recommendations.length });
      return result;
    } catch (error) {
      tracker.finish(false, { error: (error as Error).message });
      throw error;
    }
  }

  async searchMenus(searchDto: SearchMenuDto): Promise<SearchMenuResultDto> {
    const startTime = Date.now();
    const tracker = this.loggingService.createPerformanceTracker('menu_search');
    const { language = 'th', page = 1, limit = 20 } = searchDto;

    const where = this.buildSearchWhereConditions(searchDto);
    const orderBy = this.buildSearchOrderBy(searchDto);
    const skip = (page - 1) * limit;

    const [menus, totalCount] = await Promise.all([
      this.prisma.menu.findMany({
        where,
        include: {
          Subcategory: {
            include: {
              Translations: { where: { language } },
              Category: {
                include: {
                  Translations: { where: { language } },
                  FoodType: {
                    include: { Translations: { where: { language } } },
                  },
                },
              },
            },
          },
          ProteinType: {
            include: { Translations: { where: { language } } },
          },
        },
        orderBy,
        skip,
        take: limit,
      }),
      this.prisma.menu.count({ where }),
    ]);

    const searchTimeMs = Date.now() - startTime;
    this.logSearchIfNeeded(searchDto.search, totalCount, searchTimeMs);

    const result = this.buildSearchResult(
      menus,
      totalCount,
      searchDto,
      searchTimeMs,
    );

    tracker.finish(true, { results: totalCount });
    return result;
  }

  private buildSearchWhereConditions(searchDto: SearchMenuDto): any {
    const {
      search,
      language = 'th',
      meal_time,
      food_type_ids,
      category_ids,
      subcategory_ids,
      protein_type_ids,
    } = searchDto;

    const where: any = { is_active: true };

    if (search) {
      where.OR = [
        {
          Subcategory: {
            Translations: {
              some: {
                name: { contains: search, mode: 'insensitive' },
                language,
              },
            },
          },
        },
        {
          ProteinType: {
            Translations: {
              some: {
                name: { contains: search, mode: 'insensitive' },
                language,
              },
            },
          },
        },
      ];
    }

    if (meal_time) where.meal_time = meal_time;
    if (subcategory_ids?.length)
      where.subcategory_id = { in: subcategory_ids };
    if (protein_type_ids?.length)
      where.protein_type_id = { in: protein_type_ids };

    if (food_type_ids?.length || category_ids?.length) {
      where.Subcategory = where.Subcategory || {};
      if (category_ids?.length) {
        where.Subcategory.category_id = { in: category_ids };
      }
      if (food_type_ids?.length) {
        where.Subcategory.Category = {
          food_type_id: { in: food_type_ids },
        };
      }
    }

    return where;
  }

  private buildSearchOrderBy(searchDto: SearchMenuDto): any {
    const { sort_by = 'relevance', sort_order = 'desc', search } = searchDto;

    switch (sort_by) {
      case 'name':
        return { id: sort_order };
      case 'rating':
        return { created_at: sort_order };
      case 'popularity':
        return [
          { Favorites: { _count: sort_order } },
          { created_at: sort_order },
        ];
      case 'created_at':
        return { created_at: sort_order };
      default:
        return search ? { created_at: sort_order } : { created_at: 'desc' };
    }
  }

  private logSearchIfNeeded(
    search: string | undefined,
    totalCount: number,
    searchTimeMs: number,
  ): void {
    if (search) {
      this.loggingService.logSearchOperation(search, totalCount, searchTimeMs);
    }
  }

  private buildSearchResult(
    menus: any[],
    totalCount: number,
    searchDto: SearchMenuDto,
    searchTimeMs: number,
  ): SearchMenuResultDto {
    const { search, language = 'th', page = 1, limit = 20, sort_by = 'relevance', sort_order = 'desc' } = searchDto;
    const filtersApplied = this.getAppliedFilters(searchDto);

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
        suggestions:
          totalCount === 0 && search
            ? [
                `Try searching for "${search.slice(0, -1)}"`,
                'Check spelling',
                'Use fewer keywords',
              ]
            : undefined,
      },
    };
  }

  private getAppliedFilters(searchDto: SearchMenuDto): string[] {
    const filters: string[] = [];
    if (searchDto.search) filters.push('text_search');
    if (searchDto.meal_time) filters.push('meal_time');
    if (searchDto.food_type_ids?.length) filters.push('food_types');
    if (searchDto.category_ids?.length) filters.push('categories');
    if (searchDto.subcategory_ids?.length) filters.push('subcategories');
    if (searchDto.protein_type_ids?.length) filters.push('protein_types');
    if (searchDto.min_rating) filters.push('min_rating');
    return filters;
  }

  @Cacheable({
    key: 'menus:random',
    ttl: 300, // 5 minutes - shorter cache for random content
    tags: ['menus', 'random_menu'],
  })
  async getRandomMenu(
    language: string = DEFAULT_LANGUAGE,
  ): Promise<MenuWithTranslations> {
    // ดึงข้อมูลเมนูทั้งหมดที่ active พร้อม keys ที่สำคัญ
    const activeMenus = await this.prisma.menu.findMany({
      where: { is_active: true },
      select: {
        id: true,
        subcategory_id: true,
        protein_type_id: true,
        meal_time: true,
      },
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
        id: selectedMenuBasic.id, // unique key
        subcategory_id: selectedMenuBasic.subcategory_id,
        protein_type_id: selectedMenuBasic.protein_type_id,
        meal_time: selectedMenuBasic.meal_time,
        is_active: true,
      },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: language },
            },
            Category: {
              include: {
                Translations: {
                  where: { language: language },
                },
                FoodType: {
                  include: {
                    Translations: {
                      where: { language: language },
                    },
                  },
                },
              },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: language },
            },
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException('No menu found');
    }

    // คำนวณ average rating
    const ratings = await this.prisma.menuRating.aggregate({
      where: { menu_id: menu.id },
      _avg: { rating: true },
      _count: { rating: true },
    });

    // Generate dynamic menu name
    const subcategoryName =
      menu.Subcategory?.Translations?.[0]?.name ||
      menu.Subcategory?.key ||
      `subcategory_${menu.Subcategory?.id}`;
    const proteinName = menu.ProteinType?.Translations?.[0]?.name;
    const menuName = proteinName
      ? `${subcategoryName}${proteinName}`
      : subcategoryName;

    // Map subcategory if exists
    const subcategory = menu.Subcategory
      ? {
          id: menu.Subcategory.id,
          name:
            menu.Subcategory.Translations?.[0]?.name ||
            `subcategory_${menu.Subcategory.id}`,
          category: menu.Subcategory.Category
            ? {
                id: menu.Subcategory.Category.id,
                name:
                  menu.Subcategory.Category.Translations?.[0]?.name ||
                  `category_${menu.Subcategory.Category.id}`,
                food_type: menu.Subcategory.Category.FoodType
                  ? {
                      id: menu.Subcategory.Category.FoodType.id,
                      name:
                        menu.Subcategory.Category.FoodType.Translations?.[0]
                          ?.name ||
                        `foodtype_${menu.Subcategory.Category.FoodType.id}`,
                    }
                  : undefined,
              }
            : undefined,
        }
      : undefined;

    // Map protein type if exists
    const protein_type = menu.ProteinType
      ? {
          id: menu.ProteinType.id,
          name:
            menu.ProteinType.Translations?.[0]?.name ||
            `protein_${menu.ProteinType.id}`,
        }
      : undefined;

    const menuWithRating: MenuWithTranslations = {
      ...menu,
      protein_type_id: menu.protein_type_id || undefined,
      image_url: menu.image_url || undefined,
      meal_time: menu.meal_time as MealTime,
      name: menuName,
      subcategory,
      protein_type,
      average_rating: ratings._avg.rating
        ? Number(ratings._avg.rating.toFixed(1))
        : undefined,
      total_ratings: ratings._count.rating,
    };

    return menuWithRating;
  }

  async getPersonalizedRandomMenu(
    userId: string,
    language: string = DEFAULT_LANGUAGE,
  ): Promise<MenuWithTranslations> {
    // Get user's disliked menu IDs
    const userDislikes = await this.prisma.userDislike.findMany({
      where: { user_profile_id: userId },
      select: { menu_id: true },
    });

    const dislikedMenuIds = userDislikes.map((dislike) => dislike.menu_id);

    // Get user's protein preferences (proteins they DON'T want)
    const userProteinPreferences =
      await this.prisma.userProteinPreference.findMany({
        where: {
          user_profile_id: userId,
          exclude: true, // true = user doesn't want this protein
        },
        select: { protein_type_id: true },
      });

    const excludedProteinIds = userProteinPreferences.map(
      (pref) => pref.protein_type_id,
    );

    // Get active menus excluding user dislikes AND excluded proteins
    const activeMenus = await this.prisma.menu.findMany({
      where: {
        is_active: true,
        ...(dislikedMenuIds.length > 0 && {
          id: {
            notIn: dislikedMenuIds,
          },
        }),
        ...(excludedProteinIds.length > 0 && {
          OR: [
            { protein_type_id: null }, // Include menus without protein
            {
              protein_type_id: {
                notIn: excludedProteinIds, // Exclude menus with unwanted proteins
              },
            },
          ],
        }),
      },
      select: {
        id: true,
        subcategory_id: true,
        protein_type_id: true,
        meal_time: true,
      },
    });

    if (activeMenus.length === 0) {
      throw new NotFoundException(
        'No active menus found that match your preferences',
      );
    }

    // Randomly select one menu from the filtered list
    const randomIndex = Math.floor(Math.random() * activeMenus.length);
    const selectedMenuBasic = activeMenus[randomIndex];

    // Get full menu details with translations
    const menu = await this.prisma.menu.findFirst({
      where: {
        id: selectedMenuBasic.id,
        subcategory_id: selectedMenuBasic.subcategory_id,
        protein_type_id: selectedMenuBasic.protein_type_id,
        meal_time: selectedMenuBasic.meal_time,
        is_active: true,
      },
      include: {
        Subcategory: {
          include: {
            Translations: {
              where: { language: language },
            },
            Category: {
              include: {
                Translations: {
                  where: { language: language },
                },
                FoodType: {
                  include: {
                    Translations: {
                      where: { language: language },
                    },
                  },
                },
              },
            },
          },
        },
        ProteinType: {
          include: {
            Translations: {
              where: { language: language },
            },
          },
        },
      },
    });

    if (!menu) {
      throw new NotFoundException('No menu found');
    }

    // Calculate average rating
    const ratings = await this.prisma.menuRating.aggregate({
      where: { menu_id: menu.id },
      _avg: { rating: true },
      _count: { rating: true },
    });

    // Generate dynamic menu name
    const subcategoryName =
      menu.Subcategory?.Translations?.[0]?.name ||
      menu.Subcategory?.key ||
      `subcategory_${menu.Subcategory?.id}`;
    const proteinName = menu.ProteinType?.Translations?.[0]?.name;
    const menuName = proteinName
      ? `${subcategoryName}${proteinName}`
      : subcategoryName;

    // Map subcategory if exists
    const subcategory = menu.Subcategory
      ? {
          id: menu.Subcategory.id,
          name:
            menu.Subcategory.Translations?.[0]?.name ||
            `subcategory_${menu.Subcategory.id}`,
          category: menu.Subcategory.Category
            ? {
                id: menu.Subcategory.Category.id,
                name:
                  menu.Subcategory.Category.Translations?.[0]?.name ||
                  `category_${menu.Subcategory.Category.id}`,
                food_type: menu.Subcategory.Category.FoodType
                  ? {
                      id: menu.Subcategory.Category.FoodType.id,
                      name:
                        menu.Subcategory.Category.FoodType.Translations?.[0]
                          ?.name ||
                        `foodtype_${menu.Subcategory.Category.FoodType.id}`,
                    }
                  : undefined,
              }
            : undefined,
        }
      : undefined;

    // Map protein type if exists
    const protein_type = menu.ProteinType
      ? {
          id: menu.ProteinType.id,
          name:
            menu.ProteinType.Translations?.[0]?.name ||
            `protein_${menu.ProteinType.id}`,
        }
      : undefined;

    const menuWithRating: MenuWithTranslations = {
      ...menu,
      protein_type_id: menu.protein_type_id || undefined,
      image_url: menu.image_url || undefined,
      meal_time: menu.meal_time as MealTime,
      name: menuName,
      subcategory,
      protein_type,
      average_rating: ratings._avg.rating
        ? Number(ratings._avg.rating.toFixed(1))
        : undefined,
      total_ratings: ratings._count.rating,
    };

    return menuWithRating;
  }

  // Batch Operations
  @CacheEvictByTags(['menus', 'menu_list'])
  async createBatch(menusData: CreateMenuDto[]) {
    const results: any[] = [];
    const errors: any[] = [];

    // Process each menu independently (no transaction to allow partial success)
    for (const menuData of menusData) {
      try {
        // Validate subcategory
        const subcategory = await this.prisma.subcategory.findUnique({
          where: { id: menuData.subcategory_id },
        });

        if (!subcategory) {
          errors.push({
            menu: menuData,
            error: `Subcategory ${menuData.subcategory_id} not found`,
          });
          continue;
        }

        // Validate protein type if provided
        if (menuData.protein_type_id) {
          const proteinType = await this.prisma.proteinType.findUnique({
            where: { id: menuData.protein_type_id },
          });
          if (!proteinType) {
            errors.push({
              menu: menuData,
              error: `Protein type ${menuData.protein_type_id} not found`,
            });
            continue;
          }
        }

        // Check for duplicates
        const existing = await this.prisma.menu.findFirst({
          where: {
            subcategory_id: menuData.subcategory_id,
            protein_type_id: menuData.protein_type_id,
          },
        });

        if (existing) {
          errors.push({
            menu: menuData,
            error: 'Menu already exists',
          });
          continue;
        }

        // Create menu
        const created = await this.prisma.menu.create({
          data: {
            subcategory_id: menuData.subcategory_id,
            protein_type_id: menuData.protein_type_id,
            image_url: menuData.image_url,
            contains: menuData.contains,
            meal_time: menuData.meal_time,
          },
          include: {
            Subcategory: {
              include: { Translations: true },
            },
            ProteinType: {
              include: { Translations: true },
            },
          },
        });

        results.push(created);
      } catch (error) {
        errors.push({
          menu: menuData,
          error: error.message || 'Unknown error',
        });
      }
    }

    return {
      success: true,
      total: menusData.length,
      created: results.length,
      failed: errors.length,
      results,
      errors: errors.length > 0 ? errors : undefined,
    };
  }

  @CacheEvictByTags(['menus', 'menu_list'])
  async deleteBatch(ids: number[]) {
    const results: any[] = [];
    const errors: any[] = [];

    for (const id of ids) {
      try {
        const menu = await this.prisma.menu.findUnique({
          where: { id },
        });

        if (!menu) {
          errors.push({
            id,
            error: 'Menu not found',
          });
          continue;
        }

        await this.prisma.menu.delete({
          where: { id },
        });

        results.push({ id, deleted: true });
      } catch (error) {
        errors.push({
          id,
          error: error.message || 'Unknown error',
        });
      }
    }

    return {
      success: true,
      total: ids.length,
      deleted: results.length,
      failed: errors.length,
      results,
      errors: errors.length > 0 ? errors : undefined,
    };
  }
}
