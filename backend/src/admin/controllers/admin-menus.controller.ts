import { Controller, Get, Delete, Param, Put } from '@nestjs/common';
import { AdminMenusService } from '../services/admin-menus.service';

@Controller('admin/menus')
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
