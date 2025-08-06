import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

export interface CacheOptions {
  ttl?: number; // Time to live in seconds
  prefix?: string;
  compress?: boolean;
}

export interface CacheStats {
  hits: number;
  misses: number;
  keys: number;
  memory: string;
}

@Injectable()
export class CacheService implements OnModuleDestroy {
  private readonly logger = new Logger(CacheService.name);
  private readonly redis: Redis;
  private readonly defaultTTL = 3600; // 1 hour
  private readonly keyPrefix = 'kinrai:';
  
  // Cache statistics
  private stats = {
    hits: 0,
    misses: 0
  };

  constructor(private configService: ConfigService) {
    const redisConfig = {
      host: this.configService.get('REDIS_HOST', 'localhost'),
      port: this.configService.get('REDIS_PORT', 6379),
      password: this.configService.get('REDIS_PASSWORD'),
      db: this.configService.get('REDIS_DB', 0),
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3,
      lazyConnect: true,
    };

    this.redis = new Redis(redisConfig);

    this.redis.on('connect', () => {
      this.logger.log('Redis connected successfully');
    });

    this.redis.on('error', (error) => {
      this.logger.error('Redis connection error:', error);
    });

    this.redis.on('reconnecting', () => {
      this.logger.warn('Redis reconnecting...');
    });
  }

  async onModuleDestroy() {
    await this.redis.quit();
  }

  /**
   * Get value from cache
   */
  async get<T>(key: string): Promise<T | null> {
    try {
      const fullKey = this.buildKey(key);
      const value = await this.redis.get(fullKey);
      
      if (value === null) {
        this.stats.misses++;
        return null;
      }

      this.stats.hits++;
      return JSON.parse(value);
    } catch (error) {
      this.logger.error(`Cache get error for key ${key}:`, error);
      return null;
    }
  }

  /**
   * Set value in cache
   */
  async set<T>(key: string, value: T, options?: CacheOptions): Promise<void> {
    try {
      const fullKey = this.buildKey(key, options?.prefix);
      const serializedValue = JSON.stringify(value);
      const ttl = options?.ttl || this.defaultTTL;

      await this.redis.setex(fullKey, ttl, serializedValue);
    } catch (error) {
      this.logger.error(`Cache set error for key ${key}:`, error);
    }
  }

  /**
   * Delete from cache
   */
  async del(key: string | string[]): Promise<number> {
    try {
      const keys = Array.isArray(key) ? key : [key];
      const fullKeys = keys.map(k => this.buildKey(k));
      return await this.redis.del(...fullKeys);
    } catch (error) {
      this.logger.error(`Cache delete error:`, error);
      return 0;
    }
  }

  /**
   * Check if key exists
   */
  async exists(key: string): Promise<boolean> {
    try {
      const fullKey = this.buildKey(key);
      const result = await this.redis.exists(fullKey);
      return result === 1;
    } catch (error) {
      this.logger.error(`Cache exists error for key ${key}:`, error);
      return false;
    }
  }

  /**
   * Set TTL for existing key
   */
  async expire(key: string, ttl: number): Promise<boolean> {
    try {
      const fullKey = this.buildKey(key);
      const result = await this.redis.expire(fullKey, ttl);
      return result === 1;
    } catch (error) {
      this.logger.error(`Cache expire error for key ${key}:`, error);
      return false;
    }
  }

  /**
   * Get or set pattern - fetch from cache, or execute function and cache result
   */
  async getOrSet<T>(
    key: string,
    fetchFn: () => Promise<T>,
    options?: CacheOptions
  ): Promise<T> {
    const cached = await this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    const result = await fetchFn();
    await this.set(key, result, options);
    return result;
  }

  /**
   * Invalidate cache by pattern
   */
  async invalidatePattern(pattern: string): Promise<number> {
    try {
      const fullPattern = this.buildKey(pattern);
      const keys = await this.redis.keys(fullPattern);
      
      if (keys.length === 0) {
        return 0;
      }

      return await this.redis.del(...keys);
    } catch (error) {
      this.logger.error(`Cache invalidate pattern error:`, error);
      return 0;
    }
  }

  /**
   * Cache frequently accessed data with tags for easy invalidation
   */
  async setWithTags<T>(
    key: string,
    value: T,
    tags: string[],
    options?: CacheOptions
  ): Promise<void> {
    await this.set(key, value, options);
    
    // Store tags for this key
    const tagKey = this.buildKey(`tags:${key}`);
    await this.set(tagKey, tags, { ttl: (options?.ttl || this.defaultTTL) + 60 });
    
    // Add key to each tag's key list
    for (const tag of tags) {
      const tagListKey = this.buildKey(`tag_keys:${tag}`);
      await this.redis.sadd(tagListKey, key);
      await this.redis.expire(tagListKey, (options?.ttl || this.defaultTTL) + 60);
    }
  }

  /**
   * Invalidate all keys with specific tag
   */
  async invalidateByTag(tag: string): Promise<number> {
    try {
      const tagListKey = this.buildKey(`tag_keys:${tag}`);
      const keys = await this.redis.smembers(tagListKey);
      
      if (keys.length === 0) {
        return 0;
      }

      // Delete the actual keys and their tag references
      const fullKeys = keys.map(key => this.buildKey(key));
      const tagKeys = keys.map(key => this.buildKey(`tags:${key}`));
      
      await Promise.all([
        this.redis.del(...fullKeys),
        this.redis.del(...tagKeys),
        this.redis.del(tagListKey)
      ]);

      return keys.length;
    } catch (error) {
      this.logger.error(`Cache invalidate by tag error:`, error);
      return 0;
    }
  }

  /**
   * Get cache statistics
   */
  async getStats(): Promise<CacheStats> {
    try {
      const info = await this.redis.info('memory');
      const keyspace = await this.redis.info('keyspace');
      
      const memoryMatch = info.match(/used_memory_human:(.+)/);
      const keysMatch = keyspace.match(/keys=(\d+)/);
      
      return {
        hits: this.stats.hits,
        misses: this.stats.misses,
        keys: keysMatch ? parseInt(keysMatch[1]) : 0,
        memory: memoryMatch ? memoryMatch[1].trim() : 'N/A'
      };
    } catch (error) {
      this.logger.error('Error getting cache stats:', error);
      return {
        hits: this.stats.hits,
        misses: this.stats.misses,
        keys: 0,
        memory: 'N/A'
      };
    }
  }

  /**
   * Warm up cache with frequently accessed data
   */
  async warmUp(): Promise<void> {
    this.logger.log('Starting cache warm-up...');
    
    try {
      // This would typically load commonly accessed data
      // For now, we'll just log that warm-up is starting
      this.logger.log('Cache warm-up completed');
    } catch (error) {
      this.logger.error('Cache warm-up failed:', error);
    }
  }

  /**
   * Health check for cache
   */
  async healthCheck(): Promise<{ status: 'healthy' | 'unhealthy'; latency: number }> {
    const start = Date.now();
    
    try {
      await this.redis.ping();
      const latency = Date.now() - start;
      return { status: 'healthy', latency };
    } catch (error) {
      const latency = Date.now() - start;
      this.logger.error('Cache health check failed:', error);
      return { status: 'unhealthy', latency };
    }
  }

  /**
   * Build full cache key with prefix
   */
  private buildKey(key: string, prefix?: string): string {
    const actualPrefix = prefix || this.keyPrefix;
    return `${actualPrefix}${key}`;
  }

  /**
   * Reset cache statistics
   */
  resetStats(): void {
    this.stats = { hits: 0, misses: 0 };
  }
}