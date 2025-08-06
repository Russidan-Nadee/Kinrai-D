import { IsString, IsNotEmpty, MaxLength, IsArray, ValidateNested, IsInt, IsPositive } from 'class-validator';
import { Type } from 'class-transformer';

export class SubcategoryTranslationDto {
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

export class CreateSubcategoryDto {
   @IsString()
   @IsNotEmpty()
   @MaxLength(50)
   key: string; // "kuay_teow", "bamee", "thai_curry", "khao_na_neua"

   @IsInt()
   @IsPositive()
   category_id: number;

   @IsArray()
   @ValidateNested({ each: true })
   @Type(() => SubcategoryTranslationDto)
   translations: SubcategoryTranslationDto[];
}