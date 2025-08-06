import { 
   IsString, 
   IsNotEmpty, 
   MaxLength, 
   IsArray, 
   ValidateNested, 
   IsInt, 
   IsPositive, 
   IsOptional,
   IsUrl,
   IsObject,
   IsEnum
} from 'class-validator';
import { Type } from 'class-transformer';

export enum MealTime {
   BREAKFAST = 'BREAKFAST',
   LUNCH = 'LUNCH', 
   DINNER = 'DINNER',
   SNACK = 'SNACK'
}

export class MenuTranslationDto {
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
   @MaxLength(1000)
   description?: string;
}

export class CreateMenuDto {
   @IsString()
   @IsNotEmpty()
   @MaxLength(100)
   key: string; // "som_tam", "pad_thai", "green_curry_chicken"

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

   @IsObject()
   contains: any; // JSON object สำหรับส่วนผสม เช่น {"vegetables": ["lettuce", "tomato"], "meat": ["chicken"]}

   @IsEnum(MealTime)
   meal_time: MealTime;

   @IsArray()
   @ValidateNested({ each: true })
   @Type(() => MenuTranslationDto)
   translations: MenuTranslationDto[];
}