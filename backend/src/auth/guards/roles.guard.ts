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

@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(
    private reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Get required roles from decorator metadata
    const requiredRoles = this.reflector.getAllAndOverride<string[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);

    // If no roles specified, allow access
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Check if user is authenticated
    if (!user || !user.id) {
      this.logger.warn('RolesGuard: User not authenticated');
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
        this.logger.warn(`RolesGuard: User profile not found for ID: ${user.id}`);
        throw new UnauthorizedException('User profile not found');
      }

      if (!userProfile.is_active) {
        this.logger.warn(
          `RolesGuard: Inactive user attempted access: ${userProfile.email}`,
        );
        throw new ForbiddenException('User account is inactive');
      }

      // Normalize role names (convert lowercase decorator values to uppercase enum)
      const normalizedRequiredRoles = requiredRoles.map((role) =>
        role.toUpperCase(),
      );

      // Check if user has required role
      const hasRole = normalizedRequiredRoles.includes(userProfile.role);

      if (!hasRole) {
        this.logger.warn(
          `RolesGuard: User ${userProfile.email} (${userProfile.role}) attempted to access endpoint requiring roles: ${normalizedRequiredRoles.join(', ')}`,
        );
        throw new ForbiddenException(
          `Insufficient permissions. Required roles: ${normalizedRequiredRoles.join(', ')}`,
        );
      }

      // Log successful authorization
      this.logger.log(
        `User ${userProfile.email} authorized with role ${userProfile.role}`,
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
        `RolesGuard: Database error checking user role: ${error.message}`,
        error.stack,
      );
      throw new UnauthorizedException('Unable to verify user permissions');
    }
  }
}
