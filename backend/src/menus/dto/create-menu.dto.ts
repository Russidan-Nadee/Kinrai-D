import {
  MaxLength,
  IsInt,
  IsPositive,
  IsOptional,
  IsUrl,
  IsObject,
  IsEnum,
} from 'class-validator';

export enum MealTime {
  BREAKFAST = 'BREAKFAST',
  LUNCH = 'LUNCH',
  DINNER = 'DINNER',
  SNACK = 'SNACK',
}

export class CreateMenuDto {
  @IsInt()
  @IsPositive()
  subcategory_id: number;

  @IsOptional()
  @IsInt()
  @IsPositive()
  protein_type_id?: number;

  @IsOptional()
  @IsUrl()
  @MaxLength(500)
  image_url?: string;

  @IsOptional()
  @IsObject()
  contains?: any; // JSON object สำหรับส่วนผสม เช่น {"vegetables": ["lettuce", "tomato"], "meat": ["chicken"]}

  @IsEnum(MealTime)
  meal_time: MealTime;
}
