import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';

export interface SupabaseUser {
  id: string;
  email?: string;
  phone?: string;
  user_metadata?: any;
  app_metadata?: any;
  created_at: string;
  updated_at: string;
  role?: string;
}

export interface AuthResponse {
  user: SupabaseUser | null;
  error: Error | null;
}

@Injectable()
export class SupabaseService {
  private readonly logger = new Logger(SupabaseService.name);
  private supabase: SupabaseClient;

  constructor(private configService: ConfigService) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_ANON_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Supabase URL and Anon Key are required');
    }

    this.supabase = createClient(supabaseUrl, supabaseKey);
    this.logger.log('Supabase client initialized');
  }

  /**
   * Get Supabase client instance
   */
  getClient(): SupabaseClient {
    return this.supabase;
  }

  /**
   * Verify JWT token and get user
   */
  async verifyToken(token: string): Promise<SupabaseUser> {
    try {
      const { data: { user }, error } = await this.supabase.auth.getUser(token);
      
      if (error || !user) {
        this.logger.warn('Invalid token verification:', error?.message);
        throw new UnauthorizedException('Invalid or expired token');
      }

      return this.mapUser(user);
    } catch (error) {
      this.logger.error('Token verification failed:', error);
      throw new UnauthorizedException('Authentication failed');
    }
  }

  /**
   * Sign up with email and password
   */
  async signUp(email: string, password: string, userData?: any): Promise<AuthResponse> {
    try {
      const { data, error } = await this.supabase.auth.signUp({
        email,
        password,
        options: {
          data: userData
        }
      });

      if (error) {
        this.logger.warn('Sign up failed:', error.message);
        return { user: null, error: new Error(error.message) };
      }

      return { 
        user: data.user ? this.mapUser(data.user) : null, 
        error: null 
      };
    } catch (error) {
      this.logger.error('Sign up error:', error);
      return { user: null, error: error as Error };
    }
  }

  /**
   * Sign in with email and password
   */
  async signIn(email: string, password: string): Promise<AuthResponse & { session?: any }> {
    try {
      const { data, error } = await this.supabase.auth.signInWithPassword({
        email,
        password
      });

      if (error) {
        this.logger.warn('Sign in failed:', error.message);
        return { user: null, error: new Error(error.message) };
      }

      return { 
        user: data.user ? this.mapUser(data.user) : null, 
        session: data.session,
        error: null 
      };
    } catch (error) {
      this.logger.error('Sign in error:', error);
      return { user: null, error: error as Error };
    }
  }

  /**
   * Sign in with social provider
   */
  async signInWithProvider(provider: 'google' | 'facebook' | 'github' | 'apple') {
    try {
      const { data, error } = await this.supabase.auth.signInWithOAuth({
        provider,
        options: {
          redirectTo: this.configService.get('FRONTEND_URL') || 'http://localhost:3000'
        }
      });

      if (error) {
        this.logger.warn(`${provider} sign in failed:`, error.message);
        return { url: null, error: new Error(error.message) };
      }

      return { url: data.url, error: null };
    } catch (error) {
      this.logger.error(`${provider} sign in error:`, error);
      return { url: null, error: error as Error };
    }
  }

  /**
   * Sign out user
   */
  async signOut(token: string): Promise<{ error: Error | null }> {
    try {
      // Set the session before signing out
      await this.supabase.auth.setSession({
        access_token: token,
        refresh_token: '', // This would come from the client
      });

      const { error } = await this.supabase.auth.signOut();
      
      if (error) {
        this.logger.warn('Sign out failed:', error.message);
        return { error: new Error(error.message) };
      }

      return { error: null };
    } catch (error) {
      this.logger.error('Sign out error:', error);
      return { error: error as Error };
    }
  }

  /**
   * Reset password
   */
  async resetPassword(email: string): Promise<{ error: Error | null }> {
    try {
      const { error } = await this.supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${this.configService.get('FRONTEND_URL')}/reset-password`
      });

      if (error) {
        this.logger.warn('Password reset failed:', error.message);
        return { error: new Error(error.message) };
      }

      return { error: null };
    } catch (error) {
      this.logger.error('Password reset error:', error);
      return { error: error as Error };
    }
  }

  /**
   * Update user password
   */
  async updatePassword(token: string, newPassword: string): Promise<{ error: Error | null }> {
    try {
      // Set the session
      await this.supabase.auth.setSession({
        access_token: token,
        refresh_token: '',
      });

      const { error } = await this.supabase.auth.updateUser({
        password: newPassword
      });

      if (error) {
        this.logger.warn('Password update failed:', error.message);
        return { error: new Error(error.message) };
      }

      return { error: null };
    } catch (error) {
      this.logger.error('Password update error:', error);
      return { error: error as Error };
    }
  }

  /**
   * Update user metadata
   */
  async updateUserMetadata(token: string, metadata: any): Promise<AuthResponse> {
    try {
      // Set the session
      await this.supabase.auth.setSession({
        access_token: token,
        refresh_token: '',
      });

      const { data, error } = await this.supabase.auth.updateUser({
        data: metadata
      });

      if (error) {
        this.logger.warn('User metadata update failed:', error.message);
        return { user: null, error: new Error(error.message) };
      }

      return { 
        user: data.user ? this.mapUser(data.user) : null, 
        error: null 
      };
    } catch (error) {
      this.logger.error('User metadata update error:', error);
      return { user: null, error: error as Error };
    }
  }

  /**
   * Get user by ID (admin function)
   */
  async getUserById(userId: string): Promise<SupabaseUser | null> {
    try {
      // This would typically require admin privileges
      const { data, error } = await this.supabase.auth.admin.getUserById(userId);
      
      if (error || !data.user) {
        this.logger.warn('Get user by ID failed:', error?.message);
        return null;
      }

      return this.mapUser(data.user);
    } catch (error) {
      this.logger.error('Get user by ID error:', error);
      return null;
    }
  }

  /**
   * Check if user has specific role
   */
  async hasRole(userId: string, role: string): Promise<boolean> {
    try {
      const user = await this.getUserById(userId);
      const userRole = user?.app_metadata?.role || user?.role || 'user';
      return userRole === role || userRole === 'admin'; // Admin has all roles
    } catch (error) {
      this.logger.error('Role check error:', error);
      return false;
    }
  }

  /**
   * Check if user has specific permission
   */
  async hasPermission(userId: string, permission: string): Promise<boolean> {
    try {
      const user = await this.getUserById(userId);
      const permissions = user?.app_metadata?.permissions || [];
      const role = user?.app_metadata?.role || 'user';
      
      // Admin has all permissions
      if (role === 'admin') return true;
      
      return permissions.includes(permission);
    } catch (error) {
      this.logger.error('Permission check error:', error);
      return false;
    }
  }

  /**
   * Create user profile after authentication
   */
  async createUserProfile(userId: string, profileData: any): Promise<any> {
    try {
      const { data, error } = await this.supabase
        .from('user_profiles')
        .insert({
          id: userId,
          ...profileData,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .select()
        .single();

      if (error) {
        this.logger.warn('User profile creation failed:', error.message);
        return null;
      }

      return data;
    } catch (error) {
      this.logger.error('User profile creation error:', error);
      return null;
    }
  }

  /**
   * Map Supabase user to our user interface
   */
  private mapUser(user: User): SupabaseUser {
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      user_metadata: user.user_metadata,
      app_metadata: user.app_metadata,
      created_at: user.created_at,
      updated_at: user.updated_at || user.created_at,
      role: user.app_metadata?.role || user.user_metadata?.role || 'user'
    };
  }

  /**
   * Health check for Supabase connection
   */
  async healthCheck(): Promise<{ status: 'healthy' | 'unhealthy'; message: string }> {
    try {
      // Simple check by trying to access auth
      const { data } = await this.supabase.auth.getSession();
      return { 
        status: 'healthy', 
        message: 'Supabase connection is healthy' 
      };
    } catch (error) {
      this.logger.error('Supabase health check failed:', error);
      return { 
        status: 'unhealthy', 
        message: `Supabase connection failed: ${error.message}` 
      };
    }
  }
}