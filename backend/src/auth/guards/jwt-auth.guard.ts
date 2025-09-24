import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(JwtAuthGuard.name);
  private supabase;

  constructor(private configService: ConfigService) {
    // Initialize Supabase client
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY');

    if (!supabaseUrl || !supabaseKey) {
      this.logger.error(
        'Supabase configuration missing. Set SUPABASE_URL and SUPABASE_ANON_KEY in environment variables.',
      );
    } else {
      this.supabase = createClient(supabaseUrl, supabaseKey);
    }
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      this.logger.warn('No authorization token provided');
      throw new UnauthorizedException('Access token is required');
    }

    try {
      // Verify token with Supabase
      const {
        data: { user },
        error,
      } = await this.supabase.auth.getUser(token);

      if (error || !user) {
        this.logger.warn(`Token verification failed: ${error?.message}`);
        throw new UnauthorizedException('Invalid or expired token');
      }

      // Add user to request object
      request.user = {
        id: user.id,
        email: user.email,
        ...user.user_metadata,
      };

      this.logger.debug(`User authenticated: ${user.email}`);
      return true;
    } catch (error) {
      this.logger.error(`Authentication error: ${error.message}`);
      throw new UnauthorizedException('Authentication failed');
    }
  }

  private extractTokenFromHeader(request: any): string | undefined {
    const authHeader = request.headers.authorization;
    if (!authHeader) {
      return undefined;
    }

    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : undefined;
  }
}
