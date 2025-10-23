import { Processor, Process } from '@nestjs/bull';
import { Logger } from '@nestjs/common';
import type { Job } from 'bull';
import { AdminAnalyticsService } from '../../admin/services/admin-analytics.service';
import { CacheService } from '../../common/services/cache.service';
import { AnalyticsQueryDto } from '../../admin/dto/analytics-query.dto';

export const ANALYTICS_QUEUE = 'analytics';

export interface AnalyticsJobData {
  type: 'user' | 'menu' | 'rating' | 'popular' | 'trends';
  query: AnalyticsQueryDto;
  cacheKey: string;
}

@Processor(ANALYTICS_QUEUE)
export class AnalyticsProcessor {
  private readonly logger = new Logger(AnalyticsProcessor.name);

  constructor(
    private readonly analyticsService: AdminAnalyticsService,
    private readonly cacheService: CacheService,
  ) {}

  @Process('user-analytics')
  async handleUserAnalytics(job: Job<AnalyticsJobData>) {
    this.logger.log(`Processing user analytics job ${job.id}`);

    try {
      const result = await this.analyticsService.getUserAnalytics(
        job.data.query,
      );

      // Cache result for 1 hour
      await this.cacheService.set(job.data.cacheKey, result, { ttl: 3600 });

      this.logger.log(`Completed user analytics job ${job.id}`);
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process user analytics job ${job.id}:`,
        error,
      );
      throw error;
    }
  }

  @Process('menu-analytics')
  async handleMenuAnalytics(job: Job<AnalyticsJobData>) {
    this.logger.log(`Processing menu analytics job ${job.id}`);

    try {
      const result = await this.analyticsService.getMenuAnalytics(
        job.data.query,
      );

      // Cache result for 30 minutes
      await this.cacheService.set(job.data.cacheKey, result, { ttl: 1800 });

      this.logger.log(`Completed menu analytics job ${job.id}`);
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process menu analytics job ${job.id}:`,
        error,
      );
      throw error;
    }
  }

  @Process('rating-analytics')
  async handleRatingAnalytics(job: Job<AnalyticsJobData>) {
    this.logger.log(`Processing rating analytics job ${job.id}`);

    try {
      const result = await this.analyticsService.getRatingAnalytics(
        job.data.query,
      );

      // Cache result for 30 minutes
      await this.cacheService.set(job.data.cacheKey, result, { ttl: 1800 });

      this.logger.log(`Completed rating analytics job ${job.id}`);
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process rating analytics job ${job.id}:`,
        error,
      );
      throw error;
    }
  }

  @Process('popular-items')
  async handlePopularItems(job: Job<AnalyticsJobData>) {
    this.logger.log(`Processing popular items job ${job.id}`);

    try {
      const result = await this.analyticsService.getPopularItems(
        job.data.query,
      );

      // Cache result for 15 minutes
      await this.cacheService.set(job.data.cacheKey, result, { ttl: 900 });

      this.logger.log(`Completed popular items job ${job.id}`);
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process popular items job ${job.id}:`,
        error,
      );
      throw error;
    }
  }

  @Process('trends')
  async handleTrends(job: Job<AnalyticsJobData>) {
    this.logger.log(`Processing trends job ${job.id}`);

    try {
      const result = await this.analyticsService.getTrends(job.data.query);

      // Cache result for 1 hour
      await this.cacheService.set(job.data.cacheKey, result, { ttl: 3600 });

      this.logger.log(`Completed trends job ${job.id}`);
      return result;
    } catch (error) {
      this.logger.error(`Failed to process trends job ${job.id}:`, error);
      throw error;
    }
  }
}
