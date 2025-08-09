import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class SupabaseAuthDataSource {
  Future<AuthResponseModel> signInWithGoogle();
  Future<UserModel> getCurrentUser();
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final SupabaseService supabaseService;
  final GoogleSignIn googleSignIn;

  SupabaseAuthDataSourceImpl({
    required this.supabaseService,
    required this.googleSignIn,
  });

  @override
  Future<AuthResponseModel> signInWithGoogle() async {
    try {
      // Try the direct OAuth approach first
      final bool success = await supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:3000/',
      );

      if (!success) {
        throw Exception('OAuth flow was cancelled');
      }

      // Wait a moment for auth state to update
      await Future.delayed(const Duration(seconds: 1));

      // Check for current session
      final session = supabaseService.currentSession;
      final user = supabaseService.currentUser;

      if (session == null || user == null) {
        throw Exception('Authentication completed but no user session found');
      }

      // Convert Supabase User to our UserModel
      final userModel = _supabaseUserToUserModel(user);
      
      return AuthResponseModel(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        user: userModel,
      );
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = supabaseService.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    return _supabaseUserToUserModel(user);
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await googleSignIn.signOut();
      
      // Sign out from Supabase
      await supabaseService.client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return supabaseService.isAuthenticated;
  }

  // Helper method to convert Supabase User to UserModel
  UserModel _supabaseUserToUserModel(User user) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name'] as String? ?? metadata['full_name'] as String?,
      photoUrl: metadata['avatar_url'] as String? ?? metadata['picture'] as String?,
      phoneNumber: user.phone,
      emailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : DateTime.parse(user.createdAt),
    );
  }
}