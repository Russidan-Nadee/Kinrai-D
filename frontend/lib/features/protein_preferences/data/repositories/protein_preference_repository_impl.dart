import '../../domain/entities/protein_preference_entity.dart';
import '../../domain/repositories/protein_preference_repository.dart';
import '../datasources/protein_preference_remote_data_source.dart';

class ProteinPreferenceRepositoryImpl implements ProteinPreferenceRepository {
  final ProteinPreferenceRemoteDataSource remoteDataSource;

  ProteinPreferenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProteinTypeEntity>> getAvailableProteinTypes({String language = 'th'}) async {
    final models = await remoteDataSource.getAvailableProteinTypes(language: language);
    return models.map((model) => model.toEntity(language: language)).toList();
  }

  @override
  Future<List<ProteinPreferenceEntity>> getUserProteinPreferences({String language = 'th'}) async {
    final models = await remoteDataSource.getUserProteinPreferences(language: language);
    return models.map((model) => model.toEntity(language: language)).toList();
  }

  @override
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude}) async {
    return await remoteDataSource.setProteinPreference(
      proteinTypeId: proteinTypeId,
      exclude: exclude,
    );
  }

  @override
  Future<void> removeProteinPreference({required int proteinTypeId}) async {
    return await remoteDataSource.removeProteinPreference(proteinTypeId: proteinTypeId);
  }
}
