import { IsInt, IsOptional, IsString } from 'class-validator';

export class CreateDislikeDto {
  @IsInt()
  menu_id: number;

  @IsOptional()
  @IsString()
  reason?: string;
}