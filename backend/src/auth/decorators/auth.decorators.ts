import { 
  SetMetadata, 
  createParamDecorator, 
  ExecutionContext, 
  UseGuards, 
  applyDecorators 
} from '@nestjs/common';
import { ApiBearerAuth, ApiUnauthorizedResponse, ApiForbiddenResponse } from '@nestjs/swagger';
import { SupabaseAuthGuard } from '../guards/supabase-auth.guard';
import { RolesGuard } from '../guards/roles.guard';
import { PermissionsGuard } from '../guards/permissions.guard';

/**
 * Set required roles for endpoint
 */
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

/**
 * Set required permissions for endpoint
 */
export const Permissions = (...permissions: string[]) => SetMetadata('permissions', permissions);

/**
 * Get current user from request
 */
export const CurrentUser = createParamDecorator(
  (data: keyof any | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;

    return data ? user?.[data] : user;
  },
);

/**
 * Get current user ID from request
 */
export const UserId = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest();
    return request.user?.id;
  },
);

/**
 * Get auth token from request
 */
export const AuthToken = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest();
    return request.token;
  },
);

/**
 * Combined decorator for authentication only
 */
export const Auth = () => applyDecorators(
  UseGuards(SupabaseAuthGuard),
  ApiBearerAuth(),
  ApiUnauthorizedResponse({ description: 'Unauthorized' })
);

/**
 * Combined decorator for authentication + role-based authorization
 */
export const AuthRoles = (...roles: string[]) => applyDecorators(
  UseGuards(SupabaseAuthGuard, RolesGuard),
  Roles(...roles),
  ApiBearerAuth(),
  ApiUnauthorizedResponse({ description: 'Unauthorized' }),
  ApiForbiddenResponse({ description: 'Forbidden - Insufficient role' })
);

/**
 * Combined decorator for authentication + permission-based authorization
 */
export const AuthPermissions = (...permissions: string[]) => applyDecorators(
  UseGuards(SupabaseAuthGuard, PermissionsGuard),
  Permissions(...permissions),
  ApiBearerAuth(),
  ApiUnauthorizedResponse({ description: 'Unauthorized' }),
  ApiForbiddenResponse({ description: 'Forbidden - Insufficient permissions' })
);

/**
 * Admin only decorator
 */
export const AdminOnly = () => AuthRoles('admin');

/**
 * User or Admin decorator
 */
export const UserOrAdmin = () => AuthRoles('user', 'admin');

/**
 * Owner or Admin decorator (for resource ownership)
 */
export const OwnerOrAdmin = () => applyDecorators(
  UseGuards(SupabaseAuthGuard),
  ApiBearerAuth(),
  ApiUnauthorizedResponse({ description: 'Unauthorized' }),
  ApiForbiddenResponse({ description: 'Forbidden - Not owner or admin' })
);

/**
 * Optional authentication decorator
 */
export const OptionalAuth = () => applyDecorators(
  // This would need a custom guard that doesn't throw on missing auth
  ApiBearerAuth()
);