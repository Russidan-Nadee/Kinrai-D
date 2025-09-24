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
import { FoodTypesService } from '../services/food-types.service';
import { CreateFoodTypeDto } from '../dto/create-food-type.dto';
import { UpdateFoodTypeDto } from '../dto/update-food-type.dto';

@Controller('food-types')
export class FoodTypesController {
  constructor(private readonly foodTypesService: FoodTypesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createFoodTypeDto: CreateFoodTypeDto) {
    return {
      statusCode: HttpStatus.CREATED,
      message: 'Food type created successfully',
      data: await this.foodTypesService.create(createFoodTypeDto),
    };
  }

  @Get()
  async findAll(
    @Query('lang') language: string = 'en',
    @Query('include_categories') includeCategories?: string,
  ) {
    let data;

    if (includeCategories === 'true') {
      data = await this.foodTypesService.findAllWithCategories(language);
    } else {
      data = await this.foodTypesService.findAll(language);
    }

    return {
      statusCode: HttpStatus.OK,
      message: 'Food types retrieved successfully',
      data,
      meta: {
        language: language,
        include_categories: includeCategories === 'true',
      },
    };
  }

  @Get('languages')
  async getAvailableLanguages() {
    return {
      statusCode: HttpStatus.OK,
      message: 'Available languages retrieved successfully',
      data: await this.foodTypesService.findAllLanguages(),
    };
  }

  @Get('key/:key')
  async findByKey(
    @Param('key') key: string,
    @Query('lang') language: string = 'en',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Food type retrieved successfully',
      data: await this.foodTypesService.findByKey(key, language),
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
      message: 'Food type retrieved successfully',
      data: await this.foodTypesService.findOne(id, language),
      meta: {
        language: language,
      },
    };
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateFoodTypeDto: UpdateFoodTypeDto,
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Food type updated successfully',
      data: await this.foodTypesService.update(id, updateFoodTypeDto),
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id', ParseIntPipe) id: number) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Food type deleted successfully',
      data: await this.foodTypesService.remove(id),
    };
  }
}
