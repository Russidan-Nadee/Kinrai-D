import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { AdminMenusService } from '../services/admin-menus.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import {
  CreateMenuDto,
  UpdateMenuDto,
  MenuQueryDto,
  BulkMenuDto,
} from '../dto/menu-batch.dto';

@Controller('admin/menus')
// @AdminOnly() // Temporarily disabled for development
export class AdminMenusController {
  constructor(private readonly menusService: AdminMenusService) {}

  @Get()
  async getMenus(@Query() query: MenuQueryDto) {
    return this.menusService.getMenus(query);
  }

  @Get(':id')
  async getMenu(@Param('id') id: string) {
    return this.menusService.getMenuById(parseInt(id));
  }

  @Post()
  async createMenu(@Body() createMenuDto: CreateMenuDto) {
    return this.menusService.createMenu(createMenuDto);
  }

  @Put(':id')
  async updateMenu(
    @Param('id') id: string,
    @Body() updateMenuDto: UpdateMenuDto,
  ) {
    return this.menusService.updateMenu(parseInt(id), updateMenuDto);
  }

  @Delete(':id')
  async deleteMenu(@Param('id') id: string) {
    return this.menusService.deleteMenu(parseInt(id));
  }

  @Post('bulk')
  async bulkCreateMenus(@Body() bulkMenuDto: BulkMenuDto) {
    return this.menusService.bulkCreateMenus(bulkMenuDto);
  }

  @Put(':id/activate')
  async activateMenu(@Param('id') id: string) {
    return this.menusService.activateMenu(parseInt(id));
  }

  @Put(':id/deactivate')
  async deactivateMenu(@Param('id') id: string) {
    return this.menusService.deactivateMenu(parseInt(id));
  }
}