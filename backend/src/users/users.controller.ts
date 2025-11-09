import {
  Controller,
  Post,
  Get,
  Param,
  Body,
  Logger,
  HttpStatus,
  HttpException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import type { CreateUserDto } from './users.service';

@Controller('users')
export class UsersController {
  private readonly logger = new Logger(UsersController.name);

  constructor(private readonly usersService: UsersService) {}

  @Post('sync')
  async syncUser(@Body() userData: CreateUserDto) {
    this.logger.log(`Syncing user: ${userData.email}`);

    try {
      // Validate required fields
      if (!userData.id || !userData.email) {
        throw new HttpException(
          'User ID and email are required',
          HttpStatus.BAD_REQUEST,
        );
      }

      const user = await this.usersService.createOrUpdateUser(userData);

      return {
        success: true,
        message: 'User synced successfully',
        data: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          created_at: user.created_at,
        },
      };
    } catch (error) {
      this.logger.error(`Failed to sync user ${userData.email}:`, error);

      throw new HttpException(
        {
          success: false,
          message: 'Failed to sync user',
          error: (error as Error).message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Get(':id')
  async getUserById(@Param('id') id: string) {
    this.logger.log(`Fetching user: ${id}`);

    try {
      const user = await this.usersService.getUserById(id);

      if (!user) {
        throw new HttpException('User not found', HttpStatus.NOT_FOUND);
      }

      return {
        id: user.id,
        email: user.email,
        name: user.name,
        phone_number: user.phone,
        email_verified: true,
        is_admin: user.role === 'ADMIN',
        created_at: user.created_at.toISOString(),
        updated_at: user.updated_at.toISOString(),
      };
    } catch (error) {
      this.logger.error(`Failed to fetch user ${id}:`, error);

      if (error instanceof HttpException) {
        throw error;
      }

      throw new HttpException(
        {
          success: false,
          message: 'Failed to fetch user',
          error: (error as Error).message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
