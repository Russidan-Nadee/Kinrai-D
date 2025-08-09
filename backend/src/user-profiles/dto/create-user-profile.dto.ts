import { IsString, IsOptional, IsPhoneNumber, IsUUID } from 'class-validator';

export class CreateUserProfileDto {
  @IsUUID()
  id: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}