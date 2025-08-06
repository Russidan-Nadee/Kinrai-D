import { Module } from '@nestjs/common';
import { MenusService } from './menus.service';
import { MenusController } from './menus.controller';
import { RecommendationService } from './services/recommendation.service';
import { PrismaModule } from '../prisma/prisma.module';
import { CommonModule } from '../common/common.module';

@Module({
  imports: [PrismaModule, CommonModule],
  controllers: [MenusController],
  providers: [MenusService, RecommendationService],
  exports: [MenusService, RecommendationService],
})
export class MenusModule {}