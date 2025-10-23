import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_INTERCEPTOR } from '@nestjs/core';
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
import { CommonModule } from './common/common.module';
import { CacheInterceptor } from './common/interceptors/cache.interceptor';
import { QueuesModule } from './queues/queues.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    CommonModule,
    QueuesModule,
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
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: CacheInterceptor,
    },
  ],
})
export class AppModule {}
