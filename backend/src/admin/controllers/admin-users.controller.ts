import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { AdminUsersService } from '../services/admin-users.service';
import { AdminOnly } from '../../auth/decorators/auth.decorators';
import {
  CreateUserDto,
  UpdateUserDto,
  UserQueryDto,
} from '../dto/user-management.dto';

@Controller('admin/users')
@AdminOnly()
export class AdminUsersController {
  constructor(private readonly usersService: AdminUsersService) {}

  @Get()
  async getUsers(@Query() query: UserQueryDto) {
    return this.usersService.getUsers(query);
  }

  @Get(':id')
  async getUser(@Param('id') id: string) {
    return this.usersService.getUserById(id);
  }

  @Post()
  async createUser(@Body() createUserDto: CreateUserDto) {
    return this.usersService.createUser(createUserDto);
  }

  @Put(':id')
  async updateUser(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    return this.usersService.updateUser(id, updateUserDto);
  }

  @Delete(':id')
  async deleteUser(@Param('id') id: string) {
    return this.usersService.deleteUser(id);
  }

  @Put(':id/activate')
  async activateUser(@Param('id') id: string) {
    return this.usersService.activateUser(id);
  }

  @Put(':id/deactivate')
  async deactivateUser(@Param('id') id: string) {
    return this.usersService.deactivateUser(id);
  }
}