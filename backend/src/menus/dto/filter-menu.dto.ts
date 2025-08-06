import { IsOptional, IsInt, IsPositive, IsEnum, IsString, IsArray, Min, Max } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { MealTime } from './create-menu.dto';

export class FilterMenuDto {
   @IsOptional()
   @IsInt()
   @IsPositive()
   @Type(() => Number)
   subcategory_id?: number;

   @IsOptional()
   @IsInt()
   @IsPositive()
   @Type(() => Number)
   category_id?: number;

   @IsOptional()
   @IsInt()
   @IsPositive()
   @Type(() => Number)
   food_type_id?: number;

   @IsOptional()
   @IsInt()
   @IsPositive()
   @Type(() => Number)
   protein_type_id?: number;

   @IsOptional()
   @IsEnum(MealTime)
   meal_time?: MealTime;

   @IsOptional()
   @IsString()
   language?: string = 'th';

   @IsOptional()
   @IsString()
   search?: string; // ค้นหาชื่อเมนู

   @IsOptional()
   @IsArray()
   @Transform(({ value }) => Array.isArray(value) ? value : [value])
   dietary_restrictions?: string[]; // สำหรับกรองตามข้อจำกัดอาหาร

   @IsOptional()
   @IsInt()
   @Min(1)
   @Type(() => Number)
   page?: number = 1;

   @IsOptional()
   @IsInt()
   @Min(1)
   @Max(100)
   @Type(() => Number)
   limit?: number = 10;

   @IsOptional()
   @IsString()
   sort_by?: string = 'created_at'; // 'name', 'created_at', 'rating'

   @IsOptional()
   @IsString()
   sort_order?: 'asc' | 'desc' = 'desc';
}