import { PartialType } from '@nestjs/mapped-types';
import { CreateSubcategoryDto, SubcategoryTranslationDto } from './create-subcategory.dto';
import { IsOptional, IsBoolean, IsArray, ValidateNested, IsInt, IsPositive } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateSubcategoryDto extends PartialType(CreateSubcategoryDto) {
   @IsOptional()
   @IsInt()
   @IsPositive()
   category_id?: number;

   @IsOptional()
   @IsBoolean()
   is_active?: boolean;

   @IsOptional()
   @IsArray()
   @ValidateNested({ each: true })
   @Type(() => SubcategoryTranslationDto)
   translations?: SubcategoryTranslationDto[];
}