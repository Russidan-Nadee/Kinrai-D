import 'package:get_it/get_it.dart';
import '../api/api_client.dart';

// Random Menu
import '../../features/random_menu/data/datasources/menu_remote_data_source.dart';
import '../../features/random_menu/data/repositories/menu_repository_impl.dart';
import '../../features/random_menu/domain/repositories/menu_repository.dart';
import '../../features/random_menu/domain/usecases/get_personalized_random_menu.dart';

// Dislikes
import '../../features/dislikes/data/datasources/dislike_remote_data_source.dart';
import '../../features/dislikes/data/repositories/dislike_repository_impl.dart';
import '../../features/dislikes/domain/repositories/dislike_repository.dart';
import '../../features/dislikes/domain/usecases/get_user_dislikes.dart';
import '../../features/dislikes/domain/usecases/add_dislike.dart';
import '../../features/dislikes/domain/usecases/remove_dislike.dart';
import '../../features/dislikes/domain/usecases/remove_bulk_dislikes.dart';
import '../../features/dislikes/domain/usecases/is_menu_disliked.dart';

// Protein Preferences
import '../../features/protein_preferences/data/datasources/protein_preference_remote_data_source.dart';
import '../../features/protein_preferences/data/repositories/protein_preference_repository_impl.dart';
import '../../features/protein_preferences/domain/repositories/protein_preference_repository.dart';
import '../../features/protein_preferences/domain/usecases/get_available_protein_types.dart';
import '../../features/protein_preferences/domain/usecases/get_user_protein_preferences.dart';
import '../../features/protein_preferences/domain/usecases/set_protein_preference.dart';
import '../../features/protein_preferences/domain/usecases/remove_protein_preference.dart';

// Profile
import '../../features/profile/presentation/providers/profile_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core - Singleton
  // ApiClient is already a singleton, initialize it once
  final apiClient = ApiClient();
  apiClient.initialize();
  getIt.registerSingleton<ApiClient>(apiClient);

  // Data Sources
  getIt.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: getIt<MenuRemoteDataSource>()),
  );

  // Use Cases - Random Menu
  getIt.registerLazySingleton<GetPersonalizedRandomMenu>(
    () => GetPersonalizedRandomMenu(getIt<MenuRepository>()),
  );

  // Data Sources - Dislikes
  getIt.registerLazySingleton<DislikeRemoteDataSource>(
    () => DislikeRemoteDataSourceImpl(),
  );

  // Repositories - Dislikes
  getIt.registerLazySingleton<DislikeRepository>(
    () => DislikeRepositoryImpl(remoteDataSource: getIt<DislikeRemoteDataSource>()),
  );

  // Use Cases - Dislikes
  getIt.registerLazySingleton<GetUserDislikes>(
    () => GetUserDislikes(getIt<DislikeRepository>()),
  );
  getIt.registerLazySingleton<AddDislike>(
    () => AddDislike(getIt<DislikeRepository>()),
  );
  getIt.registerLazySingleton<RemoveDislike>(
    () => RemoveDislike(getIt<DislikeRepository>()),
  );
  getIt.registerLazySingleton<RemoveBulkDislikes>(
    () => RemoveBulkDislikes(getIt<DislikeRepository>()),
  );
  getIt.registerLazySingleton<IsMenuDisliked>(
    () => IsMenuDisliked(getIt<DislikeRepository>()),
  );

  // Data Sources - Protein Preferences
  getIt.registerLazySingleton<ProteinPreferenceRemoteDataSource>(
    () => ProteinPreferenceRemoteDataSourceImpl(),
  );

  // Repositories - Protein Preferences
  getIt.registerLazySingleton<ProteinPreferenceRepository>(
    () => ProteinPreferenceRepositoryImpl(
      remoteDataSource: getIt<ProteinPreferenceRemoteDataSource>(),
    ),
  );

  // Use Cases - Protein Preferences
  getIt.registerLazySingleton<GetAvailableProteinTypes>(
    () => GetAvailableProteinTypes(getIt<ProteinPreferenceRepository>()),
  );
  getIt.registerLazySingleton<GetUserProteinPreferences>(
    () => GetUserProteinPreferences(getIt<ProteinPreferenceRepository>()),
  );
  getIt.registerLazySingleton<SetProteinPreference>(
    () => SetProteinPreference(getIt<ProteinPreferenceRepository>()),
  );
  getIt.registerLazySingleton<RemoveProteinPreference>(
    () => RemoveProteinPreference(getIt<ProteinPreferenceRepository>()),
  );

  // Providers - Profile (Singleton - keep data in memory)
  getIt.registerLazySingleton<ProfileProvider>(
    () => ProfileProvider(
      getAvailableProteinTypes: getIt<GetAvailableProteinTypes>(),
      getUserProteinPreferences: getIt<GetUserProteinPreferences>(),
      setProteinPreference: getIt<SetProteinPreference>(),
      removeProteinPreference: getIt<RemoveProteinPreference>(),
      getUserDislikes: getIt<GetUserDislikes>(),
      removeDislike: getIt<RemoveDislike>(),
      removeBulkDislikes: getIt<RemoveBulkDislikes>(),
    ),
  );
}
