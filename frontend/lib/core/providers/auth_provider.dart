import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  String? _error;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1', // Backend URL with /api/v1 prefix
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = Supabase.instance.client.auth.currentUser;
    _isLoading = false;
    notifyListeners();

    // Listen to auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔐 Attempting login with: $email'); // Debug

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login response: ${response.user?.email}'); // Debug

      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Login error: $e'); // Debug

      // Handle email not confirmed error
      if (e.toString().contains('email_not_confirmed')) {
        _error = 'Please verify your email address before signing in. Check your inbox for a verification email.';
      } else {
        _error = e.toString();
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('📧 Attempting signup with: $email'); // Debug

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Signup successful, syncing user to database'); // Debug

        // Sync user to backend database
        await _syncUserToDatabase(response.user!);

        _user = response.user;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Signup error: $e'); // Debug
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncUserToDatabase(User user) async {
    try {
      print('🔄 Syncing user ${user.email} to database'); // Debug

      final response = await _dio.post('/users/sync', data: {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'phone': user.userMetadata?['phone'],
      });

      if (response.statusCode == 201) {
        print('✅ User synced to database successfully'); // Debug
      }
    } catch (e) {
      print('❌ Failed to sync user to database: $e'); // Debug
      // Don't throw error - user is still created in Supabase
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}