import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  ParseIntPipe,
  HttpStatus,
  HttpCode,
  Query,
} from '@nestjs/common';
import { CategoriesService } from '../services/categories.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createCategoryDto: CreateCategoryDto) {
    return {
      statusCode: HttpStatus.CREATED,
      message: 'Category created successfully',
      data: await this.categoriesService.create(createCategoryDto),
    };
  }

  @Get()
  async findAll(
    @Query('lang') language: string = 'en',
    @Query('include_subcategories') includeSubcategories?: string,
  ) {
    let data;

    if (includeSubcategories === 'true') {
      data = await this.categoriesService.findAllWithSubcategories(language);
    } else {
      data = await this.categoriesService.findAll(language);
    }

    return {
      statusCode: HttpStatus.OK,
      message: 'Categories retrieved successfully',
      data,
      meta: {
        language: language,
        include_subcategories: includeSubcategories === 'true',
      },
    };
  }

  @Get('food-type/:foodTypeId')
  async findByFoodType(
    @Param('foodTypeId', ParseIntPipe) foodTypeId: number,
    @Query('lang') language: string = 'en',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Categories retrieved successfully',
      data: await this.categoriesService.findByFoodType(foodTypeId, language),
      meta: {
        language: language,
        food_type_id: foodTypeId,
      },
    };
  }

  @Get('key/:key')
  async findByKey(
    @Param('key') key: string,
    @Query('lang') language: string = 'en',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Category retrieved successfully',
      data: await this.categoriesService.findByKey(key, language),
      meta: {
        language: language,
      },
    };
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @Query('lang') language: string = 'en',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Category retrieved successfully',
      data: await this.categoriesService.findOne(id, language),
      meta: {
        language: language,
      },
    };
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateCategoryDto: UpdateCategoryDto,
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Category updated successfully',
      data: await this.categoriesService.update(id, updateCategoryDto),
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id', ParseIntPipe) id: number) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Category deleted successfully',
      data: await this.categoriesService.remove(id),
    };
  }
}
