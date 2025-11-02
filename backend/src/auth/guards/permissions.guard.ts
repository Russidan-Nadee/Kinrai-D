import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PrismaService } from '../../prisma/prisma.service';
import { UserRole } from '@prisma/client';

// Define permission mappings for each role
const ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  ADMIN: ['*'], // Admin has all permissions (wildcard)
  MODERATOR: [
    'read_menu',
    'write_menu',
    'read_user',
    'read_analytics',
    'delete_comment',
    'manage_food',
  ],
  USER: [
    'read_menu',
    'write_favorite',
    'write_rating',
    'read_own_profile',
    'update_own_profile',
  ],
};

@Injectable()
export class PermissionsGuard implements CanActivate {
  private readonly logger = new Logger(PermissionsGuard.name);

  constructor(
    private reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Get required permissions from decorator metadata
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      'permissions',
      [context.getHandler(), context.getClass()],
    );

    // If no permissions specified, allow access
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Check if user is authenticated
    if (!user || !user.id) {
      this.logger.warn('PermissionsGuard: User not authenticated');
      throw new UnauthorizedException('Authentication required');
    }

    try {
      // Fetch user profile from database to get role
      const userProfile = await this.prisma.userProfile.findUnique({
        where: { id: user.id },
        select: { role: true, is_active: true, email: true },
      });

      // Check if user exists and is active
      if (!userProfile) {
        this.logger.warn(
          `PermissionsGuard: User profile not found for ID: ${user.id}`,
        );
        throw new UnauthorizedException('User profile not found');
      }

      if (!userProfile.is_active) {
        this.logger.warn(
          `PermissionsGuard: Inactive user attempted access: ${userProfile.email}`,
        );
        throw new ForbiddenException('User account is inactive');
      }

      // Get permissions for user's role
      const userPermissions = ROLE_PERMISSIONS[userProfile.role] || [];

      // Check if user has wildcard permission (admin)
      if (userPermissions.includes('*')) {
        this.logger.log(
          `Admin ${userProfile.email} authorized with wildcard permissions`,
        );
        return true;
      }

      // Check if user has all required permissions
      const missingPermissions = requiredPermissions.filter(
        (permission) => !userPermissions.includes(permission),
      );

      if (missingPermissions.length > 0) {
        this.logger.warn(
          `PermissionsGuard: User ${userProfile.email} (${userProfile.role}) missing permissions: ${missingPermissions.join(', ')}`,
        );
        throw new ForbiddenException(
          `Missing required permissions: ${missingPermissions.join(', ')}`,
        );
      }

      // Log successful authorization
      this.logger.log(
        `User ${userProfile.email} authorized with permissions: ${requiredPermissions.join(', ')}`,
      );

      return true;
    } catch (error) {
      // Re-throw HTTP exceptions
      if (
        error instanceof UnauthorizedException ||
        error instanceof ForbiddenException
      ) {
        throw error;
      }

      // Log and throw database errors
      this.logger.error(
        `PermissionsGuard: Database error checking permissions: ${error.message}`,
        error.stack,
      );
      throw new UnauthorizedException('Unable to verify user permissions');
    }
  }
}
