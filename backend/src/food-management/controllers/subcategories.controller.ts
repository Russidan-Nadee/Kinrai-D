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
import { SubcategoriesService } from '../services/subcategories.service';
import { CreateSubcategoryDto } from '../dto/create-subcategory.dto';
import { UpdateSubcategoryDto } from '../dto/update-subcategory.dto';

@Controller('subcategories')
export class SubcategoriesController {
  constructor(private readonly subcategoriesService: SubcategoriesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createSubcategoryDto: CreateSubcategoryDto) {
    return {
      statusCode: HttpStatus.CREATED,
      message: 'Subcategory created successfully',
      data: await this.subcategoriesService.create(createSubcategoryDto),
    };
  }

  @Get()
  async findAll(
    @Query('lang') language: string = 'th',
    @Query('include_menus') includeMenus?: string,
  ) {
    let data;

    if (includeMenus === 'true') {
      data = await this.subcategoriesService.findAllWithMenus(language);
    } else {
      data = await this.subcategoriesService.findAll(language);
    }

    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategories retrieved successfully',
      data,
      meta: {
        language: language,
        include_menus: includeMenus === 'true',
      },
    };
  }

  @Get('category/:categoryId')
  async findByCategory(
    @Param('categoryId', ParseIntPipe) categoryId: number,
    @Query('lang') language: string = 'th',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategories retrieved successfully',
      data: await this.subcategoriesService.findByCategory(
        categoryId,
        language,
      ),
      meta: {
        language: language,
        category_id: categoryId,
      },
    };
  }

  @Get('key/:key')
  async findByKey(
    @Param('key') key: string,
    @Query('lang') language: string = 'th',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategory retrieved successfully',
      data: await this.subcategoriesService.findByKey(key, language),
      meta: {
        language: language,
      },
    };
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @Query('lang') language: string = 'th',
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategory retrieved successfully',
      data: await this.subcategoriesService.findOne(id, language),
      meta: {
        language: language,
      },
    };
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateSubcategoryDto: UpdateSubcategoryDto,
  ) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategory updated successfully',
      data: await this.subcategoriesService.update(id, updateSubcategoryDto),
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async remove(@Param('id', ParseIntPipe) id: number) {
    return {
      statusCode: HttpStatus.OK,
      message: 'Subcategory deleted successfully',
      data: await this.subcategoriesService.remove(id),
    };
  }
}
