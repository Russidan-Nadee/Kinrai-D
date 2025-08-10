import { Controller, Get, Query } from '@nestjs/common';
import { AdminAnalyticsService } from '../services/admin-analytics.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import { AnalyticsQueryDto } from '../dto/analytics-query.dto';

@Controller('admin/analytics')
@AdminOnly()
export class AdminAnalyticsController {
  constructor(private readonly analyticsService: AdminAnalyticsService) {}

  @Get('users')
  async getUserAnalytics(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getUserAnalytics(query);
  }

  @Get('menus')
  async getMenuAnalytics(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getMenuAnalytics(query);
  }

  @Get('ratings')
  async getRatingAnalytics(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getRatingAnalytics(query);
  }

  @Get('popular-items')
  async getPopularItems(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getPopularItems(query);
  }

  @Get('trends')
  async getTrends(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getTrends(query);
  }
}