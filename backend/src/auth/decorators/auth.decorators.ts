import {
  SetMetadata,
  createParamDecorator,
  ExecutionContext,
  UseGuards,
  applyDecorators,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiUnauthorizedResponse,
  ApiForbiddenResponse,
} from '@nestjs/swagger';
import { RolesGuard } from '../guards/roles.guard';
import { PermissionsGuard } from '../guards/permissions.guard';
import { AuthRequest, TokenRequest } from '../../common/types/request.types';

/**
 * Set required roles for endpoint
 */
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);

/**
 * Set required permissions for endpoint
 */
export const Permissions = (...permissions: string[]) =>
  SetMetadata('permissions', permissions);

/**
 * Get current user from request
 */
export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<AuthRequest>();
    const user = request.user;

    if (data) {
      // Type assertion for property access
      return (user as unknown as Record<string, unknown>)[data];
    }
    return user;
  },
);

/**
 * Get current user ID from request
 */
export const UserId = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest<AuthRequest>();
    return request.user?.id;
  },
);

/**
 * Get auth token from request
 */
export const AuthToken = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest<TokenRequest>();
    return request.token;
  },
);

/**
 * Combined decorator for role-based authorization (requires custom auth guard implementation)
 */
export const AuthRoles = (...roles: string[]) =>
  applyDecorators(
    UseGuards(RolesGuard),
    Roles(...roles),
    ApiBearerAuth(),
    ApiUnauthorizedResponse({ description: 'Unauthorized' }),
    ApiForbiddenResponse({ description: 'Forbidden - Insufficient role' }),
  );

/**
 * Combined decorator for permission-based authorization (requires custom auth guard implementation)
 */
export const AuthPermissions = (...permissions: string[]) =>
  applyDecorators(
    UseGuards(PermissionsGuard),
    Permissions(...permissions),
    ApiBearerAuth(),
    ApiUnauthorizedResponse({ description: 'Unauthorized' }),
    ApiForbiddenResponse({
      description: 'Forbidden - Insufficient permissions',
    }),
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
 * Optional authentication decorator
 */
export const OptionalAuth = () =>
  applyDecorators(
    // This would need a custom guard that doesn't throw on missing auth
    ApiBearerAuth(),
  );
