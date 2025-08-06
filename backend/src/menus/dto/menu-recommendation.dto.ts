import { 
  IsOptional, 
  IsArray, 
  IsInt, 
  IsPositive, 
  IsString, 
  IsEnum, 
  IsNumber,
  Min,
  Max,
  IsObject
} from 'class-validator';
import { Type } from 'class-transformer';
import { MealTime } from './create-menu.dto';

export class MenuRecommendationQueryDto {
  @IsOptional()
  @IsInt()
  @IsPositive()
  @Type(() => Number)
  user_id?: number;

  @IsOptional()
  @IsEnum(MealTime)
  meal_time?: MealTime;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  preferred_food_types?: number[];

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  preferred_protein_types?: number[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  dietary_restrictions?: string[];

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  @Type(() => Number)
  excluded_menu_ids?: number[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  disliked_ingredients?: string[];

  @IsOptional()
  @IsString()
  language?: string = 'th';

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(50)
  @Type(() => Number)
  limit?: number = 10;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(5)
  @Type(() => Number)
  min_rating?: number;

  @IsOptional()
  @IsString()
  recommendation_type?: 'popular' | 'personalized' | 'similar' | 'random' = 'personalized';
}

export class MenuRecommendationDto {
  @IsNumber()
  id: number;

  @IsString()
  key: string;

  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  description?: string | null;

  @IsOptional()
  @IsString()
  image_url?: string | null;

  @IsObject()
  subcategory: {
    id: number;
    name: string;
    category: {
      id: number;
      name: string;
      food_type: {
        id: number;
        name: string;
      };
    };
  };

  @IsOptional()
  @IsObject()
  protein_type?: {
    id: number;
    name: string;
  };

  @IsNumber()
  average_rating: number;

  @IsNumber()
  total_ratings: number;

  @IsNumber()
  recommendation_score: number;

  @IsArray()
  recommendation_reasons: string[];

  @IsString()
  meal_time: string;

  @IsObject()
  contains: any;

  @IsOptional()
  @IsNumber()
  similarity_score?: number;
}

export class MenuRecommendationResultDto {
  @IsArray()
  recommendations: MenuRecommendationDto[];

  @IsObject()
  metadata: {
    total_found: number;
    recommendation_type: string;
    user_preferences_used: boolean;
    generated_at: Date;
    language: string;
  };

  @IsOptional()
  @IsObject()
  user_context?: {
    user_id?: number;
    dietary_restrictions?: string[];
    food_preferences?: any;
    recent_orders?: number[];
  };
}