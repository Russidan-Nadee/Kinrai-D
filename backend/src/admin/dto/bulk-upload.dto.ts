import {
  IsString,
  IsOptional,
  IsBoolean,
  IsArray,
  ValidateNested,
  IsInt,
} from 'class-validator';
import { Type } from 'class-transformer';

export class TranslationDto {
  @IsString()
  language: string;

  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string;
}

export class CreateFoodTypeDto {
  @IsString()
  key: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations: TranslationDto[];
}

export class UpdateFoodTypeDto {
  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations?: TranslationDto[];
}

export class CreateCategoryDto {
  @IsInt()
  food_type_id: number;

  @IsString()
  key: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations: TranslationDto[];
}

export class UpdateCategoryDto {
  @IsOptional()
  @IsInt()
  food_type_id?: number;

  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations?: TranslationDto[];
}

export class CreateSubcategoryDto {
  @IsInt()
  category_id: number;

  @IsString()
  key: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations: TranslationDto[];
}

export class UpdateSubcategoryDto {
  @IsOptional()
  @IsInt()
  category_id?: number;

  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations?: TranslationDto[];
}

export class CreateProteinTypeDto {
  @IsString()
  key: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations: TranslationDto[];
}

export class UpdateProteinTypeDto {
  @IsOptional()
  @IsString()
  key?: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TranslationDto)
  translations?: TranslationDto[];
}
