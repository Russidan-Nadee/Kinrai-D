import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger
} from '@nestjs/common';
import { Observable, of } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Reflector } from '@nestjs/core';
import { CacheService } from '../services/cache.service';
import { CACHE_KEY_METADATA, CACHE_TTL_METADATA, CACHE_TAGS_METADATA } from '../decorators/cache.decorator';

@Injectable()
export class CacheInterceptor implements NestInterceptor {
  private readonly logger = new Logger(CacheInterceptor.name);

  constructor(
    private readonly cacheService: CacheService,
    private readonly reflector: Reflector
  ) {}

  async intercept(context: ExecutionContext, next: CallHandler): Promise<Observable<any>> {
    const cacheKey = this.reflector.get<string>(CACHE_KEY_METADATA, context.getHandler());
    const cacheTTL = this.reflector.get<number>(CACHE_TTL_METADATA, context.getHandler());
    const cacheTags = this.reflector.get<string[]>(CACHE_TAGS_METADATA, context.getHandler());

    if (!cacheKey) {
      return next.handle();
    }

    // Build dynamic cache key based on method arguments
    const request = context.switchToHttp().getRequest();
    const dynamicKey = this.buildDynamicKey(cacheKey, context.getArgs(), request);

    try {
      // Try to get from cache first
      const cachedResult = await this.cacheService.get(dynamicKey);
      if (cachedResult !== null) {
        this.logger.debug(`Cache hit for key: ${dynamicKey}`);
        return of(cachedResult);
      }

      this.logger.debug(`Cache miss for key: ${dynamicKey}`);
      
      // Execute the method and cache the result
      return next.handle().pipe(
        tap(async (result) => {
          if (result !== null && result !== undefined) {
            if (cacheTags && cacheTags.length > 0) {
              await this.cacheService.setWithTags(
                dynamicKey, 
                result, 
                cacheTags, 
                { ttl: cacheTTL }
              );
            } else {
              await this.cacheService.set(
                dynamicKey, 
                result, 
                { ttl: cacheTTL }
              );
            }
            this.logger.debug(`Cached result for key: ${dynamicKey}`);
          }
        })
      );
    } catch (error) {
      this.logger.error(`Cache interceptor error for key ${dynamicKey}:`, error);
      return next.handle();
    }
  }

  private buildDynamicKey(baseKey: string, args: any[], request?: any): string {
    // Include method arguments in cache key
    const argsKey = this.serializeArgs(args);
    
    // Include relevant request parameters
    let requestKey = '';
    if (request) {
      const { query, params, body } = request;
      const relevantData = {
        query: this.filterRelevantParams(query),
        params: this.filterRelevantParams(params),
        body: this.filterRelevantParams(body)
      };
      requestKey = this.hash(JSON.stringify(relevantData));
    }

    return `${baseKey}:${argsKey}:${requestKey}`;
  }

  private serializeArgs(args: any[]): string {
    try {
      // Filter out complex objects that shouldn't be part of cache key
      const simplifiedArgs = args.map(arg => {
        if (typeof arg === 'object' && arg !== null) {
          // Only include serializable properties
          return this.getSerializableProperties(arg);
        }
        return arg;
      });

      return this.hash(JSON.stringify(simplifiedArgs));
    } catch (error) {
      this.logger.warn('Error serializing arguments for cache key:', error);
      return 'default';
    }
  }

  private getSerializableProperties(obj: any): any {
    const result: any = {};
    
    for (const [key, value] of Object.entries(obj)) {
      if (typeof value === 'string' || 
          typeof value === 'number' || 
          typeof value === 'boolean' ||
          value === null ||
          value === undefined) {
        result[key] = value;
      } else if (Array.isArray(value)) {
        result[key] = value.filter(item => 
          typeof item === 'string' || 
          typeof item === 'number' || 
          typeof item === 'boolean'
        );
      }
    }

    return result;
  }

  private filterRelevantParams(params: any): any {
    if (!params || typeof params !== 'object') {
      return {};
    }

    // Filter out sensitive or irrelevant parameters
    const irrelevantKeys = ['password', 'token', 'auth', 'session'];
    const filtered: any = {};

    for (const [key, value] of Object.entries(params)) {
      if (!irrelevantKeys.some(irrelevant => key.toLowerCase().includes(irrelevant))) {
        filtered[key] = value;
      }
    }

    return filtered;
  }

  private hash(str: string): string {
    let hash = 0;
    if (str.length === 0) return hash.toString();
    
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    
    return Math.abs(hash).toString(36);
  }
}