import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface LogContext {
  userId?: string;
  requestId?: string;
  userAgent?: string;
  ip?: string;
  method?: string;
  url?: string;
  statusCode?: number;
  responseTime?: number;
  error?: any;
  metadata?: Record<string, any>;
}

export interface PerformanceMetrics {
  operation: string;
  duration: number;
  timestamp: Date;
  success: boolean;
  error?: string;
  metadata?: Record<string, any>;
}

export interface UserActivity {
  userId: string;
  action: string;
  resource: string;
  resourceId?: string;
  timestamp: Date;
  metadata?: Record<string, any>;
}

@Injectable()
export class LoggingService {
  private readonly logger = new Logger(LoggingService.name);
  private readonly isProduction: boolean;

  constructor(private configService: ConfigService) {
    this.isProduction = this.configService.get('NODE_ENV') === 'production';
  }

  /**
   * Log API requests and responses
   */
  logApiCall(context: LogContext): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: this.getLogLevel(context.statusCode),
      message: `${context.method} ${context.url} ${context.statusCode}`,
      context: {
        method: context.method,
        url: context.url,
        statusCode: context.statusCode,
        responseTime: context.responseTime,
        userAgent: context.userAgent,
        ip: context.ip,
        userId: context.userId,
        requestId: context.requestId
      },
      ...(context.error && { error: this.sanitizeError(context.error) }),
      ...(context.metadata && { metadata: context.metadata })
    };

    this.writeLog(logData);
  }

  /**
   * Log performance metrics
   */
  logPerformance(metrics: PerformanceMetrics): void {
    const logData = {
      timestamp: metrics.timestamp.toISOString(),
      level: 'info',
      type: 'performance',
      message: `Operation ${metrics.operation} completed in ${metrics.duration}ms`,
      metrics: {
        operation: metrics.operation,
        duration: metrics.duration,
        success: metrics.success,
        ...(metrics.error && { error: metrics.error }),
        ...(metrics.metadata && { metadata: metrics.metadata })
      }
    };

    this.writeLog(logData);

    // Alert if performance is poor
    if (metrics.duration > 5000) { // 5 seconds
      this.logger.warn(`Slow operation detected: ${metrics.operation} took ${metrics.duration}ms`);
    }
  }

  /**
   * Log user activities for analytics
   */
  logUserActivity(activity: UserActivity): void {
    const logData = {
      timestamp: activity.timestamp.toISOString(),
      level: 'info',
      type: 'user_activity',
      message: `User ${activity.userId} performed ${activity.action} on ${activity.resource}`,
      activity: {
        userId: activity.userId,
        action: activity.action,
        resource: activity.resource,
        resourceId: activity.resourceId,
        ...(activity.metadata && { metadata: activity.metadata })
      }
    };

    this.writeLog(logData);
  }

  /**
   * Log business events
   */
  logBusinessEvent(event: string, data: Record<string, any>, userId?: string): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: 'info',
      type: 'business_event',
      message: `Business event: ${event}`,
      event: {
        name: event,
        userId,
        data
      }
    };

    this.writeLog(logData);
  }

  /**
   * Log security events
   */
  logSecurityEvent(event: string, context: LogContext, severity: 'low' | 'medium' | 'high' = 'medium'): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: severity === 'high' ? 'error' : 'warn',
      type: 'security',
      message: `Security event: ${event}`,
      security: {
        event,
        severity,
        ip: context.ip,
        userAgent: context.userAgent,
        userId: context.userId,
        url: context.url,
        method: context.method,
        ...(context.metadata && { metadata: context.metadata })
      }
    };

    this.writeLog(logData);

    // Immediate alert for high severity events
    if (severity === 'high') {
      this.logger.error(`HIGH SEVERITY SECURITY EVENT: ${event}`, logData);
    }
  }

  /**
   * Log errors with context
   */
  logError(error: Error, context?: LogContext): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: 'error',
      type: 'error',
      message: error.message,
      error: {
        name: error.name,
        message: error.message,
        stack: this.isProduction ? undefined : error.stack,
        ...(context && {
          context: {
            method: context.method,
            url: context.url,
            userId: context.userId,
            requestId: context.requestId,
            ip: context.ip,
            userAgent: context.userAgent
          }
        })
      }
    };

    this.writeLog(logData);
  }

  /**
   * Log cache operations
   */
  logCacheOperation(operation: 'hit' | 'miss' | 'set' | 'del', key: string, duration?: number): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: 'debug',
      type: 'cache',
      message: `Cache ${operation}: ${key}`,
      cache: {
        operation,
        key,
        ...(duration && { duration })
      }
    };

    this.writeLog(logData);
  }

  /**
   * Log search operations for analytics
   */
  logSearchOperation(query: string, results: number, duration: number, userId?: string): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: 'info',
      type: 'search',
      message: `Search performed: "${query}" returned ${results} results`,
      search: {
        query: this.sanitizeSearchQuery(query),
        results,
        duration,
        userId
      }
    };

    this.writeLog(logData);
  }

  /**
   * Log recommendation operations
   */
  logRecommendationOperation(
    type: string, 
    userId?: string, 
    results: number = 0, 
    duration: number = 0,
    metadata?: Record<string, any>
  ): void {
    const logData = {
      timestamp: new Date().toISOString(),
      level: 'info',
      type: 'recommendation',
      message: `Recommendation generated: ${type} for user ${userId || 'anonymous'}`,
      recommendation: {
        type,
        userId,
        results,
        duration,
        ...(metadata && { metadata })
      }
    };

    this.writeLog(logData);
  }

  /**
   * Create a performance tracker
   */
  createPerformanceTracker(operation: string): {
    finish: (success?: boolean, metadata?: Record<string, any>) => void;
  } {
    const startTime = Date.now();
    
    return {
      finish: (success: boolean = true, metadata?: Record<string, any>) => {
        const duration = Date.now() - startTime;
        this.logPerformance({
          operation,
          duration,
          timestamp: new Date(),
          success,
          metadata
        });
      }
    };
  }

  /**
   * Get aggregated error rates
   */
  async getErrorMetrics(hours: number = 24): Promise<{
    totalErrors: number;
    errorRate: number;
    topErrors: { error: string; count: number }[];
  }> {
    // This would typically query a logging database or service
    // For now, return mock data
    return {
      totalErrors: 0,
      errorRate: 0,
      topErrors: []
    };
  }

  /**
   * Get performance metrics
   */
  async getPerformanceMetrics(hours: number = 24): Promise<{
    averageResponseTime: number;
    slowestOperations: { operation: string; averageTime: number }[];
    requestsPerHour: number;
  }> {
    // This would typically query a monitoring system
    return {
      averageResponseTime: 0,
      slowestOperations: [],
      requestsPerHour: 0
    };
  }

  // Private helper methods
  private getLogLevel(statusCode?: number): string {
    if (!statusCode) return 'info';
    if (statusCode >= 500) return 'error';
    if (statusCode >= 400) return 'warn';
    return 'info';
  }

  private sanitizeError(error: any): any {
    if (error instanceof Error) {
      return {
        name: error.name,
        message: error.message,
        stack: this.isProduction ? undefined : error.stack
      };
    }
    return error;
  }

  private sanitizeSearchQuery(query: string): string {
    // Remove potential PII or sensitive information
    return query.replace(/\b\d{4,}\b/g, '[REDACTED]'); // Remove potential IDs/phone numbers
  }

  private writeLog(logData: any): void {
    // In production, this would write to structured logging system
    // (e.g., ELK stack, CloudWatch, etc.)
    
    switch (logData.level) {
      case 'error':
        this.logger.error(JSON.stringify(logData));
        break;
      case 'warn':
        this.logger.warn(JSON.stringify(logData));
        break;
      case 'debug':
        this.logger.debug(JSON.stringify(logData));
        break;
      default:
        this.logger.log(JSON.stringify(logData));
    }

    // In production, also send to external monitoring services
    if (this.isProduction) {
      this.sendToMonitoringService(logData);
    }
  }

  private async sendToMonitoringService(logData: any): Promise<void> {
    // This would integrate with external monitoring services
    // like DataDog, New Relic, Sentry, etc.
    try {
      // Example: await this.datadogService.log(logData);
      // Example: await this.sentryService.log(logData);
    } catch (error) {
      // Don't let logging errors break the application
      this.logger.error('Failed to send log to monitoring service:', error);
    }
  }
}