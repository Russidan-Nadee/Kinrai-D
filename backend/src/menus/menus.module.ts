import { Module } from '@nestjs/common';
import { MenusService } from './menus.service';
import { MenusController } from './menus.controller';
import { RecommendationService } from './services/recommendation.service';
import { PrismaModule } from '../prisma/prisma.module';
import { CommonModule } from '../common/common.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, CommonModule, AuthModule],
  controllers: [MenusController],
  providers: [MenusService, RecommendationService],
  exports: [MenusService, RecommendationService],
})
export class MenusModule {}