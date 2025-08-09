import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> loginWithGoogle(String googleToken);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<AuthResponseModel> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> loginWithGoogle(String googleToken) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.googleLogin,
        data: {
          'google_token': googleToken,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponseModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(apiResponse.message);
        }
      } else {
        throw ServerException(
          'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred during login');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => UserModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(apiResponse.message);
        }
      } else {
        throw ServerException(
          'Failed to get user profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred while getting user');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.post(ApiEndpoints.logout);

      if (response.statusCode != 200) {
        throw ServerException(
          'Logout failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException || e is AuthException) {
        rethrow;
      }
      throw ServerException('An unexpected error occurred during logout');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken() async {
    try {
      final response = await apiClient.post(ApiEndpoints.refreshToken);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponseModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw AuthException(apiResponse.message);
        }
      } else {
        throw AuthException('Token refresh failed');
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw AuthException('An unexpected error occurred during token refresh');
    }
  }
}