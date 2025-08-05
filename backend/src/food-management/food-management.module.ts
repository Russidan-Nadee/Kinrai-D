import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { FoodTypesService } from './services/food-types.service';
import { FoodTypesController } from './controllers/food-types.controller';
import { CategoriesService } from './services/categories.service';
import { CategoriesController } from './controllers/categories.controller';

@Module({
   imports: [PrismaModule],
   controllers: [
      FoodTypesController,
      CategoriesController,
   ],
   providers: [
      FoodTypesService,
      CategoriesService,
   ],
   exports: [
      FoodTypesService,
      CategoriesService,
   ],
})
export class FoodManagementModule { }