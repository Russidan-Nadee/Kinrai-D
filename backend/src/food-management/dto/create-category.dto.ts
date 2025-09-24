import {
  IsString,
  IsNotEmpty,
  MaxLength,
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
  @IsNotEmpty()
  @MaxLength(500)
  description?: string;
}

export class CreateCategoryDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  key: string; // "curry", "noodle", "rice"

  @IsInt()
  @IsPositive()
  food_type_id: number;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CategoryTranslationDto)
  translations: CategoryTranslationDto[];
}
