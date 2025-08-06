import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { SupabaseService } from '../supabase.service';
import { LoggingService } from '../../common/services/logging.service';

@Injectable()
export class PermissionsGuard implements CanActivate {
  private readonly logger = new Logger(PermissionsGuard.name);

  constructor(
    private reflector: Reflector,
    private readonly supabaseService: SupabaseService,
    private readonly loggingService: LoggingService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>('permissions', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredPermissions) {
      return true; // No permissions required
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('User not found in request');
    }

    try {
      // Check if user has all required permissions
      const hasPermissions = await this.hasAllPermissions(user.id, requiredPermissions);

      if (!hasPermissions) {
        this.loggingService.logSecurityEvent('access_denied_insufficient_permissions', {
          userId: user.id,
          ip: request.ip,
          userAgent: request.get('User-Agent'),
          url: request.url,
          method: request.method,
          metadata: { 
            requiredPermissions,
            userRole: user.role 
          }
        }, 'medium');

        throw new ForbiddenException('Insufficient permissions');
      }

      return true;
    } catch (error) {
      this.logger.warn('Permission check failed:', error.message);
      throw new ForbiddenException('Access denied');
    }
  }

  private async hasAllPermissions(userId: string, requiredPermissions: string[]): Promise<boolean> {
    for (const permission of requiredPermissions) {
      const hasPermission = await this.supabaseService.hasPermission(userId, permission);
      if (!hasPermission) {
        return false;
      }
    }
    return true;
  }
}