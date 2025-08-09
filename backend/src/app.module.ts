import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FoodManagementModule } from './food-management/food-management.module';
import { PrismaModule } from './prisma/prisma.module';
import { MenusModule } from './menus/menus.module';
import { AuthModule } from './auth/auth.module';
import { UserProfilesModule } from './user-profiles/user-profiles.module';
import { DietaryRestrictionsModule } from './dietary-restrictions/dietary-restrictions.module';
import { FavoritesModule } from './favorites/favorites.module';
import { RatingsModule } from './ratings/ratings.module';
import { AnalyticsModule } from './analytics/analytics.module';

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
    UserProfilesModule,
    DietaryRestrictionsModule,
    FavoritesModule,
    RatingsModule,
    AnalyticsModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }