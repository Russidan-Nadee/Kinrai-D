import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FoodManagementModule } from './food-management/food-management.module';
import { PrismaModule } from './prisma/prisma.module';
import { MenusModule } from './menus/menus.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    AuthModule,
    FoodManagementModule,
    MenusModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }