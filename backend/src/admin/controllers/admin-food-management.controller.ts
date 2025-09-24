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
import { AdminFoodManagementService } from '../services/admin-food-management.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import {
  CreateFoodTypeDto,
  UpdateFoodTypeDto,
  CreateCategoryDto,
  UpdateCategoryDto,
  CreateSubcategoryDto,
  UpdateSubcategoryDto,
  CreateProteinTypeDto,
  UpdateProteinTypeDto,
} from '../dto/bulk-upload.dto';

@Controller('admin/food-management')
@AdminOnly()
export class AdminFoodManagementController {
  constructor(
    private readonly foodManagementService: AdminFoodManagementService,
  ) {}

  @Get('food-types')
  async getFoodTypes(@Query('page') page?: string) {
    return this.foodManagementService.getFoodTypes(page ? parseInt(page) : 1);
  }

  @Get('food-types/:id')
  async getFoodType(@Param('id') id: string) {
    return this.foodManagementService.getFoodTypeById(parseInt(id));
  }

  @Post('food-types')
  async createFoodType(@Body() createFoodTypeDto: CreateFoodTypeDto) {
    return this.foodManagementService.createFoodType(createFoodTypeDto);
  }

  @Put('food-types/:id')
  async updateFoodType(
    @Param('id') id: string,
    @Body() updateFoodTypeDto: UpdateFoodTypeDto,
  ) {
    return this.foodManagementService.updateFoodType(
      parseInt(id),
      updateFoodTypeDto,
    );
  }

  @Delete('food-types/:id')
  async deleteFoodType(@Param('id') id: string) {
    return this.foodManagementService.deleteFoodType(parseInt(id));
  }

  @Get('categories')
  async getCategories(@Query('page') page?: string) {
    return this.foodManagementService.getCategories(page ? parseInt(page) : 1);
  }

  @Get('categories/:id')
  async getCategory(@Param('id') id: string) {
    return this.foodManagementService.getCategoryById(parseInt(id));
  }

  @Post('categories')
  async createCategory(@Body() createCategoryDto: CreateCategoryDto) {
    return this.foodManagementService.createCategory(createCategoryDto);
  }

  @Put('categories/:id')
  async updateCategory(
    @Param('id') id: string,
    @Body() updateCategoryDto: UpdateCategoryDto,
  ) {
    return this.foodManagementService.updateCategory(
      parseInt(id),
      updateCategoryDto,
    );
  }

  @Delete('categories/:id')
  async deleteCategory(@Param('id') id: string) {
    return this.foodManagementService.deleteCategory(parseInt(id));
  }

  @Get('subcategories')
  async getSubcategories(@Query('page') page?: string) {
    return this.foodManagementService.getSubcategories(
      page ? parseInt(page) : 1,
    );
  }

  @Get('subcategories/:id')
  async getSubcategory(@Param('id') id: string) {
    return this.foodManagementService.getSubcategoryById(parseInt(id));
  }

  @Post('subcategories')
  async createSubcategory(@Body() createSubcategoryDto: CreateSubcategoryDto) {
    return this.foodManagementService.createSubcategory(createSubcategoryDto);
  }

  @Put('subcategories/:id')
  async updateSubcategory(
    @Param('id') id: string,
    @Body() updateSubcategoryDto: UpdateSubcategoryDto,
  ) {
    return this.foodManagementService.updateSubcategory(
      parseInt(id),
      updateSubcategoryDto,
    );
  }

  @Delete('subcategories/:id')
  async deleteSubcategory(@Param('id') id: string) {
    return this.foodManagementService.deleteSubcategory(parseInt(id));
  }

  @Get('protein-types')
  async getProteinTypes(@Query('page') page?: string) {
    return this.foodManagementService.getProteinTypes(
      page ? parseInt(page) : 1,
    );
  }

  @Get('protein-types/:id')
  async getProteinType(@Param('id') id: string) {
    return this.foodManagementService.getProteinTypeById(parseInt(id));
  }

  @Post('protein-types')
  async createProteinType(@Body() createProteinTypeDto: CreateProteinTypeDto) {
    return this.foodManagementService.createProteinType(createProteinTypeDto);
  }

  @Put('protein-types/:id')
  async updateProteinType(
    @Param('id') id: string,
    @Body() updateProteinTypeDto: UpdateProteinTypeDto,
  ) {
    return this.foodManagementService.updateProteinType(
      parseInt(id),
      updateProteinTypeDto,
    );
  }

  @Delete('protein-types/:id')
  async deleteProteinType(@Param('id') id: string) {
    return this.foodManagementService.deleteProteinType(parseInt(id));
  }
}
