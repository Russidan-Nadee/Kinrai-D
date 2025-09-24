import { Module } from '@nestjs/common';
import { AdminDashboardController } from './controllers/admin-dashboard.controller';
import { AdminUsersController } from './controllers/admin-users.controller';
import { AdminMenusController } from './controllers/admin-menus.controller';
import { AdminFoodManagementController } from './controllers/admin-food-management.controller';
import { AdminAnalyticsController } from './controllers/admin-analytics.controller';

import { AdminDashboardService } from './services/admin-dashboard.service';
import { AdminUsersService } from './services/admin-users.service';
import { AdminMenusService } from './services/admin-menus.service';
import { AdminFoodManagementService } from './services/admin-food-management.service';
import { AdminAnalyticsService } from './services/admin-analytics.service';

import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';
import { CommonModule } from '../common/common.module';

@Module({
  imports: [PrismaModule, AuthModule, CommonModule],
  controllers: [
    AdminDashboardController,
    AdminUsersController,
    AdminMenusController,
    AdminFoodManagementController,
    AdminAnalyticsController,
  ],
  providers: [
    AdminDashboardService,
    AdminUsersService,
    AdminMenusService,
    AdminFoodManagementService,
    AdminAnalyticsService,
  ],
  exports: [
    AdminDashboardService,
    AdminUsersService,
    AdminMenusService,
    AdminFoodManagementService,
    AdminAnalyticsService,
  ],
})
export class AdminModule {}
