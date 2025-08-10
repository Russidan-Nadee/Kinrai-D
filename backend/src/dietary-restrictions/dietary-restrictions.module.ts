import { Module } from '@nestjs/common';
import { DietaryRestrictionsService } from './dietary-restrictions.service';
import { DietaryRestrictionsController } from './dietary-restrictions.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [DietaryRestrictionsController],
  providers: [DietaryRestrictionsService],
  exports: [DietaryRestrictionsService],
})
export class DietaryRestrictionsModule {}