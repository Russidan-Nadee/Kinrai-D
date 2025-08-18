import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RolesGuard } from './guards/roles.guard';
import { PermissionsGuard } from './guards/permissions.guard';
import { CommonModule } from '../common/common.module';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [ConfigModule, CommonModule, PrismaModule],
  controllers: [],
  providers: [
    RolesGuard,
    PermissionsGuard
  ],
  exports: [
    RolesGuard,
    PermissionsGuard
  ],
})
export class AuthModule {}