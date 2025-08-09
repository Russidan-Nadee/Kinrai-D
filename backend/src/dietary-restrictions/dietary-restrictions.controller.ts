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
import { DietaryRestrictionsService } from './dietary-restrictions.service';
import { CreateDietaryRestrictionDto } from './dto/create-dietary-restriction.dto';
import { UpdateDietaryRestrictionDto } from './dto/update-dietary-restriction.dto';
import { AssignRestrictionDto } from './dto/assign-restriction.dto';
import { RemoveRestrictionDto } from './dto/remove-restriction.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { Roles } from '../auth/decorators/auth.decorators';
import { RolesGuard } from '../auth/guards/roles.guard';

@Controller('dietary-restrictions')
export class DietaryRestrictionsController {
  constructor(private readonly dietaryRestrictionsService: DietaryRestrictionsService) {}

  @Post()
  @UseGuards(SupabaseAuthGuard, RolesGuard)
  @Roles('admin')
  create(@Body() createDietaryRestrictionDto: CreateDietaryRestrictionDto) {
    return this.dietaryRestrictionsService.create(createDietaryRestrictionDto);
  }

  @Get()
  findAll(@Query('language') language = 'en') {
    return this.dietaryRestrictionsService.findAll(language);
  }

  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  getUserRestrictions(@Request() req, @Query('language') language = 'en') {
    return this.dietaryRestrictionsService.getUserRestrictions(req.user.id, language);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @Query('language') language = 'en') {
    return this.dietaryRestrictionsService.findOne(id, language);
  }

  @Patch(':id')
  @UseGuards(SupabaseAuthGuard, RolesGuard)
  @Roles('admin')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateDietaryRestrictionDto: UpdateDietaryRestrictionDto,
  ) {
    return this.dietaryRestrictionsService.update(id, updateDietaryRestrictionDto);
  }

  @Delete(':id')
  @UseGuards(SupabaseAuthGuard, RolesGuard)
  @Roles('admin')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.dietaryRestrictionsService.remove(id);
  }

  @Post('me/assign')
  @UseGuards(SupabaseAuthGuard)
  assignToMe(@Body() assignRestrictionDto: AssignRestrictionDto, @Request() req) {
    return this.dietaryRestrictionsService.assignToUser(req.user.id, assignRestrictionDto);
  }

  @Delete('me/remove')
  @UseGuards(SupabaseAuthGuard)
  removeFromMe(@Body() removeRestrictionDto: RemoveRestrictionDto, @Request() req) {
    return this.dietaryRestrictionsService.removeFromUser(req.user.id, removeRestrictionDto);
  }
}