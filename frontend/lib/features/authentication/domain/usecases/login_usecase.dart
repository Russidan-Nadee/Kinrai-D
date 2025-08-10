import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(String token) async {
    // Parse the token to determine authentication method
    if (token.isEmpty) {
      // Google authentication
      return await repository.loginWithGoogle('');
    } else if (token.startsWith('email:')) {
      // Email/password authentication
      final parts = token.split(':');
      if (parts.length == 3) {
        return await (repository as dynamic).loginWithEmail(parts[1], parts[2]);
      }
    } else if (token.startsWith('signup:')) {
      // Email/password signup
      final parts = token.split(':');
      if (parts.length == 3) {
        return await (repository as dynamic).signUpWithEmail(parts[1], parts[2]);
      }
    }
    
    // Fallback to Google authentication
    return await repository.loginWithGoogle(token);
  }
}