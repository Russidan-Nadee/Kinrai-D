import { IsOptional, IsString, IsEnum, IsArray, IsInt, Min, Max } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { MealTime } from './create-menu.dto';

export class SearchMenuDto {
  @IsOptional()
  @IsString()
  search?: string; // Search term for menu name or description

  @IsOptional()
  @IsString()
  language?: string = 'th'; // Language for search and results

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => Array.isArray(value) ? value : value.split(','))
  tags?: string[]; // Search by tags/keywords

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => Array.isArray(value) ? value : value.split(','))
  ingredients?: string[]; // Search by specific ingredients

  @IsOptional()
  @IsEnum(MealTime)
  meal_time?: MealTime;

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
  limit?: number = 20;

  @IsOptional()
  @IsString()
  sort_by?: 'relevance' | 'name' | 'rating' | 'popularity' | 'created_at' = 'relevance';

  @IsOptional()
  @IsString()
  sort_order?: 'asc' | 'desc' = 'desc';

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  @Type(() => Number)
  min_rating?: number; // Minimum average rating

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  food_type_ids?: number[]; // Filter by food type IDs

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  category_ids?: number[]; // Filter by category IDs

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  subcategory_ids?: number[]; // Filter by subcategory IDs

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  protein_type_ids?: number[]; // Filter by protein type IDs
}

export class SearchMenuResultDto {
  @IsArray()
  menus: any[]; // Menu results with translations and related data

  @IsInt()
  total: number;

  @IsInt()
  page: number;

  @IsInt()
  limit: number;

  @IsInt()
  total_pages: number;

  @IsOptional()
  search_metadata?: {
    search_term?: string;
    search_language: string;
    filters_applied: string[];
    sort_criteria: string;
    search_time_ms: number;
    suggestions?: string[]; // Suggested search terms if no results
  };
}