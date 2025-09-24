import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { LoggingService } from '../services/logging.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  constructor(private readonly loggingService: LoggingService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const startTime = Date.now();

    // Generate unique request ID
    const requestId = uuidv4();
    request.requestId = requestId;

    // Extract request information
    const { method, url, headers, body } = request;
    const userAgent = headers['user-agent'];
    const ip = this.extractClientIP(request);
    const userId = this.extractUserId(request);

    // Log request start
    this.loggingService.logApiCall({
      requestId,
      method,
      url,
      userAgent,
      ip,
      userId,
      metadata: {
        body: this.sanitizeRequestBody(body),
        headers: this.sanitizeHeaders(headers),
        timestamp: new Date().toISOString(),
      },
    });

    return next.handle().pipe(
      tap((responseData) => {
        const responseTime = Date.now() - startTime;
        const statusCode = response.statusCode;

        // Log successful response
        this.loggingService.logApiCall({
          requestId,
          method,
          url,
          statusCode,
          responseTime,
          userAgent,
          ip,
          userId,
          metadata: {
            responseSize: JSON.stringify(responseData).length,
            cacheHit: response.getHeader('X-Cache-Status') === 'HIT',
          },
        });

        // Log slow requests
        if (responseTime > 1000) {
          this.logger.warn(
            `Slow request detected: ${method} ${url} took ${responseTime}ms`,
          );
        }

        // Log user activity based on the endpoint
        if (userId) {
          this.logUserActivity(method, url, userId, responseData);
        }
      }),
      catchError((error) => {
        const responseTime = Date.now() - startTime;
        const statusCode = error.status || 500;

        // Log error response
        this.loggingService.logApiCall({
          requestId,
          method,
          url,
          statusCode,
          responseTime,
          userAgent,
          ip,
          userId,
          error,
          metadata: {
            errorType: error.constructor.name,
            errorMessage: error.message,
          },
        });

        // Log error for monitoring
        this.loggingService.logError(error, {
          requestId,
          method,
          url,
          userId,
          ip,
          userAgent,
        });

        return throwError(error);
      }),
    );
  }

  private extractClientIP(request: any): string {
    return (
      request.ip ||
      request.connection.remoteAddress ||
      request.socket.remoteAddress ||
      (request.connection.socket
        ? request.connection.socket.remoteAddress
        : null) ||
      request.headers['x-forwarded-for']?.split(',')[0] ||
      request.headers['x-real-ip'] ||
      'unknown'
    );
  }

  private extractUserId(request: any): string | undefined {
    // Extract user ID from JWT token, session, or other auth mechanism
    return request.user?.id || request.user?.userId;
  }

  private sanitizeRequestBody(body: any): any {
    if (!body) return undefined;

    // Remove sensitive information
    const sanitized = { ...body };
    const sensitiveFields = ['password', 'token', 'secret', 'key', 'auth'];

    for (const field of sensitiveFields) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }

    return sanitized;
  }

  private sanitizeHeaders(headers: any): any {
    const sanitized = { ...headers };
    const sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];

    for (const header of sensitiveHeaders) {
      if (sanitized[header]) {
        sanitized[header] = '[REDACTED]';
      }
    }

    return sanitized;
  }

  private logUserActivity(
    method: string,
    url: string,
    userId: string,
    responseData?: any,
  ): void {
    let action = 'unknown';
    let resource = 'unknown';
    let resourceId: string | undefined;

    // Map HTTP methods and URLs to user actions
    if (method === 'GET') {
      if (url.includes('/menus/')) {
        action = 'view';
        resource = 'menu';
        resourceId = this.extractResourceId(url, '/menus/');
      } else if (url.includes('/menus')) {
        action = 'browse';
        resource = 'menus';
      } else if (url.includes('/search')) {
        action = 'search';
        resource = 'menus';
      } else if (url.includes('/recommendations')) {
        action = 'get_recommendations';
        resource = 'menus';
      }
    } else if (method === 'POST') {
      if (url.includes('/menus')) {
        action = 'create';
        resource = 'menu';
      } else if (url.includes('/favorites')) {
        action = 'favorite';
        resource = 'menu';
      } else if (url.includes('/ratings')) {
        action = 'rate';
        resource = 'menu';
      }
    } else if (method === 'PUT' || method === 'PATCH') {
      if (url.includes('/menus/')) {
        action = 'update';
        resource = 'menu';
        resourceId = this.extractResourceId(url, '/menus/');
      }
    } else if (method === 'DELETE') {
      if (url.includes('/menus/')) {
        action = 'delete';
        resource = 'menu';
        resourceId = this.extractResourceId(url, '/menus/');
      } else if (url.includes('/favorites/')) {
        action = 'unfavorite';
        resource = 'menu';
        resourceId = this.extractResourceId(url, '/favorites/');
      }
    }

    if (action !== 'unknown') {
      this.loggingService.logUserActivity({
        userId,
        action,
        resource,
        resourceId,
        timestamp: new Date(),
        metadata: {
          url,
          method,
          responseSize: responseData
            ? JSON.stringify(responseData).length
            : undefined,
        },
      });
    }
  }

  private extractResourceId(url: string, basePath: string): string | undefined {
    const parts = url.split(basePath);
    if (parts.length > 1) {
      const idPart = parts[1].split('/')[0].split('?')[0];
      return isNaN(Number(idPart)) ? undefined : idPart;
    }
    return undefined;
  }
}
