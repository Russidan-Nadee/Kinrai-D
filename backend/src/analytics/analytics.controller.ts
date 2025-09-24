import {
  Controller,
  Get,
  UseGuards,
  Request,
  Query,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('me')
  getUserAnalytics(@Request() req, @Query('language') language = 'en') {
    return this.analyticsService.getUserAnalytics(req.user.id, language);
  }

  @Get('me/stats')
  getUserStats(@Request() req) {
    return this.analyticsService.getUserStats(req.user.id);
  }

  @Get('me/insights')
  getPersonalizedInsights(@Request() req, @Query('language') language = 'en') {
    return this.analyticsService.getPersonalizedInsights(req.user.id, language);
  }

  @Get('menu/:menuId')
  getMenuStats(
    @Param('menuId', ParseIntPipe) menuId: number,
    @Query('language') language = 'en',
  ) {
    return this.analyticsService.getMenuStats(menuId, language);
  }
}
