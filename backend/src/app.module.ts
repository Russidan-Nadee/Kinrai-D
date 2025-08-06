import { Module } from '@nestjs/common';
import { FoodManagementModule } from './food-management/food-management.module';
import { PrismaModule } from './prisma/prisma.module';
import { MenusModule } from './menus/menus.module';

@Module({
  imports: [
    PrismaModule,
    FoodManagementModule,
    MenusModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }