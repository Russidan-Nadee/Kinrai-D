import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { SupabaseService } from './supabase.service';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { PermissionsGuard } from './guards/permissions.guard';
import { CommonModule } from '../common/common.module';

@Module({
  imports: [ConfigModule, CommonModule],
  controllers: [AuthController],
  providers: [
    SupabaseService,
    SupabaseAuthGuard,
    RolesGuard,
    PermissionsGuard
  ],
  exports: [
    SupabaseService,
    SupabaseAuthGuard,
    RolesGuard,
    PermissionsGuard
  ],
})
export class AuthModule {}