import { IsString, IsNotEmpty, MaxLength, IsArray, ValidateNested, IsOptional } from 'class-validator';
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

export class CreateFoodTypeDto {
   @IsString()
   @IsNotEmpty()
   @MaxLength(50)
   key: string; // "savory_food", "sweet_food", "beverage"

   @IsArray()
   @ValidateNested({ each: true })
   @Type(() => FoodTypeTranslationDto)
   translations: FoodTypeTranslationDto[];
}