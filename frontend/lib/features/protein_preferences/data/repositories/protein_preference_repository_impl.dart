import '../../../../core/utils/logger.dart';
import '../../domain/entities/protein_preference_entity.dart';
import '../../domain/repositories/protein_preference_repository.dart';
import '../datasources/protein_preference_remote_data_source.dart';

class ProteinPreferenceRepositoryImpl implements ProteinPreferenceRepository {
  final ProteinPreferenceRemoteDataSource remoteDataSource;

  ProteinPreferenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProteinTypeEntity>> getAvailableProteinTypes({String language = 'th'}) async {
    // Always fetch from API to get correct language translations
    // Cache is disabled for protein types to ensure language updates work properly
    AppLogger.info('🌐 [ProteinRepo] Fetching protein types from API for language: $language');

    final models = await remoteDataSource.getAvailableProteinTypes(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    return entities;
  }

  @override
  Future<List<ProteinPreferenceEntity>> getUserProteinPreferences({String language = 'th'}) async {
    // Always fetch from API to get correct language translations
    // Cache is disabled for user preferences to ensure language updates work properly
    AppLogger.info('🌐 [ProteinRepo] Fetching user preferences from API for language: $language');

    final models = await remoteDataSource.getUserProteinPreferences(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    return entities;
  }

  @override
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude}) async {
    await remoteDataSource.setProteinPreference(
      proteinTypeId: proteinTypeId,
      exclude: exclude,
    );
  }

  @override
  Future<void> removeProteinPreference({required int proteinTypeId}) async {
    await remoteDataSource.removeProteinPreference(proteinTypeId: proteinTypeId);
  }
}
