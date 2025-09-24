import { Controller, Get } from '@nestjs/common';
import { AdminDashboardService } from '../services/admin-dashboard.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';

@Controller('admin/dashboard')
@AdminOnly()
export class AdminDashboardController {
  constructor(private readonly dashboardService: AdminDashboardService) {}

  @Get('stats')
  async getStats() {
    return this.dashboardService.getSystemStats();
  }

  @Get('recent-activity')
  async getRecentActivity() {
    return this.dashboardService.getRecentActivity();
  }
}
