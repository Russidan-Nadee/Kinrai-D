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
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(
    private reflector: Reflector,
    private readonly supabaseService: SupabaseService,
    private readonly loggingService: LoggingService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true; // No roles required
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('User not found in request');
    }

    try {
      // Check if user has any of the required roles
      const hasRole = await this.hasAnyRole(user.id, requiredRoles);

      if (!hasRole) {
        this.loggingService.logSecurityEvent('access_denied_insufficient_role', {
          userId: user.id,
          ip: request.ip,
          userAgent: request.get('User-Agent'),
          url: request.url,
          method: request.method,
          metadata: { 
            userRole: user.role,
            requiredRoles 
          }
        }, 'medium');

        throw new ForbiddenException('Insufficient permissions');
      }

      return true;
    } catch (error) {
      this.logger.warn('Role check failed:', error.message);
      throw new ForbiddenException('Access denied');
    }
  }

  private async hasAnyRole(userId: string, requiredRoles: string[]): Promise<boolean> {
    for (const role of requiredRoles) {
      const hasRole = await this.supabaseService.hasRole(userId, role);
      if (hasRole) {
        return true;
      }
    }
    return false;
  }
}