import { Module } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { FavoritesController } from './favorites.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';
import { CommonModule } from '../common/common.module';

@Module({
  imports: [PrismaModule, AuthModule, CommonModule],
  controllers: [FavoritesController],
  providers: [FavoritesService],
  exports: [FavoritesService],
})
export class FavoritesModule {}