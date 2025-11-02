import { Controller, Get, Delete, Param, Put, UseGuards } from '@nestjs/common';
import { AdminMenusService } from '../services/admin-menus.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';

@Controller('admin/menus')
@UseGuards(JwtAuthGuard, RolesGuard)
@AdminOnly()
export class AdminMenusController {
  constructor(private readonly menusService: AdminMenusService) {}

  @Get()
  async getMenuCards() {
    return this.menusService.getMenuCards();
  }

  @Get(':id')
  async getMenuCard(@Param('id') id: string) {
    return this.menusService.getMenuCard(parseInt(id));
  }

  @Put(':id/toggle')
  async toggleMenuStatus(@Param('id') id: string) {
    return this.menusService.toggleMenuStatus(parseInt(id));
  }

  @Delete(':id')
  async deleteMenu(@Param('id') id: string) {
    return this.menusService.deleteMenu(parseInt(id));
  }
}
