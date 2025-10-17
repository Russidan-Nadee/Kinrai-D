import '../entities/protein_preference_entity.dart';
import '../repositories/protein_preference_repository.dart';

class GetUserProteinPreferences {
  final ProteinPreferenceRepository repository;

  GetUserProteinPreferences(this.repository);

  Future<List<ProteinPreferenceEntity>> call({String language = 'th'}) async {
    return await repository.getUserProteinPreferences(language: language);
  }
}
