import { PartialType } from '@nestjs/mapped-types';
import { CreateMenuDto, MealTime } from './create-menu.dto';
import {
  IsOptional,
  IsBoolean,
  IsInt,
  IsPositive,
  IsUrl,
  MaxLength,
  IsObject,
  IsEnum,
} from 'class-validator';

export class UpdateMenuDto extends PartialType(CreateMenuDto) {
  @IsOptional()
  @IsInt()
  @IsPositive()
  subcategory_id?: number;

  @IsOptional()
  @IsInt()
  @IsPositive()
  protein_type_id?: number;

  @IsOptional()
  @IsUrl()
  @MaxLength(500)
  image_url?: string;

  @IsOptional()
  @IsObject()
  contains?: any;

  @IsOptional()
  @IsEnum(MealTime)
  meal_time?: MealTime;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;
}
