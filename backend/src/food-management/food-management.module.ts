import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { FoodTypesService } from './services/food-types.service';
import { FoodTypesController } from './controllers/food-types.controller';
import { CategoriesService } from './services/categories.service';
import { CategoriesController } from './controllers/categories.controller';
import { SubcategoriesService } from './services/subcategories.service';
import { SubcategoriesController } from './controllers/subcategories.controller';
import { ProteinTypesController } from './controllers/protein-types.controller';

@Module({
   imports: [PrismaModule],
   controllers: [
      FoodTypesController,
      CategoriesController,
      SubcategoriesController,
      ProteinTypesController,
   ],
   providers: [
      FoodTypesService,
      CategoriesService,
      SubcategoriesService,
   ],
   exports: [
      FoodTypesService,
      CategoriesService,
      SubcategoriesService,
   ],
})
export class FoodManagementModule { }