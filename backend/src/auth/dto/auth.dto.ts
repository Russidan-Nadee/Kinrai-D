import {
  IsEmail,
  IsString,
  MinLength,
  IsOptional,
  MaxLength,
  IsPhoneNumber,
  IsEnum,
  IsDateString,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SignUpDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'securepassword123', minLength: 8 })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password: string;

  @ApiPropertyOptional({ example: 'John Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ example: '+66812345678' })
  @IsOptional()
  @IsPhoneNumber('TH')
  phone?: string;

  @ApiPropertyOptional({ example: 'en' })
  @IsOptional()
  @IsString()
  @MaxLength(5)
  preferred_language?: string;
}

export class SignInDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'securepassword123' })
  @IsString()
  password: string;
}

export class ResetPasswordDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;
}

export class UpdatePasswordDto {
  @ApiProperty({ example: 'newsecurepassword123', minLength: 8 })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  newPassword: string;
}

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 'John Doe' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ example: '+66812345678' })
  @IsOptional()
  @IsPhoneNumber('TH')
  phone?: string;

  @ApiPropertyOptional({ example: 'https://example.com/avatar.jpg' })
  @IsOptional()
  @IsString()
  avatar_url?: string;

  @ApiPropertyOptional({ example: 'en' })
  @IsOptional()
  @IsString()
  @MaxLength(5)
  preferred_language?: string;

  @ApiPropertyOptional({ example: 'Bangkok, Thailand' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  location?: string;

  @ApiPropertyOptional({ example: '1990-01-01' })
  @IsOptional()
  @IsDateString()
  date_of_birth?: string;

  @ApiPropertyOptional({
    example: {
      notifications: true,
      marketing_emails: false,
      theme: 'light',
    },
  })
  @IsOptional()
  preferences?: Record<string, any>;
}

export class SocialSignInDto {
  @ApiProperty({
    example: 'google',
    enum: ['google', 'facebook', 'github', 'apple'],
  })
  @IsEnum(['google', 'facebook', 'github', 'apple'])
  provider: 'google' | 'facebook' | 'github' | 'apple';

  @ApiPropertyOptional({ example: 'http://localhost:3000/dashboard' })
  @IsOptional()
  @IsString()
  redirectTo?: string;
}

export class RefreshTokenDto {
  @ApiProperty({ example: 'refresh_token_here' })
  @IsString()
  refresh_token: string;
}

export class VerifyEmailDto {
  @ApiProperty({ example: 'verification_token_here' })
  @IsString()
  token: string;

  @ApiProperty({ example: 'confirmation' })
  @IsString()
  type: string;
}
