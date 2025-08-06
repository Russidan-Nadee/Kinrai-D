import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger
} from '@nestjs/common';
import { SupabaseService } from '../supabase.service';
import { LoggingService } from '../../common/services/logging.service';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(SupabaseAuthGuard.name);

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly loggingService: LoggingService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      this.loggingService.logSecurityEvent('auth_missing_token', {
        ip: request.ip,
        userAgent: request.get('User-Agent'),
        url: request.url,
        method: request.method
      }, 'medium');
      
      throw new UnauthorizedException('Authentication token is required');
    }

    try {
      const user = await this.supabaseService.verifyToken(token);
      
      // Attach user to request object
      request.user = user;
      request.token = token;
      
      // Log successful authentication
      this.loggingService.logUserActivity({
        userId: user.id,
        action: 'authenticate',
        resource: 'auth',
        timestamp: new Date(),
        metadata: {
          endpoint: request.url,
          method: request.method
        }
      });

      return true;
    } catch (error) {
      this.logger.warn('Authentication failed:', error.message);
      
      this.loggingService.logSecurityEvent('auth_failed', {
        ip: request.ip,
        userAgent: request.get('User-Agent'),
        url: request.url,
        method: request.method,
        metadata: { error: error.message }
      }, 'high');
      
      throw new UnauthorizedException('Invalid or expired token');
    }
  }

  private extractTokenFromHeader(request: any): string | null {
    const authHeader = request.headers.authorization;
    if (!authHeader) {
      return null;
    }

    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : null;
  }
}