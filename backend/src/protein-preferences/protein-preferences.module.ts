import { Module } from '@nestjs/common';
import { ProteinPreferencesService } from './protein-preferences.service';
import { ProteinPreferencesController } from './protein-preferences.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [ProteinPreferencesService],
  controllers: [ProteinPreferencesController],
})
export class ProteinPreferencesModule {}
