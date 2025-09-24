import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { UserProfilesService } from './user-profiles.service';
import { CreateUserProfileDto } from './dto/create-user-profile.dto';
import { UpdateUserProfileDto } from './dto/update-user-profile.dto';
import { CreateDislikeDto } from './dto/create-dislike.dto';
import { RemoveDislikeDto } from './dto/remove-dislike.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('user-profiles')
@UseGuards(JwtAuthGuard)
export class UserProfilesController {
  constructor(private readonly userProfilesService: UserProfilesService) {}

  @Post()
  create(@Body() createUserProfileDto: CreateUserProfileDto, @Request() req) {
    createUserProfileDto.id = req.user.id;
    return this.userProfilesService.create(createUserProfileDto);
  }

  @Get('me')
  findMe(@Request() req) {
    return this.userProfilesService.findOne(req.user.id);
  }

  @Get('me/stats')
  getMyStats(@Request() req) {
    return this.userProfilesService.getUserStats(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.userProfilesService.findOne(id);
  }

  @Patch('me')
  updateMe(@Body() updateUserProfileDto: UpdateUserProfileDto, @Request() req) {
    return this.userProfilesService.update(req.user.id, updateUserProfileDto);
  }

  @Delete('me')
  removeMe(@Request() req) {
    return this.userProfilesService.remove(req.user.id);
  }

  @Post('me/dislikes')
  addDislike(@Body() createDislikeDto: CreateDislikeDto, @Request() req) {
    return this.userProfilesService.addDislike(req.user.id, createDislikeDto, req.user.email);
  }

  @Delete('me/dislikes')
  removeDislike(@Body() removeDislikeDto: RemoveDislikeDto, @Request() req) {
    return this.userProfilesService.removeDislike(
      req.user.id,
      removeDislikeDto,
    );
  }

  @Delete('me/dislikes/bulk')
  removeBulkDislikes(@Body() body: { menu_ids: number[] }, @Request() req) {
    return this.userProfilesService.removeBulkDislikes(
      req.user.id,
      body.menu_ids,
    );
  }

  @Get('me/dislikes')
  getUserDislikes(@Request() req, @Query('language') language = 'en') {
    return this.userProfilesService.getUserDislikes(req.user.id, language);
  }
}
