import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../utils/constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _addInterceptors();
  }

  void _addInterceptors() {
    // Request interceptor - Add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(AppConstants.accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      
      onError: (error, handler) async {
        // Handle 401 errors - refresh token
        if (error.response?.statusCode == 401) {
          if (await _refreshToken()) {
            // Retry the original request
            final clonedRequest = await _dio.request(
              error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
            );
            return handler.resolve(clonedRequest);
          }
        }
        handler.next(error);
      },
    ));

    // Logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(AppConstants.accessTokenKey, data['access_token']);
        await _storage.write(AppConstants.refreshTokenKey, data['refresh_token']);
        return true;
      }
    } catch (e) {
      // Refresh failed, user needs to login again
      await _storage.deleteAll();
    }
    return false;
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network settings.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error occurred';
        
        if (statusCode == 401) {
          return AuthException('Authentication failed. Please login again.');
        } else if (statusCode == 403) {
          return AuthException('Access denied. You don\'t have permission.');
        } else if (statusCode == 404) {
          return ServerException('Resource not found.', statusCode: statusCode);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException('Server error. Please try again later.', statusCode: statusCode);
        } else {
          return ServerException(message, statusCode: statusCode);
        }
      
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');
      
      default:
        return NetworkException('An unexpected error occurred. Please try again.');
    }
  }
}