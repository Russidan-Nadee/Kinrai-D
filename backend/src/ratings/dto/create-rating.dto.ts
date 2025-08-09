import { IsInt, IsOptional, IsString, Min, Max } from 'class-validator';

export class CreateRatingDto {
  @IsInt()
  menu_id: number;

  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @IsOptional()
  @IsString()
  review?: string;
}