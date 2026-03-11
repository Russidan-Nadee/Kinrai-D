import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request } from 'express';
import { CacheService } from '../services/cache.service';

@Injectable()
export class RateLimitGuard implements CanActivate {
  private readonly logger = new Logger(RateLimitGuard.name);
  private readonly limit = 20;
  private readonly windowSecs = 60;

  constructor(private readonly cacheService: CacheService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<Request>();
    const forwarded = req.headers['x-forwarded-for'] as string | undefined;
    const ip = forwarded?.split(',')[0]?.trim() ?? req.ip ?? 'unknown';

    const key = `rate_limit:random:${ip}`;
    const count = (await this.cacheService.get<number>(key)) ?? 0;

    if (count >= this.limit) {
      this.logger.warn(`Rate limit exceeded for IP: ${ip}`);
      throw new HttpException('Too Many Requests', HttpStatus.TOO_MANY_REQUESTS);
    }

    await this.cacheService.set(key, count + 1, { ttl: this.windowSecs });
    return true;
  }
}
