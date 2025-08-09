import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  Query,
  ParseIntPipe,
} from '@nestjs/common';
import { RatingsService } from './ratings.service';
import { CreateRatingDto } from './dto/create-rating.dto';
import { UpdateRatingDto } from './dto/update-rating.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';

@Controller('ratings')
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post()
  @UseGuards(SupabaseAuthGuard)
  create(@Body() createRatingDto: CreateRatingDto, @Request() req) {
    return this.ratingsService.create(req.user.id, createRatingDto);
  }

  @Get()
  findAll(
    @Query('menuId', ParseIntPipe) menuId?: number,
    @Query('userId') userId?: string,
    @Query('language') language = 'en',
  ) {
    return this.ratingsService.findAll(menuId, userId, language);
  }

  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  getUserRatings(@Request() req, @Query('language') language = 'en') {
    return this.ratingsService.getUserRatings(req.user.id, language);
  }

  @Get('top-rated')
  getTopRatedMenus(
    @Query('limit', ParseIntPipe) limit = 10,
    @Query('language') language = 'en',
  ) {
    return this.ratingsService.getTopRatedMenus(limit, language);
  }

  @Get('menu/:menuId/summary')
  getMenuRatingSummary(@Param('menuId', ParseIntPipe) menuId: number) {
    return this.ratingsService.getMenuRatingSummary(menuId);
  }

  @Get('me/menu/:menuId')
  @UseGuards(SupabaseAuthGuard)
  getUserRating(@Request() req, @Param('menuId', ParseIntPipe) menuId: number) {
    return this.ratingsService.findUserRating(req.user.id, menuId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.ratingsService.findOne(id);
  }

  @Patch('menu/:menuId')
  @UseGuards(SupabaseAuthGuard)
  update(
    @Param('menuId', ParseIntPipe) menuId: number,
    @Body() updateRatingDto: UpdateRatingDto,
    @Request() req,
  ) {
    return this.ratingsService.update(req.user.id, menuId, updateRatingDto);
  }

  @Delete('menu/:menuId')
  @UseGuards(SupabaseAuthGuard)
  remove(@Param('menuId', ParseIntPipe) menuId: number, @Request() req) {
    return this.ratingsService.remove(req.user.id, menuId);
  }
}