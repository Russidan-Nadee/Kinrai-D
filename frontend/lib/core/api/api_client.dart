import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../errors/exceptions.dart' as custom_exceptions;
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    AppLogger.info('🚀 Creating ApiClient instance');
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _addInterceptors();
    AppLogger.info('✅ ApiClient initialized with ${_dio.interceptors.length} interceptors');
  }

  Dio get dio => _dio;

  void _addInterceptors() {
    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
            AppLogger.debug('[API] Auth token added to request: ${options.path}');
          } else {
            AppLogger.warning('[API] No session found! Request will be sent without auth token: ${options.path}');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Log detailed error info
          AppLogger.error(
            '[API] Error: ${error.type} - ${error.message}',
            error.response,
          );

          // Don't retry, just pass the error
          handler.next(error);
        },
      ),
    );
    
    // Logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) {
          AppLogger.debug('[API] $obj');
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return custom_exceptions.NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return custom_exceptions.NetworkException(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Server error occurred';

        if (statusCode == 401) {
          return custom_exceptions.AuthException('Authentication failed. Please login again.');
        } else if (statusCode == 403) {
          return custom_exceptions.AuthException('Access denied. You don\'t have permission.');
        } else if (statusCode == 404) {
          return custom_exceptions.ServerException('Resource not found.', statusCode: statusCode);
        } else if (statusCode != null && statusCode >= 500) {
          return custom_exceptions.ServerException(
            'Server error. Please try again later.',
            statusCode: statusCode,
          );
        } else {
          return custom_exceptions.ServerException(message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return custom_exceptions.NetworkException('Request was cancelled.');

      default:
        return custom_exceptions.NetworkException(
          'An unexpected error occurred. Please try again.',
        );
    }
  }
}
