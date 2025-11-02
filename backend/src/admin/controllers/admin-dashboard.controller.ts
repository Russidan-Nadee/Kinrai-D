import { Controller, Get, UseGuards } from '@nestjs/common';
import { AdminDashboardService } from '../services/admin-dashboard.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';

@Controller('admin/dashboard')
@UseGuards(JwtAuthGuard, RolesGuard)
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
