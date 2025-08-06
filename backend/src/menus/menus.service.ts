import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { FilterMenuDto } from './dto/filter-menu.dto';

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
}