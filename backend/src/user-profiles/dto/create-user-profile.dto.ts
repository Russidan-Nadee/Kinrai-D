import { IsString, IsOptional, IsPhoneNumber, IsUUID, IsEmail } from 'class-validator';

export class CreateUserProfileDto {
  @IsUUID()
  id: string;

  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}