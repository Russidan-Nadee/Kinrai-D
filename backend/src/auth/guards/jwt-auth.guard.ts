import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

interface RequestWithHeaders extends Request {
  headers: {
    authorization?: string;
    [key: string]: string | undefined;
  };
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(JwtAuthGuard.name);
  private supabase: SupabaseClient | null = null;

  constructor(private configService: ConfigService) {
    this.logger.log('🔐 JwtAuthGuard constructor called');
    // Initialize Supabase client
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY');

    if (!supabaseUrl || !supabaseKey) {
      this.logger.error(
        'Supabase configuration missing. Set SUPABASE_URL and SUPABASE_ANON_KEY in environment variables.',
      );
    } else {
      this.supabase = createClient(supabaseUrl, supabaseKey);
      this.logger.log('✅ Supabase client initialized successfully');
    }
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    this.logger.log('🚀 JwtAuthGuard.canActivate() called');
    const request = context.switchToHttp().getRequest<RequestWithHeaders>();

    // Debug: Log the raw authorization header
    this.logger.debug(`Raw auth header: ${request.headers.authorization?.substring(0, 50)}...`);

    const token = this.extractTokenFromHeader(request);

    if (!token) {
      this.logger.warn('No authorization token provided');
      this.logger.debug(`Headers received: ${JSON.stringify(Object.keys(request.headers))}`);
      throw new UnauthorizedException('Access token is required');
    }

    this.logger.debug(`Token extracted successfully (length: ${token.length})`);

    if (!this.supabase) {
      this.logger.error('Supabase client not initialized');
      throw new UnauthorizedException('Authentication service unavailable');
    }

    try {
      // Verify token with Supabase
      const {
        data: { user },
        error,
      } = await this.supabase.auth.getUser(token);

      if (error || !user) {
        const errorMessage = error?.message || 'Unknown error';
        this.logger.warn(`Token verification failed: ${errorMessage}`);
        throw new UnauthorizedException('Invalid or expired token');
      }

      // Add user to request object
      const userMetadata = user.user_metadata || {};
      (
        request as RequestWithHeaders & {
          user: { id: string; email: string; [key: string]: unknown };
        }
      ).user = {
        id: user.id,
        email: user.email || '',
        ...userMetadata,
      };

      this.logger.debug(`User authenticated: ${user.email || 'unknown'}`);
      return true;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Authentication error: ${errorMessage}`);
      throw new UnauthorizedException('Authentication failed');
    }
  }

  private extractTokenFromHeader(
    request: RequestWithHeaders,
  ): string | undefined {
    const authHeader = request.headers.authorization;
    if (!authHeader) {
      return undefined;
    }

    // Remove any whitespace/newlines and split
    const cleanedHeader = authHeader.replace(/\s+/g, ' ').trim();
    const parts = cleanedHeader.split(' ');

    if (parts.length !== 2) {
      this.logger.warn(`Invalid authorization header format: ${parts.length} parts found`);
      return undefined;
    }

    const [type, token] = parts;
    return type === 'Bearer' ? token : undefined;
  }
}
