import { SetMetadata } from '@nestjs/common';

export const CACHE_KEY_METADATA = 'cache:key';
export const CACHE_TTL_METADATA = 'cache:ttl';
export const CACHE_TAGS_METADATA = 'cache:tags';

export interface CacheDecoratorOptions {
  key?: string;
  ttl?: number;
  tags?: string[];
}

/**
 * Cache decorator for methods
 * @param options Caching options
 */
export const Cacheable = (options: CacheDecoratorOptions = {}) => {
  return (target: any, propertyKey: string, descriptor: PropertyDescriptor) => {
    SetMetadata(CACHE_KEY_METADATA, options.key || `${target.constructor.name}:${propertyKey}`)(target, propertyKey, descriptor);
    SetMetadata(CACHE_TTL_METADATA, options.ttl || 3600)(target, propertyKey, descriptor);
    SetMetadata(CACHE_TAGS_METADATA, options.tags || [])(target, propertyKey, descriptor);
  };
};

/**
 * Cache eviction decorator
 * @param patterns Cache key patterns to invalidate
 */
export const CacheEvict = (patterns: string | string[]) => {
  return SetMetadata('cache:evict', Array.isArray(patterns) ? patterns : [patterns]);
};

/**
 * Cache eviction by tags decorator
 * @param tags Tags to invalidate
 */
export const CacheEvictByTags = (tags: string | string[]) => {
  return SetMetadata('cache:evict:tags', Array.isArray(tags) ? tags : [tags]);
};