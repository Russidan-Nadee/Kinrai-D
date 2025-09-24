import {
  IsString,
  IsOptional,
  IsNotEmpty,
  MaxLength,
  IsBoolean,
  IsArray,
  ValidateNested,
  IsInt,
  IsPositive,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CategoryTranslationDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2)
  language: string; // "th", "en", "jp", "zh"

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @IsString()
  @IsOptional()
  @MaxLength(500)
  description?: string;
}

export class UpdateCategoryDto {
  @IsString()
  @IsOptional()
  @IsNotEmpty()
  @MaxLength(50)
  key?: string;

  @IsInt()
  @IsPositive()
  @IsOptional()
  food_type_id?: number;

  @IsBoolean()
  @IsOptional()
  is_active?: boolean;

  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => CategoryTranslationDto)
  translations?: CategoryTranslationDto[];
}
