import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/supabase_auth_datasource.dart';
import '../../features/authentication/data/repositories/supabase_auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/menu_management_usecase.dart';
import '../../features/admin/domain/usecases/food_management_usecase.dart';
import '../../features/admin/presentation/providers/admin_provider.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Core
  late final ApiClient _apiClient;
  late final SecureStorageService _secureStorageService;
  late final SupabaseService _supabaseService;
  late final GoogleSignIn _googleSignIn;

  // Data Sources
  late final AuthRemoteDataSource _authRemoteDataSource;
  late final SupabaseAuthDataSource _supabaseAuthDataSource;
  late final AdminRemoteDataSource _adminRemoteDataSource;

  // Repositories
  late final AuthRepository _authRepository;
  late final AdminRepository _adminRepository;

  // Use Cases
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final MenuManagementUseCase _menuManagementUseCase;
  late final FoodManagementUseCase _foodManagementUseCase;

  // Providers
  late final AuthProvider _authProvider;
  late final AdminProvider _adminProvider;

  Future<void> init() async {
    // Core
    _apiClient = ApiClient();
    _apiClient.initialize();
    
    _secureStorageService = SecureStorageService();
    
    _supabaseService = SupabaseService();
    await _supabaseService.initialize();
    
    _googleSignIn = GoogleSignIn(
      clientId: SupabaseConfig.googleClientId,
      scopes: ['email', 'profile'],
    );

    // Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: _apiClient,
    );
    
    _supabaseAuthDataSource = SupabaseAuthDataSourceImpl(
      supabaseService: _supabaseService,
      googleSignIn: _googleSignIn,
    );

    _adminRemoteDataSource = AdminRemoteDataSourceImpl(
      apiClient: _apiClient,
    );

    // Repositories - Using Supabase by default
    _authRepository = SupabaseAuthRepositoryImpl(
      supabaseDataSource: _supabaseAuthDataSource,
    );
    
    // Alternative: Use custom backend instead
    // _authRepository = AuthRepositoryImpl(
    //   remoteDataSource: _authRemoteDataSource,
    //   secureStorage: _secureStorageService,
    // );

    _adminRepository = AdminRepositoryImpl(
      remoteDataSource: _adminRemoteDataSource,
    );

    // Use Cases
    _loginUsecase = LoginUsecase(_authRepository);
    _logoutUsecase = LogoutUsecase(_authRepository);
    _getCurrentUserUsecase = GetCurrentUserUsecase(_authRepository);
    _menuManagementUseCase = MenuManagementUseCase(_adminRepository);
    _foodManagementUseCase = FoodManagementUseCase(_adminRepository);

    // Providers
    _authProvider = AuthProvider(
      loginUsecase: _loginUsecase,
      logoutUsecase: _logoutUsecase,
      getCurrentUserUsecase: _getCurrentUserUsecase,
      googleSignIn: _googleSignIn,
    );

    _adminProvider = AdminProvider(
      menuManagementUseCase: _menuManagementUseCase,
      foodManagementUseCase: _foodManagementUseCase,
    );
  }

  // Getters
  ApiClient get apiClient => _apiClient;
  SecureStorageService get secureStorageService => _secureStorageService;
  SupabaseService get supabaseService => _supabaseService;
  GoogleSignIn get googleSignIn => _googleSignIn;
  
  AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;
  SupabaseAuthDataSource get supabaseAuthDataSource => _supabaseAuthDataSource;
  AdminRemoteDataSource get adminRemoteDataSource => _adminRemoteDataSource;
  
  AuthRepository get authRepository => _authRepository;
  AdminRepository get adminRepository => _adminRepository;
  
  LoginUsecase get loginUsecase => _loginUsecase;
  LogoutUsecase get logoutUsecase => _logoutUsecase;
  GetCurrentUserUsecase get getCurrentUserUsecase => _getCurrentUserUsecase;
  MenuManagementUseCase get menuManagementUseCase => _menuManagementUseCase;
  FoodManagementUseCase get foodManagementUseCase => _foodManagementUseCase;
  
  AuthProvider get authProvider => _authProvider;
  AdminProvider get adminProvider => _adminProvider;
}