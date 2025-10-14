import {
  Controller,
  Get,
  Post,
  Body,
  Delete,
  Request,
  Query,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { AddFavoriteDto } from './dto/add-favorite.dto';
import { RemoveFavoriteDto } from './dto/remove-favorite.dto';

@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Post()
  addFavorite(@Body() addFavoriteDto: AddFavoriteDto, @Request() req) {
    return this.favoritesService.addFavorite(req.user.id, addFavoriteDto);
  }

  @Delete()
  removeFavorite(@Body() removeFavoriteDto: RemoveFavoriteDto, @Request() req) {
    return this.favoritesService.removeFavorite(req.user.id, removeFavoriteDto);
  }

  @Get()
  getUserFavorites(@Request() req, @Query('language') language = 'en') {
    return this.favoritesService.getUserFavorites(req.user.id, language);
  }

  @Get('check/:menuId')
  checkIsFavorite(
    @Request() req,
    @Param('menuId', ParseIntPipe) menuId: number,
  ) {
    return this.favoritesService.checkIsFavorite(req.user.id, menuId);
  }

  @Get('meal-time/:mealTime')
  getFavoritesByMealTime(
    @Request() req,
    @Param('mealTime') mealTime: string,
    @Query('language') language = 'en',
  ) {
    return this.favoritesService.getFavoritesByMealTime(
      req.user.id,
      mealTime,
      language,
    );
  }
}
