import {
  IsString,
  IsOptional,
  IsInt,
  IsEnum,
  IsBoolean,
  IsArray,
  ValidateNested,
  IsObject,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { MealTime } from '@prisma/client';

export class MenuTranslationDto {
  @IsString()
  language: string;

  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;
}

export class CreateMenuDto {
  @IsInt()
  subcategory_id: number;

  @IsOptional()
  @IsInt()
  protein_type_id?: number;

  @IsString()
  key: string;

  @IsOptional()
  @IsString()
  image_url?: string;

  @IsObject()
  contains: any;

  @IsEnum(MealTime)
  meal_time: MealTime;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => MenuTranslationDto)
  translations: MenuTranslationDto[];
}

export class UpdateMenuDto {
  @IsOptional()
  @IsInt()
  subcategory_id?: number;

  @IsOptional()
  @IsInt()
  protein_type_id?: number;

  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsString()
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

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => MenuTranslationDto)
  translations?: MenuTranslationDto[];
}

export class MenuQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  subcategory_id?: number;

  @IsOptional()
  @IsEnum(MealTime)
  meal_time?: MealTime;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;
}

export class BulkMenuDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateMenuDto)
  menus: CreateMenuDto[];
}
