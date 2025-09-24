import { IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreateDietaryRestrictionDto {
  @IsString()
  key: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean = true;
}
