class AppConstants {
  static const String appName = 'Kinrai D';
  
  // API Configuration
  static const String baseUrl = 'https://api.kinrai-d.com'; // Replace with your API URL
  static const String apiVersion = '/v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Timeout
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}