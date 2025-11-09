import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _supabaseUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1', // Backend URL with /api/v1 prefix
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabaseUser != null;

  AuthProvider() {
    _init();
  }

  void _init() async {
    _supabaseUser = Supabase.instance.client.auth.currentUser;
    if (_supabaseUser != null) {
      await _fetchUserModel(_supabaseUser!);
    }
    _isLoading = false;
    notifyListeners();

    // Listen to auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      _supabaseUser = data.session?.user;
      if (_supabaseUser != null) {
        await _fetchUserModel(_supabaseUser!);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserModel(User supabaseUser) async {
    try {
      AppLogger.info('📥 Fetching user data from backend for: ${supabaseUser.email}');

      final response = await _dio.get('/users/${supabaseUser.id}');

      if (response.statusCode == 200 && response.data != null) {
        _userModel = UserModel.fromJson(response.data);
        AppLogger.info('✅ User model fetched successfully. isAdmin: ${_userModel?.isAdmin}');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to fetch user model, using default', e);
      // Fallback: Create UserModel from Supabase user data
      _userModel = UserModel(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: supabaseUser.userMetadata?['name'],
        emailVerified: supabaseUser.emailConfirmedAt != null,
        isAdmin: false, // Default to non-admin
        createdAt: DateTime.parse(supabaseUser.createdAt),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('🔐 Attempting login with: $email');

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      AppLogger.info('✅ Login response: ${response.user?.email}');

      _supabaseUser = response.user;
      if (_supabaseUser != null) {
        await _fetchUserModel(_supabaseUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('❌ Login error', e);

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

      AppLogger.info('📧 Attempting signup with: $email');

      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        AppLogger.info('✅ Signup successful, syncing user to database');

        // Sync user to backend database
        await _syncUserToDatabase(response.user!);

        _supabaseUser = response.user;
        await _fetchUserModel(_supabaseUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('❌ Signup error', e);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncUserToDatabase(User user) async {
    try {
      AppLogger.info('🔄 Syncing user ${user.email} to database');

      final response = await _dio.post('/users/sync', data: {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'phone': user.userMetadata?['phone'],
      });

      if (response.statusCode == 201) {
        AppLogger.info('✅ User synced to database successfully');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to sync user to database', e);
      // Don't throw error - user is still created in Supabase
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _supabaseUser = null;
      _userModel = null;
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
