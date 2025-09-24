import {
  IsString,
  IsOptional,
  IsNotEmpty,
  MaxLength,
  IsBoolean,
  IsArray,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class FoodTypeTranslationDto {
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

export class UpdateFoodTypeDto {
  @IsString()
  @IsOptional()
  @IsNotEmpty()
  @MaxLength(50)
  key?: string;

  @IsBoolean()
  @IsOptional()
  is_active?: boolean;

  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => FoodTypeTranslationDto)
  translations?: FoodTypeTranslationDto[];
}
