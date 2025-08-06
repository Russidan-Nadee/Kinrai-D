import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { MenusService } from './menus.service';
import { CreateMenuDto } from './dto/create-menu.dto';
import { UpdateMenuDto } from './dto/update-menu.dto';
import { FilterMenuDto } from './dto/filter-menu.dto';
import { SearchMenuDto } from './dto/search-menu.dto';
import { MenuRecommendationQueryDto } from './dto/menu-recommendation.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';

@ApiTags('menus')
@Controller('menus')
export class MenusController {
  constructor(private readonly menusService: MenusService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new menu item' })
  @ApiResponse({ status: 201, description: 'Menu item created successfully.' })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  @ApiResponse({ status: 409, description: 'Conflict - Menu key already exists.' })
  create(@Body() createMenuDto: CreateMenuDto) {
    return this.menusService.create(createMenuDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all menu items with filtering and pagination' })
  @ApiResponse({ status: 200, description: 'Menu items retrieved successfully.' })
  @ApiQuery({ name: 'subcategory_id', required: false, type: Number })
  @ApiQuery({ name: 'category_id', required: false, type: Number })
  @ApiQuery({ name: 'food_type_id', required: false, type: Number })
  @ApiQuery({ name: 'protein_type_id', required: false, type: Number })
  @ApiQuery({ name: 'meal_time', required: false, enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'] })
  @ApiQuery({ name: 'language', required: false, type: String, description: 'Language code (th, en, jp, zh)' })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'sort_by', required: false, type: String })
  @ApiQuery({ name: 'sort_order', required: false, enum: ['asc', 'desc'] })
  findAll(@Query() filterDto: FilterMenuDto) {
    return this.menusService.findAll(filterDto);
  }

  @Get('popular')
  @ApiOperation({ summary: 'Get popular menu items' })
  @ApiResponse({ status: 200, description: 'Popular menu items retrieved successfully.' })
  @ApiQuery({ name: 'language', required: false, type: String, description: 'Language code (th, en, jp, zh)' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Number of items to return' })
  getPopular(
    @Query('language') language?: string,
    @Query('limit', new ParseIntPipe({ optional: true })) limit?: number,
  ) {
    return this.menusService.getPopularMenus(language, limit);
  }

  @Get('key/:key')
  @ApiOperation({ summary: 'Get menu item by key' })
  @ApiResponse({ status: 200, description: 'Menu item retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Menu item not found.' })
  @ApiQuery({ name: 'language', required: false, type: String, description: 'Language code (th, en, jp, zh)' })
  findByKey(
    @Param('key') key: string,
    @Query('language') language?: string,
  ) {
    return this.menusService.findByKey(key, language);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get menu item by ID' })
  @ApiResponse({ status: 200, description: 'Menu item retrieved successfully.' })
  @ApiResponse({ status: 404, description: 'Menu item not found.' })
  @ApiQuery({ name: 'language', required: false, type: String, description: 'Language code (th, en, jp, zh)' })
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Query('language') language?: string,
  ) {
    return this.menusService.findOne(id, language);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update menu item' })
  @ApiResponse({ status: 200, description: 'Menu item updated successfully.' })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  @ApiResponse({ status: 404, description: 'Menu item not found.' })
  @ApiResponse({ status: 409, description: 'Conflict - Menu key already exists.' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateMenuDto: UpdateMenuDto,
  ) {
    return this.menusService.update(id, updateMenuDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Soft delete menu item (deactivate)' })
  @ApiResponse({ status: 204, description: 'Menu item deactivated successfully.' })
  @ApiResponse({ status: 404, description: 'Menu item not found.' })
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.menusService.remove(id);
  }

  @Post('recommendations')
  @ApiOperation({ summary: 'Get menu recommendations based on user preferences' })
  @ApiResponse({ status: 200, description: 'Menu recommendations retrieved successfully.' })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  getRecommendations(@Body() queryDto: MenuRecommendationQueryDto) {
    return this.menusService.getRecommendations(queryDto);
  }

  @Get('search')
  @ApiOperation({ summary: 'Advanced search for menu items' })
  @ApiResponse({ status: 200, description: 'Menu search results retrieved successfully.' })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Search term' })
  @ApiQuery({ name: 'language', required: false, type: String, description: 'Language code (th, en, jp, zh)' })
  @ApiQuery({ name: 'meal_time', required: false, enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'] })
  @ApiQuery({ name: 'min_rating', required: false, type: Number, description: 'Minimum rating (1-5)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'sort_by', required: false, enum: ['relevance', 'name', 'rating', 'popularity', 'created_at'] })
  @ApiQuery({ name: 'sort_order', required: false, enum: ['asc', 'desc'] })
  searchMenus(@Query() searchDto: SearchMenuDto) {
    return this.menusService.searchMenus(searchDto);
  }
}