import '../utils/constants.dart';

class ApiEndpoints {
  // Base URL with API version
  static String get baseUrl => AppConstants.baseUrl + AppConstants.apiVersion;

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String register = '/auth/register';

  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/account';

  // Build full URL
  static String buildUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}