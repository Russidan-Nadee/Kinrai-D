import '../entities/protein_preference_entity.dart';
import '../repositories/protein_preference_repository.dart';

class GetAvailableProteinTypes {
  final ProteinPreferenceRepository repository;

  GetAvailableProteinTypes(this.repository);

  Future<List<ProteinTypeEntity>> call({String language = 'th'}) async {
    return await repository.getAvailableProteinTypes(language: language);
  }
}
