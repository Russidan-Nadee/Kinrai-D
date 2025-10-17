class AppConstants {
  static const String appName = 'Kinrai D';

  // API Configuration
  // Use --dart-define=API_URL=... from run.bat
  // Development: uses localhost by default
  // Production: uses URL from --dart-define

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String apiVersion = '/api/v1'; // Backend API version

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Timeout
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
