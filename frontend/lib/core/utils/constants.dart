import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Kinrai D';

  // API Configuration
  // In production: Use Railway URL from environment or const

  static const String _productionBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://kinrai-d-backend-production.up.railway.app',
  );

  static const String _developmentBaseUrl = 'http://localhost:8000';

  static String get baseUrl =>
      kReleaseMode ? _productionBaseUrl : _developmentBaseUrl;

  static const String apiVersion = '/api/v1'; // Backend API version

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Timeout
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
