import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle(String googleToken) async {
    try {
      final result = await remoteDataSource.loginWithGoogle(googleToken);
      
      // Store tokens securely
      await secureStorage.write(AppConstants.accessTokenKey, result.accessToken);
      await secureStorage.write(AppConstants.refreshTokenKey, result.refreshToken);
      
      // Convert UserModel to UserEntity
      final userEntity = UserEntity(
        id: result.user.id,
        email: result.user.email,
        name: result.user.name,
        photoUrl: result.user.photoUrl,
        phoneNumber: result.user.phoneNumber,
        emailVerified: result.user.emailVerified,
        createdAt: result.user.createdAt,
        updatedAt: result.user.updatedAt,
      );
      
      return Right(userEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      
      // Convert UserModel to UserEntity
      final userEntity = UserEntity(
        id: result.id,
        email: result.email,
        name: result.name,
        photoUrl: result.photoUrl,
        phoneNumber: result.phoneNumber,
        emailVerified: result.emailVerified,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
      
      return Right(userEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      
      // Clear stored tokens
      await secureStorage.deleteAll();
      
      return const Right(null);
    } on ServerException catch (e) {
      // Even if server logout fails, clear local tokens
      await secureStorage.deleteAll();
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Even if network fails, clear local tokens
      await secureStorage.deleteAll();
      return Left(NetworkFailure(e.message));
    } on AuthException catch (e) {
      await secureStorage.deleteAll();
      return Left(AuthFailure(e.message));
    } catch (e) {
      await secureStorage.deleteAll();
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final accessToken = await secureStorage.read(AppConstants.accessTokenKey);
      return Right(accessToken != null);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    try {
      final result = await remoteDataSource.refreshToken();
      
      // Update stored tokens
      await secureStorage.write(AppConstants.accessTokenKey, result.accessToken);
      await secureStorage.write(AppConstants.refreshTokenKey, result.refreshToken);
      
      // Convert UserModel to UserEntity
      final userEntity = UserEntity(
        id: result.user.id,
        email: result.user.email,
        name: result.user.name,
        photoUrl: result.user.photoUrl,
        phoneNumber: result.user.phoneNumber,
        emailVerified: result.user.emailVerified,
        createdAt: result.user.createdAt,
        updatedAt: result.user.updatedAt,
      );
      
      return Right(userEntity);
    } on AuthException catch (e) {
      // Clear tokens if refresh fails
      await secureStorage.deleteAll();
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      await secureStorage.deleteAll();
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      await secureStorage.deleteAll();
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}