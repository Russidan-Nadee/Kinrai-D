import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FoodManagementModule } from './food-management/food-management.module';
import { PrismaModule } from './prisma/prisma.module';
import { MenusModule } from './menus/menus.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { UserProfilesModule } from './user-profiles/user-profiles.module';
import { FavoritesModule } from './favorites/favorites.module';
import { RatingsModule } from './ratings/ratings.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AdminModule } from './admin/admin.module';
import { ProteinPreferencesModule } from './protein-preferences/protein-preferences.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    HealthModule,
    AuthModule,
    UsersModule,
    FoodManagementModule,
    MenusModule,
    UserProfilesModule,
    FavoritesModule,
    RatingsModule,
    AnalyticsModule,
    AdminModule,
    ProteinPreferencesModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
