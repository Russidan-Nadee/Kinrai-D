import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GoogleSignIn googleSignIn;

  AuthProvider({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
    required this.googleSignIn,
  });

  AuthState _state = AuthState.initial;
  UserEntity? _user;
  String _errorMessage = '';

  // Getters
  AuthState get state => _state;
  UserEntity? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Initialize auth state
  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);

    final result = await getCurrentUserUsecase();
    result.fold(
      (failure) {
        _setError(failure.toString());
        _setState(AuthState.unauthenticated);
      },
      (user) {
        _user = user;
        _setState(AuthState.authenticated);
      },
    );
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // Login with Supabase (handles Google sign-in internally)
      final result = await loginUsecase(''); // Empty token as Supabase handles it
      result.fold(
        (failure) {
          _setError(failure.toString());
          _setState(AuthState.error);
        },
        (user) {
          _user = user;
          _setState(AuthState.authenticated);
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred during sign in: $e');
      _setState(AuthState.error);
    }
  }

  // Email/Password Sign In
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final result = await loginUsecase('email:$email:$password');
      result.fold(
        (failure) {
          _setError(failure.toString());
          _setState(AuthState.error);
        },
        (user) {
          _user = user;
          _setState(AuthState.authenticated);
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred during sign in: $e');
      _setState(AuthState.error);
    }
  }

  // Email/Password Sign Up
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _setState(AuthState.loading);
      _clearError();

      final result = await loginUsecase('signup:$email:$password');
      result.fold(
        (failure) {
          _setError(failure.toString());
          _setState(AuthState.error);
        },
        (user) {
          _user = user;
          _setState(AuthState.authenticated);
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred during sign up: $e');
      _setState(AuthState.error);
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      _setState(AuthState.loading);
      _clearError();

      // Sign out from Google
      await googleSignIn.signOut();

      // Logout from backend
      final result = await logoutUsecase();
      result.fold(
        (failure) {
          // Even if backend logout fails, we should clear local state
          debugPrint('Backend logout failed: $failure');
        },
        (_) {
          debugPrint('Successfully logged out from backend');
        },
      );

      // Clear user data and set state
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('An error occurred during sign out: $e');
      _setState(AuthState.error);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_state != AuthState.authenticated) return;

    final result = await getCurrentUserUsecase();
    result.fold(
      (failure) {
        debugPrint('Failed to refresh user data: $failure');
        // Don't change state, just log the error
      },
      (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  // Helper methods
  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('AuthProvider Error: $message');
  }

  void _clearError() {
    _errorMessage = '';
  }

  void clearError() {
    _clearError();
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
  }
}