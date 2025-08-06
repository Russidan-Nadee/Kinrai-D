import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Get,
  UseGuards,
  Request,
  Patch,
  BadRequestException,
  UnauthorizedException
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { SupabaseService } from './supabase.service';
import { LoggingService } from '../common/services/logging.service';
import { SignUpDto, SignInDto, ResetPasswordDto, UpdatePasswordDto, UpdateProfileDto } from './dto/auth.dto';
import { SupabaseAuthGuard } from './guards/supabase-auth.guard';

@ApiTags('authentication')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly loggingService: LoggingService
  ) {}

  @Post('signup')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User registered successfully.' })
  @ApiResponse({ status: 400, description: 'Bad Request.' })
  @ApiBody({ type: SignUpDto })
  async signUp(@Body() signUpDto: SignUpDto) {
    const { email, password, ...userData } = signUpDto;

    if (!email || !password) {
      throw new BadRequestException('Email and password are required');
    }

    const result = await this.supabaseService.signUp(email, password, userData);

    if (result.error) {
      this.loggingService.logSecurityEvent('signup_failed', {
        ip: undefined, // Would be extracted from request in real scenario
        userAgent: undefined,
        metadata: { email, error: result.error.message }
      }, 'medium');
      
      throw new BadRequestException(result.error.message);
    }

    // Log successful signup
    this.loggingService.logBusinessEvent('user_signup', {
      userId: result.user?.id,
      email: result.user?.email,
      provider: 'email'
    });

    return {
      message: 'User registered successfully. Please check your email for verification.',
      user: {
        id: result.user?.id,
        email: result.user?.email,
        email_confirmed: false
      }
    };
  }

  @Post('signin')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Sign in user' })
  @ApiResponse({ status: 200, description: 'User signed in successfully.' })
  @ApiResponse({ status: 401, description: 'Invalid credentials.' })
  @ApiBody({ type: SignInDto })
  async signIn(@Body() signInDto: SignInDto) {
    const { email, password } = signInDto;

    if (!email || !password) {
      throw new BadRequestException('Email and password are required');
    }

    const result = await this.supabaseService.signIn(email, password);

    if (result.error) {
      this.loggingService.logSecurityEvent('signin_failed', {
        ip: undefined,
        userAgent: undefined,
        metadata: { email, error: result.error.message }
      }, 'medium');
      
      throw new UnauthorizedException('Invalid credentials');
    }

    // Log successful signin
    this.loggingService.logBusinessEvent('user_signin', {
      userId: result.user?.id,
      email: result.user?.email,
      provider: 'email'
    });

    // Log user activity
    this.loggingService.logUserActivity({
      userId: result.user!.id,
      action: 'signin',
      resource: 'auth',
      timestamp: new Date()
    });

    return {
      message: 'Signed in successfully',
      user: {
        id: result.user?.id,
        email: result.user?.email,
        role: result.user?.role
      },
      access_token: result.session?.access_token,
      refresh_token: result.session?.refresh_token,
      expires_at: result.session?.expires_at
    };
  }

  @Post('signout')
  @UseGuards(SupabaseAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Sign out user' })
  @ApiResponse({ status: 204, description: 'User signed out successfully.' })
  async signOut(@Request() req) {
    const token = this.extractTokenFromHeader(req);
    const result = await this.supabaseService.signOut(token);

    if (result.error) {
      throw new BadRequestException(result.error.message);
    }

    // Log signout activity
    this.loggingService.logUserActivity({
      userId: req.user.id,
      action: 'signout',
      resource: 'auth',
      timestamp: new Date()
    });
  }

  @Post('social/:provider')
  @ApiOperation({ summary: 'Sign in with social provider' })
  @ApiResponse({ status: 200, description: 'Social sign in initiated.' })
  async socialSignIn(@Body('provider') provider: 'google' | 'facebook' | 'github' | 'apple') {
    if (!['google', 'facebook', 'github', 'apple'].includes(provider)) {
      throw new BadRequestException('Unsupported provider');
    }

    const result = await this.supabaseService.signInWithProvider(provider);

    if (result.error) {
      throw new BadRequestException(result.error.message);
    }

    return {
      message: `${provider} sign in initiated`,
      url: result.url
    };
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request password reset' })
  @ApiResponse({ status: 200, description: 'Password reset email sent.' })
  @ApiBody({ type: ResetPasswordDto })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    const { email } = resetPasswordDto;

    if (!email) {
      throw new BadRequestException('Email is required');
    }

    const result = await this.supabaseService.resetPassword(email);

    if (result.error) {
      // Don't reveal whether email exists or not for security
      this.loggingService.logSecurityEvent('password_reset_failed', {
        ip: undefined,
        userAgent: undefined,
        metadata: { email, error: result.error.message }
      }, 'low');
    } else {
      this.loggingService.logSecurityEvent('password_reset_requested', {
        ip: undefined,
        userAgent: undefined,
        metadata: { email }
      }, 'low');
    }

    // Always return success to prevent email enumeration
    return {
      message: 'If the email exists, a password reset link will be sent.'
    };
  }

  @Patch('update-password')
  @UseGuards(SupabaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user password' })
  @ApiResponse({ status: 200, description: 'Password updated successfully.' })
  @ApiBody({ type: UpdatePasswordDto })
  async updatePassword(@Request() req, @Body() updatePasswordDto: UpdatePasswordDto) {
    const { newPassword } = updatePasswordDto;
    const token = this.extractTokenFromHeader(req);

    if (!newPassword || newPassword.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters long');
    }

    const result = await this.supabaseService.updatePassword(token, newPassword);

    if (result.error) {
      throw new BadRequestException(result.error.message);
    }

    // Log password update
    this.loggingService.logSecurityEvent('password_updated', {
      userId: req.user.id,
      ip: undefined,
      userAgent: undefined
    }, 'low');

    return {
      message: 'Password updated successfully'
    };
  }

  @Get('profile')
  @UseGuards(SupabaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved successfully.' })
  async getProfile(@Request() req) {
    return {
      user: {
        id: req.user.id,
        email: req.user.email,
        phone: req.user.phone,
        user_metadata: req.user.user_metadata,
        role: req.user.role,
        created_at: req.user.created_at,
        updated_at: req.user.updated_at
      }
    };
  }

  @Patch('profile')
  @UseGuards(SupabaseAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update user profile' })
  @ApiResponse({ status: 200, description: 'Profile updated successfully.' })
  @ApiBody({ type: UpdateProfileDto })
  async updateProfile(@Request() req, @Body() updateProfileDto: UpdateProfileDto) {
    const token = this.extractTokenFromHeader(req);
    const result = await this.supabaseService.updateUserMetadata(token, updateProfileDto);

    if (result.error) {
      throw new BadRequestException(result.error.message);
    }

    // Log profile update
    this.loggingService.logUserActivity({
      userId: req.user.id,
      action: 'update_profile',
      resource: 'user_profile',
      timestamp: new Date(),
      metadata: { updatedFields: Object.keys(updateProfileDto) }
    });

    return {
      message: 'Profile updated successfully',
      user: result.user
    };
  }

  @Get('health')
  @ApiOperation({ summary: 'Check auth service health' })
  @ApiResponse({ status: 200, description: 'Auth service health status.' })
  async healthCheck() {
    const health = await this.supabaseService.healthCheck();
    return {
      service: 'authentication',
      status: health.status,
      message: health.message,
      timestamp: new Date().toISOString()
    };
  }

  private extractTokenFromHeader(request: any): string {
    const authHeader = request.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Invalid authorization header');
    }
    return authHeader.substring(7);
  }
}