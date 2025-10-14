import {
  Controller,
  Get,
  Request,
  Query,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { AnalyticsService } from './analytics.service';

interface AuthRequest extends Request {
  user: {
    id: string;
  };
}

@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('me')
  getUserAnalytics(
    @Request() req: AuthRequest,
    @Query('language') language = 'en',
  ) {
    return this.analyticsService.getUserAnalytics(req.user.id, language);
  }

  @Get('me/stats')
  getUserStats(@Request() req: AuthRequest) {
    return this.analyticsService.getUserStats(req.user.id);
  }

  @Get('me/insights')
  getPersonalizedInsights(@Request() req: AuthRequest) {
    return this.analyticsService.getPersonalizedInsights(req.user.id);
  }

  @Get('menu/:menuId')
  getMenuStats(
    @Param('menuId', ParseIntPipe) menuId: number,
    @Query('language') language = 'en',
  ) {
    return this.analyticsService.getMenuStats(menuId, language);
  }
}
