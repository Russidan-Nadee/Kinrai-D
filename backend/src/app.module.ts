import { Module } from '@nestjs/common';
import { FoodManagementModule } from './food-management/food-management.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    PrismaModule,
    FoodManagementModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }