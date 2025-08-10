import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource supabaseDataSource;

  SupabaseAuthRepositoryImpl({
    required this.supabaseDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle(String googleToken) async {
    try {
      final result = await supabaseDataSource.signInWithGoogle();
      
      // Convert UserModel to UserEntity
      final userEntity = _userModelToEntity(result.user);
      
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during login'));
    }
  }

  Future<Either<Failure, UserEntity>> loginWithEmail(String email, String password) async {
    try {
      final result = await supabaseDataSource.signInWithEmail(email, password);
      
      // Convert UserModel to UserEntity
      final userEntity = _userModelToEntity(result.user);
      
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during email login'));
    }
  }

  Future<Either<Failure, UserEntity>> signUpWithEmail(String email, String password) async {
    try {
      final result = await supabaseDataSource.signUpWithEmail(email, password);
      
      // Convert UserModel to UserEntity
      final userEntity = _userModelToEntity(result.user);
      
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during email signup'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final result = await supabaseDataSource.getCurrentUser();
      
      // Convert UserModel to UserEntity
      final userEntity = _userModelToEntity(result);
      
      return Right(userEntity);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred while getting user'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await supabaseDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during logout'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isAuthenticated = await supabaseDataSource.isAuthenticated();
      return Right(isAuthenticated);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    // Supabase handles token refresh automatically
    // Just return current user
    return getCurrentUser();
  }

  // Helper method to convert UserModel to UserEntity
  UserEntity _userModelToEntity(userModel) {
    return UserEntity(
      id: userModel.id,
      email: userModel.email,
      name: userModel.name,
      photoUrl: userModel.photoUrl,
      phoneNumber: userModel.phoneNumber,
      emailVerified: userModel.emailVerified,
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
    );
  }
}