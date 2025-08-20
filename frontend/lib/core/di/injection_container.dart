import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Core
  late final ApiClient _apiClient;
  late final SecureStorageService _secureStorageService;
  late final GoogleSignIn _googleSignIn;

  // Data Sources
  late final AuthRemoteDataSource _authRemoteDataSource;

  // Repositories
  late final AuthRepository _authRepository;

  // Use Cases
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;

  // Providers
  late final AuthProvider _authProvider;

  Future<void> init() async {
    // Core
    _apiClient = ApiClient();
    _apiClient.initialize();
    
    _secureStorageService = SecureStorageService();
    
    
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    // Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: _apiClient,
    );

    // Repositories - Use custom backend authentication
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      secureStorage: _secureStorageService,
    );

    // Use Cases
    _loginUsecase = LoginUsecase(_authRepository);
    _logoutUsecase = LogoutUsecase(_authRepository);
    _getCurrentUserUsecase = GetCurrentUserUsecase(_authRepository);

    // Providers
    _authProvider = AuthProvider(
      loginUsecase: _loginUsecase,
      logoutUsecase: _logoutUsecase,
      getCurrentUserUsecase: _getCurrentUserUsecase,
      googleSignIn: _googleSignIn,
    );
  }

  // Getters
  ApiClient get apiClient => _apiClient;
  SecureStorageService get secureStorageService => _secureStorageService;
  GoogleSignIn get googleSignIn => _googleSignIn;
  
  AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;
  
  AuthRepository get authRepository => _authRepository;
  
  LoginUsecase get loginUsecase => _loginUsecase;
  LogoutUsecase get logoutUsecase => _logoutUsecase;
  GetCurrentUserUsecase get getCurrentUserUsecase => _getCurrentUserUsecase;
  
  AuthProvider get authProvider => _authProvider;
}