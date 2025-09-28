import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { ProteinPreferencesService } from './protein-preferences.service';
import { SetProteinPreferenceDto } from './dto/set-protein-preference.dto';
import { RemoveProteinPreferenceDto } from './dto/remove-protein-preference.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('protein-preferences')
@UseGuards(JwtAuthGuard)
export class ProteinPreferencesController {
  constructor(
    private readonly proteinPreferencesService: ProteinPreferencesService,
  ) {}

  @Get('available')
  getAvailableProteinTypes(@Query('language') language = 'en') {
    return this.proteinPreferencesService.getAvailableProteinTypes(language);
  }

  @Get('me')
  getUserProteinPreferences(@Request() req, @Query('language') language = 'en') {
    return this.proteinPreferencesService.getUserProteinPreferences(
      req.user.id,
      language,
    );
  }

  @Post('me')
  setProteinPreference(
    @Body() setProteinPreferenceDto: SetProteinPreferenceDto,
    @Request() req,
  ) {
    return this.proteinPreferencesService.setProteinPreference(
      req.user.id,
      setProteinPreferenceDto,
      req.user.email,
    );
  }

  @Delete('me')
  removeProteinPreference(
    @Body() removeProteinPreferenceDto: RemoveProteinPreferenceDto,
    @Request() req,
  ) {
    return this.proteinPreferencesService.removeProteinPreference(
      req.user.id,
      removeProteinPreferenceDto,
    );
  }
}
