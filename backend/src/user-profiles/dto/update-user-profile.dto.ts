import { PartialType } from '@nestjs/mapped-types';
import { IsString, IsOptional, IsPhoneNumber } from 'class-validator';

export class UpdateUserProfileDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}